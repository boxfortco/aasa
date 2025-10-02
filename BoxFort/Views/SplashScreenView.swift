import SwiftUI
import AVKit

struct ContainedVideoPlayer: UIViewControllerRepresentable {
    let player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}

struct SplashScreenView: View {
    @State private var showMainContent = false
    @State private var player: AVPlayer?
    
    var body: some View {
        ZStack {
            // Background
            ColorConstants.splashVideoBg
                .edgesIgnoringSafeArea(.all)
            
            // Video Player
            if let player = player {
                ContainedVideoPlayer(player: player)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        player.play()
                    }
                    .overlay(
                        Rectangle()
                            .opacity(0.001)  // Nearly invisible overlay
                            .onTapGesture {
                                showMainContent = true
                            }
                    )
            } else {
                // Loading indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        }
        .fullScreenCover(isPresented: $showMainContent) {
            ContentView()
        }
        .onAppear {
            // Load video
            if let url = Bundle.main.url(forResource: "splash", withExtension: "mp4") {
                player = AVPlayer(url: url)
                
                // Auto-dismiss when video ends
                NotificationCenter.default.addObserver(
                    forName: .AVPlayerItemDidPlayToEndTime,
                    object: player?.currentItem,
                    queue: .main
                ) { _ in
                    showMainContent = true
                }
            }
        }
    }
}

// Helper extension to create Color from hex string
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 