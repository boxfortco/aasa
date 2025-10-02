import SwiftUI
import UIKit
import ConfettiSwiftUI

struct CharacterCreatorView: View {
    @StateObject private var packManager = CharacterPackManager.shared
    @StateObject private var completionService = BookCompletionService.shared
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userViewModel: UserViewModel
    
    // Asset sizes (updated for new mix and match)
    // Head: 619x534, Torso: 619x275, Legs: 619x477, Total: 619x1286
    private let partWidth: CGFloat = 619
    private let headHeight: CGFloat = 534
    private let bodyHeight: CGFloat = 275
    private let legsHeight: CGFloat = 477
    private let totalHeight: CGFloat = 1286
    
    // Arrays of unlocked image names for each part
    private var headImages: [String] {
        let arr = packManager.getAvailableParts(for: .head).map { $0.imageName }.sorted()
        #if DEBUG
        print("Head images: \(arr)")
        #endif
        return arr
    }
    private var bodyImages: [String] {
        let arr = packManager.getAvailableParts(for: .torso).map { $0.imageName }.sorted()
        #if DEBUG
        print("Body images: \(arr)")
        #endif
        return arr
    }
    private var legsImages: [String] {
        let arr = packManager.getAvailableParts(for: .legs).map { $0.imageName }.sorted()
        #if DEBUG
        print("Legs images: \(arr)")
        #endif
        return arr
    }
    
    // Current indices for each part
    @State private var headIndex: Int = 0
    @State private var bodyIndex: Int = 0
    @State private var legsIndex: Int = 0
    
    // Confetti counters for poof effect
    @State private var headConfetti = 0
    @State private var bodyConfetti = 0
    @State private var legsConfetti = 0
    
    @State private var showingShareSheet = false
    @State private var shareImage: UIImage?
    @State private var showingUnlockAnimation = false
    @State private var newlyUnlockedPack: CharacterPack?
    
    // Clamp indices if image arrays change
    private func clampIndices() {
        if headIndex >= headImages.count { headIndex = max(0, headImages.count - 1) }
        if bodyIndex >= bodyImages.count { bodyIndex = max(0, bodyImages.count - 1) }
        if legsIndex >= legsImages.count { legsIndex = max(0, legsImages.count - 1) }
    }
    
