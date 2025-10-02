import SwiftUI
import AVFoundation

// MARK: - Cutscene View
struct CatCallCrisisCutsceneView: View {
    let cutscene: CutsceneData
    let onContinue: () -> Void
    
    @State private var displayedText = ""
    @State private var isTextComplete = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var showContinueButton = false
    
    private let typewriterSpeed: TimeInterval = 0.05
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                backgroundView
                
                // Main content
                VStack(spacing: 20) {
                    Spacer()
                    
                    // Cat character
                    catCharacterView
                    
                    // Dialogue bubble
                    dialogueBubbleView
                    
                    Spacer()
                    
                    // Continue button
                    if showContinueButton {
                        continueButtonView
                    }
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 60)
            }
        }
        .onAppear {
            startCutscene()
        }
        .onDisappear {
            stopAudio()
        }
    }
    
    // MARK: - Background View
    private var backgroundView: some View {
        ZStack {
            // Pixel art background
            Image(backgroundImageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
            
            // Overlay for better text readability
            Rectangle()
                .fill(Color.black.opacity(0.3))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    // MARK: - Cat Character View
    private var catCharacterView: some View {
        VStack(spacing: 10) {
            // Cat sprite
            Image(catExpressionImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 200)
                .scaleEffect(1.0)
                .animation(.easeInOut(duration: 0.5), value: isTextComplete)
            
            // Cat name/title
            Text(cutscene.title)
                .font(.custom("LondrinaSolid-Regular", size: 24))
                .foregroundColor(.white)
                .shadow(color: .black, radius: 2, x: 1, y: 1)
        }
    }
    
    // MARK: - Dialogue Bubble View
    private var dialogueBubbleView: some View {
        VStack(spacing: 15) {
            // Speech bubble background
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.3), radius: 5, x: 2, y: 2)
                .overlay(
                    // Speech bubble tail
                    Triangle()
                        .fill(Color.white)
                        .frame(width: 20, height: 15)
                        .rotationEffect(.degrees(180))
                        .offset(y: 10)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                    , alignment: .top
                )
            
            // Dialogue text
            Text(displayedText)
                .font(.custom("LondrinaSolid-Regular", size: 18))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Continue Button View
    private var continueButtonView: some View {
        Button(action: onContinue) {
            HStack(spacing: 10) {
                Text("Continue")
                    .font(.custom("LondrinaSolid-Regular", size: 20))
                    .foregroundColor(.white)
                
                Image(systemName: "arrow.right.circle.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 20))
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 15)
            .background(Color.black.opacity(0.7))
            .cornerRadius(25)
            .shadow(color: .black.opacity(0.3), radius: 3, x: 1, y: 1)
        }
        .transition(.scale.combined(with: .opacity))
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showContinueButton)
    }
    
    // MARK: - Helper Views
    private var backgroundImageName: String {
        return cutscene.backgroundImage
    }
    
    private var catExpressionImageName: String {
        return "cat_\(cutscene.catExpression)"
    }
    
    // MARK: - Cutscene Logic
    private func startCutscene() {
        // Start typewriter effect
        startTypewriterEffect()
        
        // Play audio if available
        if let audioFile = cutscene.audioFile {
            playAudio(named: audioFile)
        }
    }
    
    private func startTypewriterEffect() {
        displayedText = ""
        isTextComplete = false
        showContinueButton = false
        
        let fullText = cutscene.dialogue
        var currentIndex = 0
        
        Timer.scheduledTimer(withTimeInterval: typewriterSpeed, repeats: true) { timer in
            if currentIndex < fullText.count {
                let index = fullText.index(fullText.startIndex, offsetBy: currentIndex)
                displayedText += String(fullText[index])
                currentIndex += 1
            } else {
                timer.invalidate()
                isTextComplete = true
                
                // Show continue button after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation {
                        showContinueButton = true
                    }
                }
            }
        }
    }
    
    private func playAudio(named fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            print("Cat Call Crisis: Audio file not found: \(fileName)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Cat Call Crisis: Failed to play audio: \(error)")
        }
    }
    
    private func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}

// MARK: - Triangle Shape for Speech Bubble
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Cutscene Container View
struct CatCallCrisisCutsceneContainerView: View {
    let cutscene: CutsceneData
    let onContinue: () -> Void
    let onSkip: () -> Void
    
    @State private var showSkipButton = false
    
    var body: some View {
        ZStack {
            CatCallCrisisCutsceneView(cutscene: cutscene, onContinue: onContinue)
            
            // Skip button
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: onSkip) {
                        Text("Skip")
                            .font(.custom("LondrinaSolid-Regular", size: 16))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(15)
                    }
                    .opacity(showSkipButton ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.3), value: showSkipButton)
                }
                .padding(.top, 50)
                .padding(.trailing, 20)
                
                Spacer()
            }
        }
        .onAppear {
            // Show skip button after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    showSkipButton = true
                }
            }
        }
    }
}

// MARK: - Preview
struct CatCallCrisisCutsceneView_Previews: PreviewProvider {
    static var previews: some View {
        CatCallCrisisCutsceneView(
            cutscene: CutsceneData.cutscenes[0],
            onContinue: {}
        )
        .preferredColorScheme(.dark)
    }
} 