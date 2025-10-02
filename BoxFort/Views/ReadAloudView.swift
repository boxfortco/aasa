//
//  ReadAloudView.swift
//  BoxFort
//
//  Created by Matthew Ryan on 4/11/25.
//


import SwiftUI
import AVKit
import FirebaseAnalytics

struct ReadAloudView: View {
    let videoStory: [Book] = Book.videoStory.shuffled()
    @State private var selectedBook: Book?
    @State private var showingVideo = false
    @State private var currentVideoURL: URL?
    @State private var errorMessage: String?
    @State private var showingError = false
    
    var body: some View {
        ZStack {
            GradientBackgroundView()
            
            ScrollView {
                VStack(spacing: 0) {
                    Image("readaloud")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                    
                    Text("Read Aloud Storybooks")
                        .font(Font.custom("LondrinaSolid-Light", size: 38))
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], alignment: .center, spacing: 10) {
                        ForEach(videoStory) { book in
                            Button(action: {
                                self.selectedBook = book
                                // Track read aloud book selection
                                Analytics.logEvent("read_aloud_book_selected", parameters: [
                                    "book_id": book.id,
                                    "book_title": book.title,
                                    "is_free": book.free,
                                    "source": "read_aloud_view"
                                ])
                                if let url = videoURL(from: book.bookUrl) {
                                    self.currentVideoURL = url
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        self.showingVideo = true
                                    }
                                    print("Attempting to play video: \(url.absoluteString)")
                                } else {
                                    self.errorMessage = "Failed to load video URL for book: \(book.bookUrl)"
                                    self.showingError = true
                                    print(self.errorMessage ?? "")
                                }
                            }) {
                                ZStack {
                                    Image(book.posterImage)
                                        .resizable()
                                        .scaledToFit()
                                        .cornerRadius(10)
                                    
                                    Image(systemName: "play.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .ignoresSafeArea(.all, edges: .top)
        }
        .background(
            Group {
                if let url = currentVideoURL {
                    FullScreenVideoPlayer(videoURL: url, presented: $showingVideo)
                }
            }
        )
        .alert(isPresented: $showingError) {
            Alert(title: Text("Error"), message: Text(errorMessage ?? "An unknown error occurred"), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            debugPrintBundleInfo()
        }
    }


    private func videoURL(from videoName: String) -> URL? {
        let videosDirectoryName = "video"
        
        if let videosURL = Bundle.main.url(forResource: videosDirectoryName, withExtension: nil) {
            let fileURL = videosURL.appendingPathComponent(videoName)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                print("Video found at path: \(fileURL.path)")
                return fileURL
            }
        }
        
        if let fileURL = Bundle.main.url(forResource: videoName, withExtension: nil) {
            print("Video found at path: \(fileURL.path)")
            return fileURL
        }
        
        print("Error: Video file \(videoName) not found.")
        debugPrintBundleInfo()
        
        return nil
    }
    
    private func debugPrintBundleInfo() {
        print("Bundle path: \(Bundle.main.bundlePath)")
        let videosDirectoryName = "video"
        if let videosURL = Bundle.main.url(forResource: videosDirectoryName, withExtension: nil) {
            print("Videos folder path: \(videosURL.path)")
            do {
                let videoFiles = try FileManager.default.contentsOfDirectory(atPath: videosURL.path)
                print("Files in videos folder: \(videoFiles)")
            } catch {
                print("Error reading contents of videos folder: \(error)")
            }
        } else {
            print("Videos folder not found in bundle")
        }
    }
}
