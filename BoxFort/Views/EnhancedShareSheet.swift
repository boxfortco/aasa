import SwiftUI
import UIKit
import SwiftyGif

struct EnhancedShareSheet: View {
    let previewCard: StoryPreviewCard
    @Environment(\.presentationMode) var presentationMode
    @State private var showingQRCode = false
    @State private var showingActivitySheet = false
    @State private var activityItems: [Any] = []
    @State private var showingToast = false
    @State private var toastMessage = ""
    @State private var isPreparingShare = false
    @State private var preparedActivityItems: [Any] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackgroundView()
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Preview Card
                        previewCardSection
                        
                        // Action Buttons
                        actionButtonsSection
                    }
                    .padding(20)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingActivitySheet) {
            ShareSheet(activityItems: activityItems)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .onChange(of: showingActivitySheet) { isShowing in
            if !isShowing && isPreparingShare {
                // If sheet was dismissed while preparing, reset state
                isPreparingShare = false
            }
        }
        .overlay(
            // Toast notification
            VStack {
                Spacer()
                if showingToast {
                    Text(toastMessage)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(8)
                        .padding(.bottom, 100)
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut(duration: 0.3), value: showingToast)
                }
            }
        )
        .onAppear {
            // Pre-cache activity items for faster sharing
            preCacheActivityItems()
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white)
                .font(.headline)
                
                Spacer()
                
                Text("Share Story")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white)
                .font(.headline)
            }
            
            Divider()
                .background(Color.white.opacity(0.3))
        }
    }
    
    // MARK: - Preview Card Section
    
    private var previewCardSection: some View {
        VStack(spacing: 16) {
            // Book Image
            if let previewImage = previewCard.previewImage {
                Image(uiImage: previewImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                    .cornerRadius(12)
            } else {
                SwiftyGifView(imageName: previewCard.book.posterImage)
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                    .cornerRadius(12)
            }
            
            // Book Info
            VStack(spacing: 8) {
                Text(previewCard.book.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(previewCard.book.details)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            
            // QR Code (always show)
            if let qrCode = previewCard.qrCode {
                VStack(spacing: 8) {
                    Image(uiImage: qrCode)
                        .resizable()
                        .frame(width: 100, height: 100)
                        .cornerRadius(8)
                    
                    Text("Scan to read this story")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding(20)
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
    }
    
    // MARK: - Action Buttons Section
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            // Share Button
            Button(action: prepareAndShareContent) {
                HStack {
                    if isPreparingShare {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "square.and.arrow.up")
                    }
                    Text(isPreparingShare ? "Preparing..." : "Share Story")
                }
                .foregroundColor(.white)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(isPreparingShare ? Color.gray : Color.blue)
                .cornerRadius(12)
            }
            .disabled(isPreparingShare)
            
            // Copy Link Button
            Button(action: copyLink) {
                HStack {
                    Image(systemName: "link")
                    Text("Copy Link")
                }
                .foregroundColor(.white)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(Color.green)
                .cornerRadius(12)
            }
            
            // Save Image Button
            Button(action: saveImage) {
                HStack {
                    Image(systemName: "photo")
                    Text("Save Image")
                }
                .foregroundColor(.white)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(Color.orange)
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func prepareAndShareContent() {
        isPreparingShare = true
        
        // Use pre-cached items if available, otherwise prepare them
        if !preparedActivityItems.isEmpty {
            activityItems = preparedActivityItems
            isPreparingShare = false
            showingActivitySheet = true
        } else {
            // Fallback to preparing items
            DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.async {
                    var items: [Any] = []
                    
                    // Add text first (always available)
                    items.append(previewCard.shareText)
                    
                    // Always add cover image
                    if let previewImage = previewCard.previewImage {
                        items.append(previewImage)
                    }
                    
                    // Add app deep link for in-app sharing (not web link)
                    items.append(previewCard.deepLink)
                    
                    // Ensure we have at least the text
                    guard items.count > 0 else {
                        isPreparingShare = false
                        return
                    }
                    
                    // Small delay to ensure UI is ready
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        // Update activity items and show sheet
                        activityItems = items
                        isPreparingShare = false
                        showingActivitySheet = true
                    }
                }
            }
        }
    }
    
    private func copyLink() {
        UIPasteboard.general.string = previewCard.deepLink.absoluteString
        
        // Show feedback
        toastMessage = "Link copied to clipboard!"
        showingToast = true
        
        // Hide toast after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showingToast = false
        }
    }
    
    private func saveImage() {
        guard let image = previewCard.previewImage else { return }
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        // Show feedback
        toastMessage = "Image saved to photos!"
        showingToast = true
        
        // Hide toast after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showingToast = false
        }
    }
    
    private func preCacheActivityItems() {
        // Use DispatchQueue to handle background work without async/await
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                var items: [Any] = []
                
                // Add text first (always available)
                items.append(previewCard.shareText)
                
                // Always add cover image
                if let previewImage = previewCard.previewImage {
                    items.append(previewImage)
                }
                
                // Add app deep link for in-app sharing (not web link)
                items.append(previewCard.deepLink)
                
                // Cache the prepared items
                preparedActivityItems = items
            }
        }
    }
}

// MARK: - QR Code View

struct QRCodeView: View {
    let qrCode: UIImage?
    let book: Book
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackgroundView()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 24) {
                    Text("Scan to Download")
                        .font(Font.custom("LondrinaSolid-Regular", size: 32))
                        .foregroundColor(.white)
                    
                    Text("Share this QR code with friends to help them discover '\(book.title)'")
                        .font(Font.custom("LondrinaSolid-Light", size: 18))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    if let qrCode = qrCode {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(radius: 10)
                            
                            Image(uiImage: qrCode)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 250, height: 250)
                                .padding(20)
                        }
                    }
                    
                    Text("BoxFort - Kids Books")
                        .font(Font.custom("LondrinaSolid-Regular", size: 20))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("QR Code")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
} 