


import SwiftUI
import UIKit
import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseCore

// A struct to represent a receipt document from Firestore
struct Receipt: Identifiable, Codable {
    var id: String?
    var billAmount: Double
    var peopleCount: Int
    var tipInput: String
    var receiptImageBase64: String
    var timestamp: Date?
}

// A helper struct to convert a Base64 string to a UIImage
struct Base64Image: View {
    let base64String: String
    
    var body: some View {
        if let imageData = Data(base64Encoded: base64String), let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .cornerRadius(10)
        } else {
            Text("Image could not be loaded.")
                .foregroundColor(.red)
        }
    }
}

struct PastReceiptsView: View {
    @State private var receipts = [Receipt]()
    @State private var listenerRegistration: ListenerRegistration?
    
    let db: Firestore
    let userId: String
    let firebaseAppId: String
    
    var body: some View {
        List(receipts) { receipt in
            VStack(alignment: .leading) {
                Text("Bill Amount: $\(String(format: "%.2f", receipt.billAmount))")
                    .font(.headline)
                Text("Tip: \(receipt.tipInput)")
                Text("Split between: \(receipt.peopleCount) people")
                if let date = receipt.timestamp {
                    Text("Date: \(date, formatter: itemFormatter)")
                        .font(.caption)
                }
                Base64Image(base64String: receipt.receiptImageBase64)
            }
            .padding(.vertical)
        }
        .navigationTitle("Past Receipts")
        .onAppear {
            self.startListeningForReceipts()
        }
        .onDisappear {
            self.stopListeningForReceipts()
        }
    }
    
