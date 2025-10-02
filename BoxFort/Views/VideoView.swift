//
//  VideoView.swift
//  BoxFort
//
//  Created by Matthew Ryan on 4/11/25.
//


import SwiftUI
import AVKit

struct VideoView: View {
    let bookUrl: String
    @Environment(\.presentationMode) var presentationMode
    @State private var player: AVPlayer? = nil

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Use GeometryReader to ensure full coverage of the parent view
            GeometryReader { _ in
                if let player = player {
                    VideoPlayer(player: player)
                        .edgesIgnoringSafeArea(.all)
                } else {
                    Text("Preparing video...")
                }
            }

            // Ensure close button is always accessible and visible
            closeButton
                .padding(20) // Provide padding from the edges
                .background(Color.white.opacity(0.5)) // Optional: Add background for visibility
                .clipShape(Circle())
                .padding(.top, safeAreaTopPadding()) // Adjust for safe area
                .padding(.trailing, 16) // Consistent padding from trailing edge
        }
        .onAppear {
            setupPlayer()
        }
        .onChange(of: bookUrl) { _ in
            setupPlayer() // Resetup the player if the bookUrl changes
        }
    }

    private func setupPlayer() {
        guard let url = videoURL(from: bookUrl) else {
            print("Video URL not found.")
            return
        }
        player = AVPlayer(url: url)
        player?.play() // Autoplay
    }

    private func videoURL(from videoName: String) -> URL? {
        // Extracts the video name and type, assuming it's stored in a "video" directory within the bundle
        let videoPathComponents = videoName.split(separator: ".")
        guard videoPathComponents.count > 1,
              let path = Bundle.main.path(forResource: String(videoPathComponents[0]), ofType: String(videoPathComponents[1]), inDirectory: "video") else {
            return nil
        }
        return URL(fileURLWithPath: path)
    }

    private var closeButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "xmark.circle")
                .foregroundColor(.white)
                .padding()
                .background(Circle().fill(Color.black.opacity(0.7)))
        }
    }

    // Helper to adjust for the top safe area in various devices
    private func safeAreaTopPadding() -> CGFloat {
        let window = UIApplication.shared.windows.first
        let safeFrame = window?.safeAreaLayoutGuide.layoutFrame
        return safeFrame?.minY ?? 0
    }
}




/*
import SwiftUI
import AVKit

struct VideoView: View {
    let bookUrl: String
    @Environment(\.presentationMode) var presentationMode
    @State private var player: AVPlayer?
    @State private var orientation = UIDevice.current.orientation

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if let player = player {
                    VideoPlayer(player: player)
                        .edgesIgnoringSafeArea(.all)
                } else {
                    Text("Preparing video...")
                        .onAppear {
                            setupVideoPlayer()
                        }
                }
            }

            closeButton
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { _ in
                orientation = UIDevice.current.orientation
                // Optionally pause/play or adjust video player settings based on orientation
            }
        }
        .onChange(of: orientation) { newOrientation in
            // Handle orientation change
            // For example, you might want to adjust the player's settings or UI elements
            print("Orientation changed to \(newOrientation)")
        }
    }

    private func setupVideoPlayer() {
        guard let videoURL = videoURL(from: bookUrl) else { return }
        player = AVPlayer(url: videoURL)
        player?.play() // Autoplay when the view appears
    }

    private func videoURL(from videoName: String) -> URL? {
        let videoPathComponents = videoName.split(separator: ".")
        guard videoPathComponents.count > 1,
              let path = Bundle.main.path(forResource: String(videoPathComponents[0]), ofType: String(videoPathComponents[1]), inDirectory: "video") else { return nil }
        return URL(fileURLWithPath: path)
    }

    private var closeButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "xmark.circle.fill")
                .font(.title)
                .foregroundColor(.white.opacity(0.8))
                .padding(.trailing, 10)
                .padding(.top, 10)
        }
    }
}
*/

/*
import SwiftUI
import AVKit

struct VideoView: View {
    let bookUrl: String
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Directly create a VideoPlayer with the AVPlayer initialized with the video URL
            if let videoURL = videoURL(from: bookUrl) {
                VideoPlayer(player: AVPlayer(url: videoURL))
                    .edgesIgnoringSafeArea(.all)
            } else {
                Text("Video file not found.")
            }

            closeButton
        }
    }

    private func videoURL(from videoName: String) -> URL? {
        // Assuming the videoName includes the file extension, e.g., "FollowThatDuck.mp4"
        let videoPathComponents = videoName.split(separator: ".")
        guard videoPathComponents.count > 1,
              let path = Bundle.main.path(forResource: String(videoPathComponents[0]), ofType: String(videoPathComponents[1]), inDirectory: "video") else { return nil }
        return URL(fileURLWithPath: path)
    }

    private var closeButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "xmark.circle.fill")
                .font(.title)
                .foregroundColor(.white.opacity(0.8))
                .padding(.trailing, 10)
                .padding(.top, 10)
        }
    }
}
*/
