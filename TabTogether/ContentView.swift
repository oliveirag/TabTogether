

import SwiftUI
import UIKit // Needed for UIImage

// This extension is required for the .sheet(item:) modifier to work.
extension UIImagePickerController.SourceType: @retroactive Identifiable {
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
    var isFavorited: Bool = false
}

enum FABMenuOption: String, CaseIterable {
    case scanReceipt = "Scan receipt"
    case photoLibrary = "Photo library"
    case enterManually = "Enter manually"
    case savedReceipts = "Saved receipts"
    
    var icon: String {
        switch self {
        case .scanReceipt: return "camera.fill"
        case .photoLibrary: return "photo.on.rectangle"
        case .enterManually: return "square.and.pencil"
        case .savedReceipts: return "heart.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .scanReceipt: return .blue
        case .photoLibrary: return .green
        case .enterManually: return .orange
        case .savedReceipts: return .pink
        }
    }
}

struct ContentView: View {
    @State private var receiptImage: UIImage?
    @State private var selectedSource: UIImagePickerController.SourceType?
    @State private var showReceiptInfo = false
    @State private var bills: [Bill] = [] // Will be populated from persistent storage later
    @State private var showFABMenu = false
    @State private var showSavedReceipts = false
    @State private var showManualEntry = false
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            homeView
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(0)
            
            // Saved Tab
            savedTabView
                .tabItem {
                    Image(systemName: "heart")
                    Text("Saved")
                }
                .tag(1)
            
            // Settings Tab
            settingsTabView
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
                .tag(2)
        }
        .overlay(alignment: .bottomTrailing) {
            // Plus FAB - positioned to match Cal AI design
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showFABMenu.toggle()
                }
            }) {
                Image(systemName: showFABMenu ? "xmark" : "plus")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.black)
                    .clipShape(Circle())
                    .rotationEffect(.degrees(showFABMenu ? 45 : 0))
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            }
            .padding(.trailing, 16)
            .padding(.bottom, 100) // Above tab bar
        }
        .overlay(alignment: .bottomTrailing) {
            // FAB Menu Items
            if showFABMenu {
                VStack(spacing: 16) {
                    ForEach(FABMenuOption.allCases.reversed(), id: \.self) { option in
                        FABMenuItemView(option: option) {
                            handleFABMenuSelection(option)
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                    }
                }
                .padding(.trailing, 16) // Match FAB alignment
                .padding(.bottom, 210) // Above FAB button
            }
        }
        .sheet(isPresented: $showSavedReceipts) {
            SavedReceiptsView(bills: $bills)
        }
        .sheet(isPresented: $showManualEntry) {
            ManualEntryView()
        }
        .sheet(item: $selectedSource, onDismiss: {
            selectedSource = nil
        }) { source in
            ImagePicker(image: $receiptImage, sourceType: source)
        }
        .navigationDestination(isPresented: $showReceiptInfo) {
            if let image = receiptImage {
                ReceiptInfoView(receiptImage: image)
            }
        }
    }
    
    private var homeView: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    Color(.systemGroupedBackground)
                        .ignoresSafeArea()
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            // Header
                            headerView
                            
                            // Main Content Card
                            mainContentCard
                            
                            // Recently Uploaded Section
                            recentlyUploadedSection
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100) // Space for FAB
                    }

                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private var savedTabView: some View {
        NavigationStack {
            VStack {
                Spacer()
                Image(systemName: "heart.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.pink)
                Text("Saved Receipts")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 16)
                Text("Your favorited receipts will appear here")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Spacer()
            }
            .navigationTitle("Saved")
            .background(Color(.systemGroupedBackground))
        }
    }
    
    private var settingsTabView: some View {
        NavigationStack {
            VStack {
                Spacer()
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 16)
                Text("App settings and preferences will be available here")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Spacer()
            }
            .navigationTitle("Settings")
            .background(Color(.systemGroupedBackground))
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            // Logo placeholder and app title
            HStack(spacing: 12) {
                // Logo placeholder - will be replaced with actual logo later
                Circle()
                    .fill(Color.clear)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                            .overlay(
                                Text("🧾")
                                    .font(.system(size: 16))
                            )
                    )
                
                Text("TabTogether")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding(.top, 8)
    }
    
    // MARK: - Main Content Card
    private var mainContentCard: some View {
        VStack(spacing: 20) {
            if bills.isEmpty {
                // Empty state content
                VStack(spacing: 16) {
                    Text("0")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Bills split")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    // Visual element placeholder
                    Circle()
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 8)
                        .frame(width: 120, height: 120)
                        .overlay(
                            Image(systemName: "receipt")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary.opacity(0.5))
                        )
                }
            } else {
                // Stats when bills exist
                VStack(spacing: 16) {
                    Text("\(bills.count)")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Bills split")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    // Progress circle with bill count
                    ZStack {
                        Circle()
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 8)
                            .frame(width: 120, height: 120)
                        
                        Circle()
                            .trim(from: 0, to: min(Double(bills.count) / 100.0, 1.0))
                            .stroke(Color.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))
                        
                        Image(systemName: "receipt")
                            .font(.system(size: 32))
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Recently Uploaded Section
    private var recentlyUploadedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recently uploaded")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            if bills.isEmpty {
                // Empty state for recently uploaded
                VStack(spacing: 12) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary.opacity(0.5))
                    
                    Text("Tap + to add your first receipt")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(Color(.systemBackground))
                .cornerRadius(12)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(bills.prefix(5)) { bill in
                        BillRowView(bill: bill) {
                            toggleFavorite(for: bill)
                        }
                    }
                }
            }
        }
    }
    

    
    // MARK: - Helper Functions
    private func toggleFavorite(for bill: Bill) {
        if let index = bills.firstIndex(where: { $0.id == bill.id }) {
            bills[index].isFavorited.toggle()
        }
    }
    
    private func handleFABMenuSelection(_ option: FABMenuOption) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showFABMenu = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            switch option {
            case .scanReceipt:
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    selectedSource = .camera
                }
            case .photoLibrary:
                selectedSource = .photoLibrary
            case .enterManually:
                showManualEntry = true
            case .savedReceipts:
                showSavedReceipts = true
            }
        }
    }
}

