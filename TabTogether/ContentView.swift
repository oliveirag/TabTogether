

import SwiftUI
import UIKit // Needed for UIImage

// This extension is required for the .sheet(item:) modifier to work.
extension UIImagePickerController.SourceType: Identifiable {
    public var id: Self { self }
}

struct ContentView: View {
    @State private var receiptImage: UIImage?
    @State private var selectedSource: UIImagePickerController.SourceType?
    @State private var showReceiptInfo = false

    var body: some View {
        // Use NavigationStack as the main container for modern navigation
        NavigationStack {
            VStack(spacing: 40) {
                
                // Camera Button
                Button(action: {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        self.selectedSource = .camera
                    }
                }) {
                    VStack {
                        Image(systemName: "camera.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.blue)
                        Text("Camera")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Photo Library Button
                Button(action: {
                    self.selectedSource = .photoLibrary
                }) {
                    VStack {
                        Image(systemName: "photo.on.rectangle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.green)
                        Text("Photo Library")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Manual Entry Button with NavigationLink
                NavigationLink(destination: ManualEntryView()) {
                    VStack {
                        Image(systemName: "square.and.pencil")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.orange)
                        Text("Enter Manually")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationTitle("Tab Together")
            .navigationDestination(isPresented: $showReceiptInfo) {
                // This will present the ReceiptInfoView when showReceiptInfo is true
                if let image = receiptImage {
                    ReceiptInfoView(receiptImage: image)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .edgesIgnoringSafeArea(.all)
        .sheet(item: $selectedSource) { sourceType in
            ImagePicker(image: $receiptImage, sourceType: sourceType)
        }
        // This is a reliable way to trigger navigation after an image is selected
        .onChange(of: receiptImage) { newImage in
            if newImage != nil {
                self.showReceiptInfo = true
            }
        }
    }
}

// Preview Provider for Xcode
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

