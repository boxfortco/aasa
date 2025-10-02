//
//  NetflixStyleHeroSection.swift
//  BoxFort
//
//  Created by Matthew Ryan on 4/11/25.
//

import SwiftUI
import FirebaseAnalytics

struct NetflixStyleHeroSection: View {
    let selectedChildId: String?
    @Binding var selectedBook: Book?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var showDetails = false
    @State private var showProfileView = false
    @State private var isFavorited = false
    @State private var showParticles = false
    @State private var particleScale: CGFloat = 0
    
    // MARK: - Dynamic Layout Properties
    private var isPad: Bool { horizontalSizeClass == .regular }
    private var heroHeight: CGFloat { isPad ? 500 : 350 }
    private var titleFontSize: CGFloat { isPad ? 48 : 32 }
    private var descriptionFontSize: CGFloat { isPad ? 20 : 16 }
    private var buttonFontSize: CGFloat { isPad ? 18 : 16 }
    private var badgeFontSize: CGFloat { isPad ? 16 : 14 }
    
    // Featured book configuration
    private let featuredBook = BookSection.sampleBooks.first { $0.id == "sheepover" }
    private let badgeLabel = "NEW RELEASE"
    
    private var selectedChild: ChildProfile? {
        guard let user = userViewModel.user else { return nil }
        if let childId = selectedChildId {
            return user.children.first(where: { $0.id == childId })
        }
        return user.children.first
    }
    
    private func updateFavoriteStatus() {
        if let child = selectedChild, let book = featuredBook {
            isFavorited = child.favorites.contains(book.id)
        } else {
            isFavorited = false
        }
    }
    
    private func toggleFavorite() {
        guard let book = featuredBook else { return }
        
        if let childId = selectedChildId ?? selectedChild?.id {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isFavorited.toggle()
                showParticles = true
                particleScale = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.2)) {
                    particleScale = 0
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showParticles = false
            }
            userViewModel.toggleFavorite(bookId: book.id, for: childId)
            updateFavoriteStatus()
            
            Analytics.logEvent("hero_book_favorite_toggled", parameters: [
                "book_id": book.id,
                "book_title": book.title,
                "is_favorited": isFavorited,
                "child_id": childId,
                "source": "netflix_hero"
            ])
        }
    }
    
    var body: some View {
        Group {
            if let book = featuredBook {
                ZStack(alignment: .bottomLeading) {
                    // Background Image
                    GeometryReader { geometry in
                        Image(book.posterImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                            .overlay(
                                // Dark gradient overlay for text readability
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.clear,
                                        Color.black.opacity(0.3),
                                        Color.black.opacity(0.7)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                    .frame(height: heroHeight)
                    .clipped()
                    
                    // Content Overlay
                    VStack(alignment: .leading, spacing: 16) {
                        // Badge
                        HStack {
                            Text(badgeLabel)
                                .font(Font.custom("LondrinaSolid-Regular", size: badgeFontSize))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.red)
                                .cornerRadius(12)
                            
                            Spacer()
                        }
                        
                        // Title
                        Text(book.title.uppercased())
                            .font(Font.custom("LondrinaSolid-Regular", size: titleFontSize))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .shadow(color: .black.opacity(0.8), radius: 4, x: 0, y: 2)
                        
                        // Description
                        Text(book.details)
                            .font(Font.custom("LondrinaSolid-Light", size: descriptionFontSize))
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                            .shadow(color: .black.opacity(0.8), radius: 2, x: 0, y: 1)
                        
                        // Action Buttons
                        HStack(spacing: 16) {
                            // Play Button
                            Button(action: {
                                selectedBook = book
                                trackHeroBookSelection(book: book, action: "play")
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "play.fill")
                                        .font(.system(size: buttonFontSize))
                                    Text("Read Now")
                                        .font(Font.custom("LondrinaSolid-Light", size: buttonFontSize))
                                }
                                .foregroundColor(.black)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 24)
                                .background(Color.white)
                                .cornerRadius(8)
                            }
                            
                            // Favorite Button
                            ZStack {
                                Button(action: {
                                    if userViewModel.user != nil {
                                        toggleFavorite()
                                    } else {
                                        showProfileView = true
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: isFavorited ? "heart.fill" : "heart")
                                            .font(.system(size: buttonFontSize))
                                        Text(userViewModel.user == nil ? "Sign in to favorite" : "Favorite")
                                            .font(Font.custom("LondrinaSolid-Light", size: buttonFontSize))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 24)
                                    .background(Color.gray.opacity(0.6))
                                    .cornerRadius(8)
                                }
                                
                                // Particle effect
                                if showParticles {
                                    ForEach(0..<8, id: \.self) { index in
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 4, height: 4)
                                            .scaleEffect(particleScale)
                                            .offset(
                                                x: CGFloat.random(in: -30...30),
                                                y: CGFloat.random(in: -30...30)
                                            )
                                            .opacity(particleScale)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
                .frame(height: heroHeight)
                .cornerRadius(0) // Full width, no corner radius
                .clipped()
            }
        }
        .onAppear {
            updateFavoriteStatus()
        }
        .onChange(of: selectedChildId) { _ in
            updateFavoriteStatus()
        }
        .sheet(isPresented: $showProfileView) {
            ProfileView()
        }
        .sheet(item: horizontalSizeClass == .compact ? $selectedBook : .constant(nil)) { book in
            BookDetailView(book: book,
                         dismissToRoot: {
                             selectedBook = nil
                         },
                         selectedChildId: selectedChildId)
        }
        .fullScreenCover(item: horizontalSizeClass == .regular ? $selectedBook : .constant(nil)) { book in
            BookDetailView(book: book,
                         dismissToRoot: {
                             selectedBook = nil
                         },
                         selectedChildId: selectedChildId)
        }
    }
    
    private func trackHeroBookSelection(book: Book, action: String) {
        Analytics.logEvent("netflix_hero_book_selected", parameters: [
            "book_id": book.id,
            "book_title": book.title,
            "is_free": book.free,
            "action": action,
            "source": "netflix_hero"
        ])
    }
}


struct NetflixStyleHeroSection_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            NetflixStyleHeroSection(selectedChildId: nil, selectedBook: .constant(nil))
        }
    }
}
