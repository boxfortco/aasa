import SwiftUI
import PhotosUI
import UIKit
import CoreImage

struct PhotoUploadView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @StateObject private var aiImageService = AIImageService()
    private let photoSavingService = PhotoSavingService()
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var generatedImage: UIImage?
    @State private var showingImageEditor = false
    @State private var showingSuccess = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingShareSheet = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                GradientBackgroundView()
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 24) {
                        if let image = generatedImage {
                            previewView(image)
                        } else {
                            headerSection
                            photoSelectionSection
                            instructionsSection
                        }
                        
                        Spacer(minLength: 100)
                    }
                }
            }
            .navigationTitle("Photo Magic")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        // Dismiss view
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .onChange(of: selectedItem) { _ in
            Task {
                await loadImage()
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let image = generatedImage {
                ShareSheet(activityItems: [image])
            }
        }
        .alert("Success!", isPresented: $showingSuccess) {
            Button("Done") {
                resetFlow()
            }
        } message: {
            Text("Your photo has been saved to your Photo Library!")
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - View Components
    
    private func previewView(_ image: UIImage) -> some View {
        VStack(spacing: 24) {
            Text("Here's Your Creation!")
                .font(Font.custom("LondrinaSolid-Regular", size: 36))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 400)
                .cornerRadius(15)
                .shadow(radius: 8)
            
            VStack(spacing: 16) {
                Button(action: saveToPhotoLibrary) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Save to Photos")
                    }
                    .font(Font.custom("LondrinaSolid-Light", size: 20))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(25)
                }
                
                Button(action: { showingShareSheet = true }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .font(Font.custom("LondrinaSolid-Light", size: 20))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(25)
                }
                
                Button(action: resetFlow) {
                    Text("Start Over")
                        .font(Font.custom("LondrinaSolid-Light", size: 18))
                        .foregroundColor(.white)
                }
                .padding(.top, 8)
            }
            .padding(.horizontal)
        }
        .padding(.top, 20)
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Text("Add Patrick to Your Photos!")
                .font(Font.custom("LondrinaSolid-Regular", size: 36))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("Select a photo from your album and watch Patrick join the fun!")
                .font(Font.custom("LondrinaSolid-Light", size: 20))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.top, 20)
    }
    
    private var photoSelectionSection: some View {
        VStack(spacing: 20) {
            if let selectedImage = selectedImage {
                selectedImageView(selectedImage)
            } else {
                photoPickerView
            }
        }
        .padding(.horizontal)
    }
    
    private func selectedImageView(_ image: UIImage) -> some View {
        VStack(spacing: 16) {
            // Show selected image
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 300)
                .cornerRadius(15)
                .shadow(radius: 8)
            
            // Generate button
            Button(action: generateImage) {
                HStack {
                    if aiImageService.isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 20))
                    }
                    
                    Text(aiImageService.isProcessing ? "Adding Patrick..." : "Add Patrick to Photo")
                        .font(Font.custom("LondrinaSolid-Light", size: 20))
                }
                .foregroundColor(.white)
                .padding(.vertical, 16)
                .padding(.horizontal, 32)
                .background(Color.blue)
                .cornerRadius(25)
                .shadow(radius: 4)
            }
            .disabled(aiImageService.isProcessing)
            
            // Select different photo button
            Button(action: {
                selectedImage = nil
                selectedItem = nil
            }) {
                Text("Select Different Photo")
                    .font(Font.custom("LondrinaSolid-Light", size: 16))
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 20)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(20)
            }
        }
    }
    
    private var photoPickerView: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            VStack(spacing: 16) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                
                Text("Select a Photo")
                    .font(Font.custom("LondrinaSolid-Light", size: 24))
                    .foregroundColor(.white)
                
                Text("Choose from your photo library")
                    .font(Font.custom("LondrinaSolid-Light", size: 16))
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .background(Color.black.opacity(0.3))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
            )
        }
    }
    
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How it works:")
                .font(Font.custom("LondrinaSolid-Regular", size: 24))
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 8) {
                InstructionRow(number: "1", text: "Select a photo from your album")
                InstructionRow(number: "2", text: "Our AI will add Patrick to your photo")
                InstructionRow(number: "3", text: "Save your creation to your Photo Library")
                InstructionRow(number: "4", text: "Share with friends and family!")
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 20)
        .background(Color.black.opacity(0.3))
        .cornerRadius(15)
        .padding(.horizontal)
    }
    
    private func resetFlow() {
        selectedItem = nil
        selectedImage = nil
        generatedImage = nil
    }
    
    private func loadImage() async {
        guard let item = selectedItem else { return }
        
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                
                // Fix orientation
                let correctlyOrientedImage = uiImage.correctlyOriented()
                
                await MainActor.run {
                    self.selectedImage = correctlyOrientedImage
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load image: \(error.localizedDescription)"
                self.showingError = true
            }
        }
    }
    
    private func generateImage() {
        guard let image = selectedImage, let userId = userViewModel.user?.id else {
            errorMessage = "No image selected or user not logged in."
            showingError = true
            return
        }
        
        Task {
            do {
                let childName = userViewModel.user?.children.first?.name
                let finalImageBase64 = try await aiImageService.generateImageWithPatrick(
                    originalImage: image,
                    childName: childName
                )
                
                // Convert base64 string to UIImage
                guard let imageData = Data(base64Encoded: finalImageBase64),
                      let finalImage = UIImage(data: imageData) else {
                    throw NSError(domain: "ImageConversion", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert base64 to image."])
                }
                
                await MainActor.run {
                    self.generatedImage = finalImage
                }
                
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to generate image: \(error.localizedDescription)"
                    self.showingError = true
                }
            }
        }
    }
    
    private func saveToPhotoLibrary() {
        guard let finalImage = generatedImage else {
            errorMessage = "Could not save the image. Please try again."
            showingError = true
            return
        }
        
        Task {
            do {
                try await photoSavingService.saveImage(finalImage)
                await MainActor.run {
                    self.showingSuccess = true
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to save photo: \(error.localizedDescription)"
                    self.showingError = true
                }
            }
        }
    }
}

extension UIImage {
    func correctlyOriented() -> UIImage {
        if imageOrientation == .up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return normalizedImage
    }
}

struct InstructionRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text("\(number).")
                .font(Font.custom("LondrinaSolid-Regular", size: 20))
                .foregroundColor(.white)
                .frame(width: 30)
            
            Text(text)
                .font(Font.custom("LondrinaSolid-Light", size: 18))
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}

struct PhotoUploadView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoUploadView()
            .environmentObject(UserViewModel())
    }
} 