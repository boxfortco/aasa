//
//  TrendingBooksView.swift
//  BoxFort
//
//  Created by Matthew Ryan on 1/15/25.
//

import SwiftUI

struct TrendingBooksView: View {
    @StateObject private var trendingService = TrendingBooksService.shared
    @Binding var selectedBook: Book?
    let selectedChildId: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Top 10 This Week")
                    .font(Font.custom("LondrinaSolid-Light", size: 32))
                    .foregroundColor(.white)
                
                Spacer()
                
                if trendingService.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
            }
            .padding(.horizontal, 20)
            
            // Trending Books Grid
            trendingBooksGrid
        }
        .onAppear {
            Task {
                await trendingService.fetchTrendingBooks()
                trendingService.trackTrendingSectionViewed()
            }
        }
    }
    
    private var trendingBooksGrid: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(Array(trendingService.trendingBooks.enumerated()), id: \.element.id) { index, trendingBook in
                    TrendingBookCard(
                        trendingBook: trendingBook,
                        rank: index + 1,
                        selectedBook: $selectedBook,
                        selectedChildId: selectedChildId
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
}

struct TrendingBookCard: View {
    let trendingBook: TrendingBook
    let rank: Int
    @Binding var selectedBook: Book?
    let selectedChildId: String?
    
    var body: some View {
        Button(action: {
            // Find the actual Book object and set it as selected
            if let book = BookSection.sampleBooks.first(where: { $0.id == trendingBook.bookId }) {
                selectedBook = book
                TrendingBooksService.shared.trackTrendingBookSelected(trendingBook, source: "trending_section")
            }
        }) {
            ZStack {
                // Book cover
                Image(trendingBook.posterImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 200)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                
                // Rank number overlay (Netflix style)
                VStack {
                    HStack {
                        Spacer()
                        Text("\(rank)")
                            .font(Font.custom("LondrinaSolid-Regular", size: 48))
                            .foregroundColor(.white.opacity(0.8))
                            .shadow(color: .black.opacity(0.7), radius: 4, x: 2, y: 2)
                    }
                    Spacer()
                }
                .padding(12)
                
                // Hot badge for 1000+ reads
                if trendingBook.isHot {
                    VStack {
                        HStack {
                            Spacer()
                            hotBadge
                        }
                        Spacer()
                    }
                    .padding(12)
                }
                
                // Title overlay at bottom
                VStack {
                    Spacer()
                    HStack {
                        Text(trendingBook.title)
                            .font(Font.custom("LondrinaSolid-Light", size: 14))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.8), radius: 2, x: 1, y: 1)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                }
                .padding(12)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var hotBadge: some View {
        VStack(spacing: 4) {
            Text("🔥")
                .font(.system(size: 20))
            
            Text("Over 1,000 reads this week")
                .font(Font.custom("LondrinaSolid-Light", size: 10))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 80)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.orange.opacity(0.9))
        )
        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Preview

struct TrendingBooksView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            TrendingBooksView(
                selectedBook: .constant(nil),
                selectedChildId: nil
            )
        }
    }
}

struct TrendingBookCard_Previews: PreviewProvider {
    static var previews: some View {
        let sampleTrendingBook = TrendingBook(
            bookId: "sample-book",
            title: "Sample Story",
            posterImage: "PatrickTakesOff",
            readCount: 1200,
            rank: 1
        )
        
        ZStack {
            Color.black.ignoresSafeArea()
            
            TrendingBookCard(
                trendingBook: sampleTrendingBook,
                rank: 1,
                selectedBook: .constant(nil),
                selectedChildId: nil
            )
        }
    }
}
