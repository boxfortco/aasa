//
//  FullScreenVideoPlayer.swift
//  BoxFort
//
//  Created by Matthew Ryan on 4/11/25.
//


import SwiftUI
import AVKit

struct FullScreenVideoPlayer: UIViewControllerRepresentable {
    var videoURL: URL
    var presented: Binding<Bool>
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, presented: presented)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController() // Placeholder
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if presented.wrappedValue {
            DispatchQueue.main.async {
                let playerViewController = AVPlayerViewController()
                playerViewController.player = AVPlayer(url: videoURL)
                context.coordinator.present(playerViewController, in: uiViewController)
            }
        }
    }
    
    class Coordinator: NSObject {
        var parent: FullScreenVideoPlayer
        var isPresented: Binding<Bool>
        
        init(_ parent: FullScreenVideoPlayer, presented: Binding<Bool>) {
            self.parent = parent
            self.isPresented = presented
        }
        
        func present(_ playerViewController: AVPlayerViewController, in viewController: UIViewController) {
            guard viewController.presentedViewController == nil else { return }
            viewController.present(playerViewController, animated: true) {
                self.isPresented.wrappedValue = false
                playerViewController.player?.play()
            }
        }
    }
}


/*
import SwiftUI
import AVKit

struct FullScreenVideoPlayer: UIViewControllerRepresentable {
    var videoURL: URL
    var presented: Binding<Bool>

    func makeCoordinator() -> Coordinator {
        Coordinator(self, presented: presented)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController() // Placeholder
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if presented.wrappedValue {
            let playerViewController = AVPlayerViewController()
            playerViewController.player = AVPlayer(url: videoURL)
            context.coordinator.present(playerViewController, in: uiViewController)
        }
    }

    class Coordinator: NSObject {
        var parent: FullScreenVideoPlayer
        var isPresented: Binding<Bool>

        init(_ parent: FullScreenVideoPlayer, presented: Binding<Bool>) {
            self.parent = parent
            self.isPresented = presented
        }

        func present(_ playerViewController: AVPlayerViewController, in viewController: UIViewController) {
            guard viewController.presentedViewController == nil else { return }
            viewController.present(playerViewController, animated: true) {
                self.isPresented.wrappedValue = false
                playerViewController.player?.play()
            }
        }
    }
}
*/
