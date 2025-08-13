

import SwiftUI
import UIKit // Needed for UIImage

// This extension is required for the .sheet(item:) modifier to work.
extension UIImagePickerController.SourceType: Identifiable {
    public var id: Self { self }
}

// Temporary data model for bills - will be replaced with Core Data later
struct Bill: Identifiable {
    let id = UUID()
    let date: Date
    let totalAmount: Double
    let participants: Int
    let thumbnail: UIImage?
    let title: String
}

struct ContentView: View {
    @State private var receiptImage: UIImage?
    @State private var selectedSource: UIImagePickerController.SourceType?
    @State private var showReceiptInfo = false
    @State private var bills: [Bill] = [] // Will be populated from persistent storage later
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Main Content
                VStack(spacing: 0) {
                    if bills.isEmpty {
                        // Empty State
                        emptyStateView
                    } else {
                        // Bills List
                        billsListView
                    }
                }
                
                // Floating Action Buttons
                VStack {
                    Spacer()
                    HStack {
                        // Gallery Button (bottom-left)
                        FloatingActionButton(
                            icon: "photo.on.rectangle",
                            label: "Gallery",
                            color: .green,
                            position: .leading
                        ) {
                            selectedSource = .photoLibrary
                        }
                        
                        Spacer()
                        
                        // Manual Entry Button (center-bottom)
                        NavigationLink(destination: ManualEntryView()) {
                            FloatingActionButton(
                                icon: "square.and.pencil",
                                label: "Manual",
                                color: .orange,
                                position: .center
                            )
                        }
                        
                        Spacer()
                        
                        // Camera Button (bottom-right)
                        FloatingActionButton(
                            icon: "camera.fill",
                            label: "Camera",
                            color: .blue,
                            position: .trailing
                        ) {
                            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                selectedSource = .camera
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 34) // Account for safe area
                }
            }
            .navigationTitle("TabTogether")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
            .navigationDestination(isPresented: $showReceiptInfo) {
                if let image = receiptImage {
                    ReceiptInfoView(receiptImage: image)
                }
            }
        }
        .sheet(item: $selectedSource) { sourceType in
            ImagePicker(image: $receiptImage, sourceType: sourceType)
        }
        .onChange(of: receiptImage) { newImage in
            if newImage != nil {
                showReceiptInfo = true
            }
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Empty State Illustration
            VStack(spacing: 16) {
                Image(systemName: "doc.text.viewfinder")
                    .font(.system(size: 80, weight: .thin))
                    .foregroundColor(.secondary)
                
                VStack(spacing: 8) {
                    Text("No Bills Yet")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("Start by capturing a receipt or entering bill details manually")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }
            
            Spacer()
            
            // Quick Start Instructions
            VStack(spacing: 16) {
                Text("Get Started:")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack(spacing: 24) {
                    QuickStartItem(
                        icon: "camera.fill",
                        text: "Snap a photo",
                        color: .blue
                    )
                    
                    QuickStartItem(
                        icon: "photo.on.rectangle",
                        text: "Choose from gallery",
                        color: .green
                    )
                    
                    QuickStartItem(
                        icon: "square.and.pencil",
                        text: "Enter manually",
                        color: .orange
                    )
                }
            }
            .padding(.bottom, 120) // Space for floating buttons
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Bills List View
    private var billsListView: some View {
        List(bills) { bill in
            BillRowView(bill: bill)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        }
        .listStyle(InsetGroupedListStyle())
        .padding(.bottom, 100) // Space for floating buttons
    }
}

// MARK: - Supporting Views

struct FloatingActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let position: HorizontalAlignment
    let action: (() -> Void)?
    
    init(icon: String, label: String, color: Color, position: HorizontalAlignment, action: (() -> Void)? = nil) {
        self.icon = icon
        self.label = label
        self.color = color
        self.position = position
        self.action = action
    }
    
    var body: some View {
        Button(action: { action?() }) {
            VStack(spacing: 8) {
                Circle()
                    .fill(color)
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                
                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuickStartItem: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(color)
                .frame(width: 40, height: 40)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct BillRowView: View {
    let bill: Bill
    
    var body: some View {
        HStack(spacing: 16) {
            // Bill Thumbnail
            if let thumbnail = bill.thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipped()
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.secondary.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "doc.text")
                            .foregroundColor(.secondary)
                    )
            }
            
            // Bill Info
            VStack(alignment: .leading, spacing: 4) {
                Text(bill.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("$\(bill.totalAmount, specifier: "%.2f") • \(bill.participants) people")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(bill.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// Preview Provider for Xcode
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

