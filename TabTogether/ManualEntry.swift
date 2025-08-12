

import SwiftUI

struct ManualEntryView: View {
    @State private var billAmount = ""
    @State private var peopleInput = ""
    @State private var tipInput = ""

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
        .navigationTitle("Receipt Info")
        .background(Color(.systemGroupedBackground))
    }
}

// Preview Provider for Xcode
struct ManualEntryView_Previews: PreviewProvider {
    static var previews: some View {
        ManualEntryView()
    }
}

