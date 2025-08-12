

import SwiftUI

struct ContentView: View {
    @State private var billAmount = ""
    @State private var peopleInput = ""
    @State private var tipInput = ""
    @State private var receiptImage: UIImage?
    
    @State private var selectedSource: UIImagePickerController.SourceType?
    @State private var showCameraAlert = false

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
    
    var body: some View {
        NavigationView {
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

                Section(header: Text("Receipt Photo")) {
                    if let image = receiptImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                    }

                    // The new button UI
                    HStack(spacing: 20) {
                        Spacer()
                        
                        // Camera Button
                        Button(action: {
                            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    self.selectedSource = .camera
                                }
                            } else {
                                self.showCameraAlert = true
                            }
                        }) {
                            Image(systemName: "camera.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Upload Button
                        Button(action: {
                            self.selectedSource = .photoLibrary
                        }) {
                            Image(systemName: "photo.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("Tab Together")
            
            .sheet(item: $selectedSource) { sourceType in
                ImagePicker(image: $receiptImage, sourceType: sourceType)
            }
            .alert(isPresented: $showCameraAlert) {
                Alert(
                    title: Text("Camera Not Available"),
                    message: Text("This device has no camera."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

// Ensure this extension is still in your project.
extension UIImagePickerController.SourceType: Identifiable {
    public var id: Self { self }
}