// MARK: - Supporting Views

struct FABMenuItemView: View {
    let option: FABMenuOption
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Text(option.rawValue)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                .cornerRadius(25)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            Button(action: action) {
                Image(systemName: option.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(option.color)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
            }
        }
    }
}

struct BillRowView: View {
    let bill: Bill
    let onFavoriteToggle: () -> Void
    
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
                    .fill(Color.secondary.opacity(0.1))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "doc.text")
                            .font(.system(size: 24))
                            .foregroundColor(.secondary)
                    )
            }
            
            // Bill Info
            VStack(alignment: .leading, spacing: 6) {
                Text(bill.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("$\(bill.totalAmount, specifier: "%.2f") • \(bill.participants) people")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(bill.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Favorite Button
            Button(action: onFavoriteToggle) {
                Image(systemName: bill.isFavorited ? "heart.fill" : "heart")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(bill.isFavorited ? .pink : .secondary)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.02), radius: 1, x: 0, y: 1)
    }
}

// MARK: - Saved Receipts View

struct SavedReceiptsView: View {
    @Binding var bills: [Bill]
    @Environment(\.dismiss) private var dismiss
    
    private var savedBills: [Bill] {
        bills.filter { $0.isFavorited }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if savedBills.isEmpty {
                    // Empty state
                    VStack(spacing: 24) {
                        Spacer()
                        
                        Image(systemName: "heart.slash")
                            .font(.system(size: 60, weight: .thin))
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 8) {
                            Text("No Saved Receipts")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text("Tap the heart icon on any receipt to save it here")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        
                        Spacer()
                    }
                } else {
                    // Saved bills list
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(savedBills) { bill in
                                BillRowView(bill: bill) {
                                    toggleFavorite(for: bill)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                    }
                }
            }
            .navigationTitle("Saved Receipts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func toggleFavorite(for bill: Bill) {
        if let index = bills.firstIndex(where: { $0.id == bill.id }) {
            bills[index].isFavorited.toggle()
        }
    }
}

// Preview Provider for Xcode
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

