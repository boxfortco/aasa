//
//  ReadingBuddyView.swift
//  BoxFort
//
//  Created by Matthew Ryan on 9/15/25.
//

import SwiftUI

struct ReadingBuddyView: View {
    let currentPage: Int
    let totalPages: Int
    let bookTitle: String
    let characterName: String
    
    @State private var progressAnimation: Double = 0
    
    private var progress: Double {
        guard totalPages > 0 else { return 0 }
        return Double(currentPage) / Double(totalPages)
    }
    
    var body: some View {
        HStack(spacing: 8) {
            // Character peek - Patrick GIF (fallback to system image if not found)
            let imageName = "\(characterName)_peek"
            if let _ = NSDataAsset(name: imageName) {
                SwiftyGifView(imageName: imageName)
                    .frame(width: 40, height: 40)
            } else {
                // Fallback to system image
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.purple)
                    .frame(width: 40, height: 40)
            }
            
            // Progress bar - compact
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)
                    
                    // Progress fill
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.purple)
                        .frame(width: geometry.size.width * progressAnimation, height: 4)
                        .animation(.easeInOut(duration: 0.5), value: progressAnimation)
                }
            }
            .frame(height: 4)
            
            // Page counter - tiny
            Text("\(currentPage)/\(totalPages)")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: "#999999"))
                .frame(width: 35)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: "#242424"))
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
        )
        .frame(height: 60)
        .onAppear {
            startAnimations()
        }
        .onChange(of: currentPage) { _ in
            updateProgress()
        }
    }
    
    private func startAnimations() {
        // Animate progress bar
        withAnimation(.easeInOut(duration: 0.8)) {
            progressAnimation = progress
        }
    }
    
    private func updateProgress() {
        withAnimation(.easeInOut(duration: 0.5)) {
            progressAnimation = progress
        }
    }
}

#Preview {
    ReadingBuddyView(
        currentPage: 5,
        totalPages: 20,
        bookTitle: "Patrick's Big Adventure",
        characterName: "patrick"
    )
    .padding()
    .background(Color.white)
}