    // Starts a real-time listener for receipt documents
    private func startListeningForReceipts() {
        let collectionPath = "artifacts/\(firebaseAppId)/public/data/receipts"
        let receiptQuery = db.collection(collectionPath)
        
        listenerRegistration = receiptQuery.addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            
            self.receipts = documents.compactMap { queryDocumentSnapshot -> Receipt? in
                let data = queryDocumentSnapshot.data()
                let id = queryDocumentSnapshot.documentID
                
                let billAmount = data["billAmount"] as? Double ?? 0.0
                let peopleCount = data["peopleCount"] as? Int ?? 0
                let tipInput = data["tipInput"] as? String ?? ""
                let receiptImageBase64 = data["receiptImageBase64"] as? String ?? ""
                let timestamp = (data["timestamp"] as? Timestamp)?.dateValue()
                
                return Receipt(
                    id: id,
                    billAmount: billAmount,
                    peopleCount: peopleCount,
                    tipInput: tipInput,
                    receiptImageBase64: receiptImageBase64,
                    timestamp: timestamp
                )
            }
            print("Successfully fetched \(self.receipts.count) receipts.")
        }
    }
    
    // Removes the listener when the view disappears
    private func stopListeningForReceipts() {
        listenerRegistration?.remove()
        print("Firestore listener removed.")
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

struct ReceiptInfoView: View {
    @State private var billAmount = ""
    @State private var peopleInput = ""
    @State private var tipInput = ""
    @State private var isLoading = false
    @State private var showSaveAlert = false
    @State private var saveMessage = ""

    // The receipt image passed from ContentView
    let receiptImage: UIImage?

    // Firebase state variables
    @State private var db: Firestore?
    @State private var auth: Auth?
    @State private var userId: String?
    @State private var firebaseAppId: String?
    
    // Computed property for amount per person
    var totalPerPerson: Double {
        let amount = Double(billAmount) ?? 0
        let peopleCount = Double(peopleInput) ?? 1
        let tipAmount = parseTip(amount: amount)
        guard peopleCount > 0 else { return 0 }
        let grandTotal = amount + tipAmount
        return grandTotal / peopleCount
    }

    // Function to parse the tip amount (can be a percentage or a fixed value)
    func parseTip(amount: Double) -> Double {
        let trimmed = tipInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasSuffix("%") {
            let numberPart = trimmed.dropLast()
            if let percent = Double(numberPart) {
                return amount * percent / 100
            }
        }
        return Double(trimmed) ?? 0
    }
    
    // Function to convert UIImage to a Base64 string for the API call
    func base64String(from image: UIImage) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }
        return imageData.base64EncodedString()
    }

    // Function to call the AI for image processing
    func processReceiptWithAI() {
        print("Starting processReceiptWithAI()")
        guard let image = receiptImage else {
            print("Error: receiptImage is nil.")
            return
        }

        guard let base64Image = base64String(from: image) else {
            print("Error: Could not convert receipt image to Base64 string. The image data might be corrupt.")
            return
        }
        print("Image successfully converted to Base64.")

        isLoading = true

        let endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-05-20:generateContent?key=\(API.apiKey)"
        
        let prompt = """
        Extract the total bill amount, tip amount, and number of people from this receipt. The bill amount should be the total amount. Provide the output as a JSON object with keys `billAmount`, `tipAmount`, and `peopleCount`. If a value is not found, use a default of 0. Respond ONLY with the JSON object, do NOT include any other text or markdown formatting.
        """

        // Use a traditional data task to capture detailed error information
        makeAPIRequest(prompt: prompt, base64Image: base64Image, endpoint: endpoint) { result in
            DispatchQueue.main.async {
                self.isLoading = false
            }

            switch result {
            case .success(let (data, response)):
                print("API request successful.")
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("Received status code: \(httpResponse.statusCode)")
                    if httpResponse.statusCode != 200 {
                        print("Error: API returned status code \(httpResponse.statusCode).")
                        if let errorData = String(data: data, encoding: .utf8) {
                            print("Error response data: \(errorData)")
                        }
                        return
                    }
                }

                do {
                    let decodedResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
                    guard let textContent = decodedResponse.candidates.first?.content.parts.first?.text else {
                        print("Error: API response did not contain text content.")
                        return
                    }
                    
                    let regex = try NSRegularExpression(pattern: "\\{.*?\\}", options: .dotMatchesLineSeparators)
                    let nsTextContent = textContent as NSString
                    guard let match = regex.firstMatch(in: textContent, options: [], range: NSRange(location: 0, length: nsTextContent.length)) else {
                        print("Error: No JSON object found in the AI response.")
                        return
                    }
                    let jsonString = nsTextContent.substring(with: match.range)
                    
                    print("Raw response from AI: \(textContent)")
                    print("Extracted JSON string: \(jsonString)")
                    
                    guard let jsonData = jsonString.data(using: .utf8) else {
                        print("Error: Could not convert extracted JSON string to data.")
                        return
                    }
                    
                    guard let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                        print("Error: Could not convert extracted JSON string to dictionary.")
                        return
                    }

                    DispatchQueue.main.async {
                        if let billValue = json["billAmount"] {
                            if let bill = billValue as? Double {
                                self.billAmount = String(format: "%.2f", bill)
                            } else if let billString = billValue as? String, let bill = Double(billString.replacingOccurrences(of: ",", with: "")) {
                                self.billAmount = String(format: "%.2f", bill)
                            }
                        }
                        
                        if let tipValue = json["tipAmount"] {
                            if let tip = tipValue as? Double {
                                self.tipInput = String(format: "%.2f", tip)
                            } else if let tipString = tipValue as? String, let tip = Double(tipString.replacingOccurrences(of: ",", with: "")) {
                                self.tipInput = String(format: "%.2f", tip)
                            }
                        }
                        
                        if let peopleValue = json["peopleCount"] {
                            if let people = peopleValue as? Double {
                                self.peopleInput = String(Int(people))
                            } else if let people = peopleValue as? Int {
                                self.peopleInput = String(people)
                            } else if let peopleString = peopleValue as? String, let people = Int(peopleString) {
                                self.peopleInput = String(people)
                            }
                        }
                        print("Successfully parsed and updated UI with AI data.")
                        print("Updated Bill Amount: \(self.billAmount)")
                        print("Updated Tip: \(self.tipInput)")
                        print("Updated People Count: \(self.peopleInput)")
                    }
                } catch {
                    print("Error during JSON decoding or parsing: \(error.localizedDescription)")
                    print("Possible reason: The response data format is not what the app is expecting.")
                }
            case .failure(let error):
                print("Failed to process receipt: \(error.localizedDescription)")
                print("Possible reason: The API call itself failed. Check network connection or API key.")
            }
        }
    }
    
    // MARK: API Call (Updated to use a completion handler)
    
    func makeAPIRequest(prompt: String, base64Image: String, endpoint: String, completion: @escaping (Result<(Data, URLResponse), Error>) -> Void) {
        guard let url = URL(string: endpoint) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        [ "text": prompt ],
                        [ "inlineData": ["mimeType": "image/jpeg", "data": base64Image] ]
                    ]
                ]
            ]
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload)
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Network request error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let data = data, let response = response else {
                    print("Error: Data or response was nil.")
                    completion(.failure(URLError(.cannotParseResponse)))
                    return
                }
                
                completion(.success((data, response)))
            }
            task.resume()
        } catch {
            print("Error creating JSON payload for API request: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }

    // MARK: Firebase Functionality
    
    func saveReceipt() {
        guard let db = db, let userId = userId, let appId = firebaseAppId else {
            print("Firestore is not initialized or user is not signed in.")
            return
        }

        guard let receiptImage = receiptImage, let base64Image = base64String(from: receiptImage) else {
            self.saveMessage = "Error: No receipt image to save."
            self.showSaveAlert = true
            return
        }
        
        let receiptData: [String: Any] = [
            "billAmount": Double(billAmount) ?? 0,
            "peopleCount": Int(peopleInput) ?? 1,
            "tipInput": tipInput,
            "receiptImageBase64": base64Image,
            "timestamp": FieldValue.serverTimestamp(),
            "userId": userId
        ]
        
        let collectionPath = "artifacts/\(appId)/public/data/receipts"
        
        do {
            _ = try db.collection(collectionPath).addDocument(data: receiptData)
            self.saveMessage = "Receipt saved successfully!"
            self.showSaveAlert = true
        } catch {
            self.saveMessage = "Error saving document: \(error)"
            self.showSaveAlert = true
            print("Error adding document: \(error)")
        }
    }

    // MARK: API Response Structs
    
    struct GeminiResponse: Decodable {
        let candidates: [Candidate]
    }
    
    struct Candidate: Decodable {
        let content: Content
    }
    
    struct Content: Decodable {
        let parts: [Part]
    }
    
    struct Part: Decodable {
        let text: String
    }
    
    // MARK: View Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    if let image = receiptImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .cornerRadius(10)
                            .padding()
                    }

                    if isLoading {
                        ProgressView("Processing receipt...")
                            .padding()
                    } else {
                        Form {
                            Section(header: Text("Bill Amount")) {
                                TextField("Enter bill amount", text: $billAmount)
                                    .keyboardType(.decimalPad)
                            }
                            Section(header: Text("Number of People")) {
                                TextField("Enter number of people", text: $peopleInput)
                                    .keyboardType(.numberPad)
                            }
                            Section(header: Text("Tip (amount or %)")) {
                                TextField("e.g. 5 or 10%", text: $tipInput)
                                    .keyboardType(.default)
                            }
                            Section(header: Text("Amount Per Person")) {
                                Text("$\(totalPerPerson, specifier: "%.2f")")
                                    .font(.largeTitle)
                                    .foregroundColor(.blue)
                            }
                            
                            Button("Save Receipt") {
                                saveReceipt()
                            }
                            .alert(isPresented: $showSaveAlert) {
                                Alert(title: Text("Save Status"), message: Text(saveMessage), dismissButton: .default(Text("OK")))
                            }
                        }
                        .frame(height: 500)
                        .padding()
                    }
                }
            }
            .navigationTitle("Receipt Info")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let db = db, let userId = userId, let appId = firebaseAppId {
                        NavigationLink(destination: PastReceiptsView(db: db, userId: userId, firebaseAppId: appId)) {
                            Text("View Past Receipts")
                        }
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .onAppear {
                self.firebaseAppId = "__app_id"
                Task {
                    do {
                        let auth = Auth.auth()
                        if "__initial_auth_token".isEmpty == false {
                            _ = try await auth.signIn(withCustomToken: "__initial_auth_token")
                        } else {
                            _ = try await auth.signInAnonymously()
                        }
                        self.db = Firestore.firestore()
                        self.auth = auth
                        self.userId = auth.currentUser?.uid
                        print("Firebase Auth and Firestore initialized.")
                        
                        DispatchQueue.main.async {
                            self.processReceiptWithAI()
                        }
                    } catch {
                        print("Error with Firebase authentication: \(error)")
                    }
                }
            }
        }
    }
}

