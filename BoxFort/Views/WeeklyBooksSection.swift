import SwiftUI
import FirebaseAnalytics

struct WeeklyBooksSection: View {
    @StateObject private var weeklyService = WeeklyBookService.shared
    @State private var selectedBook: Book?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let selectedChildId: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with countdown
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weekly Delivery")
                        .font(Font.custom("LondrinaSolid-Light", size: 32))
                        .foregroundColor(.white)
                    
                    if weeklyService.isCountdownActive {
                        Text("Next delivery in \(weeklyService.countdownTime)")
                            .font(Font.custom("LondrinaSolid-Light", size: 18))
                            .foregroundColor(.white.opacity(0.8))
                    } else {
                        Text("New books available!")
                            .font(Font.custom("LondrinaSolid-Light", size: 18))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                // Countdown indicator
                if weeklyService.isCountdownActive {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .opacity(0.8)
                }
            }
            .padding(.horizontal, 32)
            
            // Books carousel
            if weeklyService.isLoading {
                HStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                    Text("Loading new books...")
                        .font(Font.custom("LondrinaSolid-Light", size: 18))
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else if weeklyService.weeklyBooks.isEmpty {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("No new books this week")
                        .font(Font.custom("LondrinaSolid-Light", size: 20))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    if let error = weeklyService.error {
                        Text(error)
                            .font(Font.custom("LondrinaSolid-Light", size: 16))
                            .foregroundColor(.red.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                // Books grid
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(weeklyService.weeklyBooks) { book in
                            WeeklyBookCard(book: book) {
                                selectedBook = book
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                }
            }
        }
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    ColorConstants.ctaColor,
                    ColorConstants.ctaColor.opacity(0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 20)
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

struct WeeklyBookCard: View {
    let book: Book
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            onTap()
            // Track weekly book selection
            Analytics.logEvent("weekly_book_selected", parameters: [
                "book_id": book.id,
                "book_title": book.title,
                "is_free": book.free,
                "source": "weekly_delivery"
            ])
        }) {
            VStack(spacing: 12) {
                // Book cover
                ZStack {
                    Image(book.posterImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
                    
                    // New book indicator
                    VStack {
                        HStack {
                            Spacer()
                            Text("NEW")
                                .font(Font.custom("LondrinaSolid-Regular", size: 12))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.red)
                                .cornerRadius(8)
                        }
                        Spacer()
                    }
                    .padding(8)
                }
                
                // Book title
                Text(book.title)
                    .font(Font.custom("LondrinaSolid-Regular", size: 18))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(width: 150)
                
                // Characters
                if !book.characters.isEmpty {
                    Text("Featuring \(book.characters.joined(separator: ", "))")
                        .font(Font.custom("LondrinaSolid-Light", size: 14))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .frame(width: 150)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct WeeklyBooksSection_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            WeeklyBooksSection(selectedChildId: nil)
        }
    }
} 