    var body: some View {
        GeometryReader { geo in
            let maxDisplayWidth = geo.size.width * 0.9
            let maxDisplayHeight = geo.size.height * 0.8
            let scale = min(maxDisplayWidth / partWidth, maxDisplayHeight / totalHeight)
            let displayWidth = partWidth * scale
            let displayHeadHeight = headHeight * scale
            let displayBodyHeight = bodyHeight * scale
            let displayLegsHeight = legsHeight * scale
            let displayTotalHeight = totalHeight * scale
            
            ZStack {
                GradientBackgroundView()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    headerSection
                    Spacer(minLength: 0)
                    characterFlipbookSection(
                        width: displayWidth,
                        headHeight: displayHeadHeight,
                        bodyHeight: displayBodyHeight,
                        legsHeight: displayLegsHeight,
                        totalHeight: displayTotalHeight,
                        scale: scale
                    )
                    Spacer(minLength: 0)
                    actionButtonsSection
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            checkForUnlocks()
            clampIndices()
        }
        .onChange(of: headImages) { _ in clampIndices() }
        .onChange(of: bodyImages) { _ in clampIndices() }
        .onChange(of: legsImages) { _ in clampIndices() }
        .sheet(isPresented: $showingShareSheet) {
            if let image = shareImage {
                SystemShareSheet(activityItems: [
                    image,
                    "Check out my character creation on BoxFort! Download the app: https://apps.apple.com/us/app/boxfort-kids-books/id6443570027"
                ])
                .onDisappear {
                    shareImage = nil
                }
            }
        }
        .overlay(
            Group {
                if showingUnlockAnimation, let pack = newlyUnlockedPack {
                    UnlockAnimationView(pack: pack) {
                        showingUnlockAnimation = false
                        newlyUnlockedPack = nil
                    }
                }
            }
        )
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.trailing, 8)
                Text("Back")
                    .foregroundColor(.white)
                    .font(.headline)
            }
            Spacer()
            Text("Character Creator")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Spacer()
            Button("Randomize") {
                randomizeAllParts()
            }
            .foregroundColor(.white)
            .font(.headline)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 8)
    }
    
    // MARK: - Flipbook Section
    private func characterFlipbookSection(
        width: CGFloat,
        headHeight: CGFloat,
        bodyHeight: CGFloat,
        legsHeight: CGFloat,
        totalHeight: CGFloat,
        scale: CGFloat
    ) -> some View {
        VStack(spacing: 0) {
            flipbookRow(
                images: headImages,
                currentIndex: $headIndex,
                label: "Head",
                width: width,
                height: headHeight,
                arrowOffset: .top,
                confettiTrigger: $headConfetti
            )
            .frame(width: width, height: headHeight)
            flipbookRow(
                images: bodyImages,
                currentIndex: $bodyIndex,
                label: "Body",
                width: width,
                height: bodyHeight,
                arrowOffset: .center,
                confettiTrigger: $bodyConfetti
            )
            .frame(width: width, height: bodyHeight)
            flipbookRow(
                images: legsImages,
                currentIndex: $legsIndex,
                label: "Legs",
                width: width,
                height: legsHeight,
                arrowOffset: .bottom,
                confettiTrigger: $legsConfetti
            )
            .frame(width: width, height: legsHeight)
        }
        .frame(width: width, height: totalHeight)
        .background(
            RoundedRectangle(cornerRadius: 40 * scale)
                .fill(Color.white.opacity(0.08))
        )
        .padding(.vertical, 30 * scale)
    }
    
    // MARK: - Flipbook Row
    private enum ArrowOffset { case top, center, bottom }
    private func flipbookRow(
        images: [String],
        currentIndex: Binding<Int>,
        label: String,
        width: CGFloat,
        height: CGFloat,
        arrowOffset: ArrowOffset,
        confettiTrigger: Binding<Int>
    ) -> some View {
        ZStack {
            GeometryReader { geo in
                ZStack {
                    if !images.isEmpty {
                        CharacterPartImage(imageName: images[safe: currentIndex.wrappedValue] ?? "")
                            .frame(width: geo.size.width, height: geo.size.height)
                            .aspectRatio(width/height, contentMode: .fit)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture()
                                    .onEnded { value in
                                        let threshold: CGFloat = 30
                                        if value.translation.width < -threshold {
                                            withAnimation {
                                                currentIndex.wrappedValue = (currentIndex.wrappedValue + 1) % images.count
                                                confettiTrigger.wrappedValue += 1
                                            }
                                        } else if value.translation.width > threshold {
                                            withAnimation {
                                                currentIndex.wrappedValue = (currentIndex.wrappedValue - 1 + images.count) % images.count
                                                confettiTrigger.wrappedValue += 1
                                            }
                                        }
                                    }
                            )
                        // Left arrow
                        HStack {
                            Button(action: {
                                withAnimation {
                                    currentIndex.wrappedValue = (currentIndex.wrappedValue - 1 + images.count) % images.count
                                    confettiTrigger.wrappedValue += 1
                                }
                            }) {
                                Image(systemName: "chevron.left.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.white.opacity(0.7))
                                    .shadow(radius: 2)
                            }
                            .padding(.leading, 8)
                            Spacer()
                            Button(action: {
                                withAnimation {
                                    currentIndex.wrappedValue = (currentIndex.wrappedValue + 1) % images.count
                                    confettiTrigger.wrappedValue += 1
                                }
                            }) {
                                Image(systemName: "chevron.right.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.white.opacity(0.7))
                                    .shadow(radius: 2)
                            }
                            .padding(.trailing, 8)
                        }
                        .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                        // Confetti poof at seam
                        ConfettiSwiftUI.ConfettiCannon(
                            trigger: confettiTrigger,
                            num: 12,
                            colors: [.white, .yellow, .purple, .blue, .orange],
                            confettiSize: 14,
                            rainHeight: 60,
                            opacity: 0.8,
                            openingAngle: .degrees(200),
                            closingAngle: .degrees(340),
                            radius: 40,
                            repetitions: 0,
                            repetitionInterval: 0
                        )
                        .allowsHitTesting(false)
                        .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.2))
                            .overlay(
                                Text(label)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                            )
                    }
                }
            }
        }
    }
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            Button(action: shareCharacter) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Character")
                }
                .foregroundColor(.white)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(isComplete ? Color.blue : Color.gray)
                .cornerRadius(12)
            }
            .disabled(!isComplete)
            .padding(.horizontal, 20)
            
            if let lockedPack = getNextLockedPack() {
                VStack(spacing: 8) {
                    Text("Unlock More Parts!")
                        .font(Font.custom("LondrinaSolid-Light", size: 16))
                        .foregroundColor(.white)
                    Text("Read '\(lockedPack.unlockBookTitle)' to unlock the \(lockedPack.name)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Helper Properties & Methods
    private var isComplete: Bool {
        !headImages.isEmpty && !bodyImages.isEmpty && !legsImages.isEmpty
    }
    
    private func randomizeAllParts() {
        if !headImages.isEmpty { headIndex = Int.random(in: 0..<headImages.count) }
        if !bodyImages.isEmpty { bodyIndex = Int.random(in: 0..<bodyImages.count) }
        if !legsImages.isEmpty { legsIndex = Int.random(in: 0..<legsImages.count) }
    }
    
    private func shareCharacter() {
        guard isComplete else { 
            print("Share: Not complete - head: \(headImages.count), body: \(bodyImages.count), legs: \(legsImages.count)")
            return 
        }
        
        print("Share: Starting image creation")
        print("Share: Head index \(headIndex), image: \(headImages[safe: headIndex] ?? "nil")")
        print("Share: Body index \(bodyIndex), image: \(bodyImages[safe: bodyIndex] ?? "nil")")
        print("Share: Legs index \(legsIndex), image: \(legsImages[safe: legsIndex] ?? "nil")")
        
        // Preload images to ensure they're in memory
        _ = UIImage(named: headImages[safe: headIndex] ?? "")
        _ = UIImage(named: bodyImages[safe: bodyIndex] ?? "")
        _ = UIImage(named: legsImages[safe: legsIndex] ?? "")
        
        let shareWidth: CGFloat = 619
        let shareHeight: CGFloat = 1286
        let scale = shareWidth / partWidth
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: shareWidth, height: shareHeight))
        let image = renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(x: 0, y: 0, width: shareWidth, height: shareHeight))
            var yOffset: CGFloat = 0
            // Draw head
            if let head = headImages[safe: headIndex], let uiImage = UIImage(named: head) {
                let headRect = CGRect(x: 0, y: yOffset, width: shareWidth, height: headHeight * scale)
                uiImage.draw(in: headRect)
                yOffset += headHeight * scale
                print("Share: Drew head \(head)")
            } else {
                print("Share: Failed to load head image")
            }
            // Draw body
            if let body = bodyImages[safe: bodyIndex], let uiImage = UIImage(named: body) {
                let bodyRect = CGRect(x: 0, y: yOffset, width: shareWidth, height: bodyHeight * scale)
                uiImage.draw(in: bodyRect)
                yOffset += bodyHeight * scale
                print("Share: Drew body \(body)")
            } else {
                print("Share: Failed to load body image")
            }
            // Draw legs
            if let legs = legsImages[safe: legsIndex], let uiImage = UIImage(named: legs) {
                let legsRect = CGRect(x: 0, y: yOffset, width: shareWidth, height: legsHeight * scale)
                uiImage.draw(in: legsRect)
                print("Share: Drew legs \(legs)")
            } else {
                print("Share: Failed to load legs image")
            }
        }
        guard image.size.width > 0 && image.size.height > 0 else {
            print("Share: Failed to create share image - size is zero")
            return
        }
        print("Share: Image created successfully - size: \(image.size)")
        guard let imageData = image.pngData() else {
            print("Share: Failed to convert image to PNG data")
            return
        }
        print("Share: Converted to PNG data - size: \(imageData.count) bytes")
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        print("Share: Saved image to photos")
        shareImage = image
        // Add a short delay before presenting the share sheet
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            showingShareSheet = true
            print("Share: Showing share sheet (after delay)")
        }
    }
    
    private func checkForUnlocks() {
        packManager.checkForUnlocks(completedBooks: completionService.completedBooks)
    }
    
    private func getNextLockedPack() -> CharacterPack? {
        return packManager.availablePacks.first { !$0.isUnlocked }
    }
}

