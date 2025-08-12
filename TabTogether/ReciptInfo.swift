

import SwiftUI
import UIKit
import Foundation

struct ReceiptInfoView: View {
    @State private var billAmount = ""
    @State private var peopleInput = ""
    @State private var tipInput = ""
    @State private var isLoading = false
    
    // The receipt image passed from ContentView
    let receiptImage: UIImage?

    var totalPerPerson: Double {
        let amount = Double(billAmount) ?? 0
        let peopleCount = Double(peopleInput) ?? 1
        let tipAmount = parseTip(amount: amount)
        guard peopleCount > 0 else { return 0 }
        let grandTotal = amount + tipAmount
        return grandTotal / peopleCount
    }

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
        guard let image = receiptImage, let base64Image = base64String(from: image) else { return }

        isLoading = true

        // Read the API key from Info.plist
        guard let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String else {
            print("Error: API_KEY not found in Info.plist")
            isLoading = false
            return
        }

        let endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-05-20:generateContent?key=\(apiKey)"
        let prompt = "Extract the total bill amount, tip amount, and number of people from this receipt. Provide the output as a JSON object with keys `billAmount`, `tipAmount`, and `peopleCount`. If a value is not found, use a default of 0. Ignore tax. Respond only with the JSON object, no other text or markdown formatting."

        Task {
            do {
                // The actual API call to the Gemini model
                let (data, _) = try await makeAPIRequest(prompt: prompt, base64Image: base64Image, endpoint: endpoint)
                
                // Parse the JSON response
                if let decodedResponse = try? JSONDecoder().decode(GeminiResponse.self, from: data) {
                    if let textContent = decodedResponse.candidates.first?.content.parts.first?.text {
                        
                        // Clean the string to ensure it's a valid JSON format
                        let cleanedText = textContent
                            .replacingOccurrences(of: "```json", with: "")
                            .replacingOccurrences(of: "```", with: "")
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        if let jsonData = cleanedText.data(using: .utf8),
                           let parsedData = try? JSONDecoder().decode([String: Double].self, from: jsonData) {
                            
                            // Update the state variables with the parsed data
                            if let bill = parsedData["billAmount"] {
                                billAmount = String(format: "%.2f", bill)
                            }
                            if let tip = parsedData["tipAmount"] {
                                tipInput = String(format: "%.2f", tip)
                            }
                            if let people = parsedData["peopleCount"] {
                                peopleInput = String(Int(people))
                            }
                        }
                    }
                }
            } catch {
                print("Failed to process receipt: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }
    
    // MARK: API Call
    
    // A function to make the real API request
    func makeAPIRequest(prompt: String, base64Image: String, endpoint: String) async throws -> (Data, URLResponse) {
        let url = URL(string: endpoint)!
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
        
        let jsonData = try JSONSerialization.data(withJSONObject: payload)
        request.httpBody = jsonData
        
        return try await URLSession.shared.data(for: request)
    }

    // MARK: API Response Structs
    
    // These structs help decode the JSON response from the API
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
                    }
                    .frame(height: 500) // Set a fixed height for the Form
                    .padding()
                }
            }
        }
        .navigationTitle("Receipt Info")
        .background(Color(.systemGroupedBackground))
        .onAppear {
            // Process the receipt as soon as the view appears
            processReceiptWithAI()
        }
    }
}

