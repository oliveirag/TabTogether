
//
//  ContentView.swift
//  TabTogether
//
//  Created by Sultan Lodi on 8/4/25.
//

import SwiftUI

struct ContentView: View {
    @State private var billAmount = ""
    @State private var peopleInput = ""
    @State private var tipInput = ""

    @State private var showingImagePicker = false
    @State private var useCamera = false
    @State private var receiptImage: UIImage?

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

                    Button("Take Receipt Photo") {
                        useCamera = true
                        showingImagePicker = true
                    }

                    Button("Upload Screenshot") {
                        useCamera = false
                        showingImagePicker = true
                    }
                }
            }
            .navigationTitle("Tab Together")
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $receiptImage, sourceType: useCamera ? .camera : .photoLibrary)
            }
        }
    }
}
