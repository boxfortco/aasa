//
//  SpotlightView.swift
//  BoxFort
//
//  Created by Matthew Ryan on 4/11/25.
//

import SwiftUI
import FirebaseAnalytics

struct SpotlightView: View {
    let selectedChildId: String?
    @State private var selectedBook: Book?
    @State private var currentIndex = 0
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private let spotlightBooks: [Book] = [
        BookSection.sampleBooks.first(where: { $0.id == "measuringup" })!,
        BookSection.sampleBooks.first(where: { $0.id == "costumeparty" })!,
        BookSection.sampleBooks.first(where: { $0.id == "bubblegum" })!,
        BookSection.sampleBooks.first(where: { $0.id == "theexpert" })!,
        BookSection.sampleBooks.first(where: { $0.id == "surprise" })!,
        BookSection.sampleBooks.first(where: { $0.id == "fireworks" })!
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Spotlight")
                .font(Font.custom("LondrinaSolid-Light", size: 32))
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.bottom, 16)
            
            GeometryReader { geometry in
                Button(action: {
                    self.selectedBook = spotlightBooks[currentIndex]
                    // Track spotlight book selection
                    Analytics.logEvent("spotlight_book_selected", parameters: [
                        "book_id": spotlightBooks[currentIndex].id,
                        "book_title": spotlightBooks[currentIndex].title,
                        "is_free": spotlightBooks[currentIndex].free,
                        "source": "spotlight_carousel"
                    ])
                }) {
                    if horizontalSizeClass == .regular {
                        // iPad layout - side by side
                        HStack(spacing: 0) {
                            Image(spotlightBooks[currentIndex].pages[0])
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: geometry.size.width * 0.4, height: 400)
                                .clipped()
                                .cornerRadius(15, corners: [.topLeft, .bottomLeft])
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text(spotlightBooks[currentIndex].title)
                                    .font(Font.custom("LondrinaSolid-Regular", size: 32))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                
                                Text(spotlightBooks[currentIndex].details)
                                    .font(Font.custom("LondrinaSolid-Light", size: 20))
                                    .foregroundColor(.white)
                                    .lineLimit(4)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                                HStack {
                                    Spacer()
                                    Image(systemName: "chevron.right.circle.fill")
                                        .resizable()
                                        .frame(width: 36, height: 36)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 32)
                            .frame(width: geometry.size.width * 0.6, height: 400, alignment: .leading)
                        }
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(15)
                    } else {
                        // iPhone layout - stacked
                        ZStack(alignment: .bottom) {
                            Image(spotlightBooks[currentIndex].pages[0])
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width - 32, height: 300)
                                .clipped()
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(spotlightBooks[currentIndex].title)
                                    .font(Font.custom("LondrinaSolid-Regular", size: 24))
                                    .foregroundColor(.white)
                                
                                Text(spotlightBooks[currentIndex].details)
                                    .font(Font.custom("LondrinaSolid-Light", size: 16))
                                    .foregroundColor(.white)
                                    .lineLimit(2)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.black.opacity(0.7))
                        }
                        .cornerRadius(15)
                    }
                }
                .frame(width: geometry.size.width - 32)
                .frame(maxWidth: .infinity)
            }
            .frame(height: horizontalSizeClass == .regular ? 400 : 300)
            .padding(.horizontal)
            .onAppear {
                // Start cycling through spotlight books
                Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                    withAnimation {
                        currentIndex = (currentIndex + 1) % spotlightBooks.count
                    }
                }
            }
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
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners,
                              cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct SpotlightView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            GradientBackgroundView()
            SpotlightView(selectedChildId: nil)
        }
    }
} 