// MARK: - Character Part Image View
struct CharacterPartImage: View {
    let imageName: String
    var body: some View {
        Group {
            if UIImage(named: imageName) != nil {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.2))
                    .overlay(
                        VStack {
                            Image(systemName: "person.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.blue)
                            Text(imageName)
                                .font(.caption)
                                .foregroundColor(.blue)
                                .multilineTextAlignment(.center)
                        }
                    )
            }
        }
    }
}

// MARK: - Unlock Animation View

struct UnlockAnimationView: View {
    let pack: CharacterPack
    let onDismiss: () -> Void
    
    @State private var showingAnimation = false
    @State private var showingConfetti = false
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    onDismiss()
                }
            
            VStack(spacing: 20) {
                // Pack icon
                Image(systemName: "gift.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.yellow)
                    .scaleEffect(showingAnimation ? 1.2 : 0.8)
                    .animation(.easeInOut(duration: 0.5).repeatCount(3), value: showingAnimation)
                
                // Pack name
                Text("New Pack Unlocked!")
                    .font(Font.custom("LondrinaSolid-Light", size: 28))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(pack.name)
                    .font(Font.custom("LondrinaSolid-Light", size: 24))
                    .foregroundColor(.yellow)
                    .multilineTextAlignment(.center)
                
                Text("You unlocked this pack by reading '\(pack.unlockBookTitle)'")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                // Sample parts
                HStack(spacing: 20) {
                    ForEach(pack.parts.prefix(3), id: \.id) { part in
                        CharacterPartImage(imageName: part.imageName)
                            .frame(width: 60, height: 60)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                Button("Continue") {
                    onDismiss()
                }
                .foregroundColor(.white)
                .font(.headline)
                .padding(.vertical, 12)
                .padding(.horizontal, 30)
                .background(Color.blue)
                .cornerRadius(20)
            }
            .padding(40)
            .background(Color.black.opacity(0.7))
            .cornerRadius(20)
            .padding(20)
        }
        .onAppear {
            showingAnimation = true
            showingConfetti = true
        }
    }
}

// MARK: - Array Safe Index Extension
extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0 && index < count else { return nil }
        return self[index]
    }
}

struct CharacterCreatorView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterCreatorView()
    }
} 

