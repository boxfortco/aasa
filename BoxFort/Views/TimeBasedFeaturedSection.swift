import SwiftUI
import FirebaseAnalytics

struct TimeBasedFeaturedSection: View {
    let selectedChildId: String?
    @Binding var selectedBook: Book?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    // MARK: - Dynamic Layout Properties
    private var isPad: Bool { horizontalSizeClass == .regular }
    private var bookCoverWidth: CGFloat { isPad ? 160 : 120 }
    private var bookCoverHeight: CGFloat { isPad ? 224 : 168 }
    private var titleFontSize: CGFloat { isPad ? 28 : 24 }
    private var descriptionFontSize: CGFloat { isPad ? 18 : 16 }
    private var buttonFontSize: CGFloat { isPad ? 20 : 18 }
    private var badgeFontSize: CGFloat { isPad ? 14 : 12 }
    
    // Time-based featured book configuration
    private let featuredBook = BookSection.sampleBooks.first { $0.id == "sheepover" }
    private let badgeLabel = "NEW RELEASE"
    // For testing: set dates to show the section now
    private let startDate = Calendar.current.date(from: DateComponents(year: 2024, month: 1, day: 1)) ?? Date()
    private let endDate = Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 31)) ?? Date()
    
    private var isActive: Bool {
        let now = Date()
        return now >= startDate && now <= endDate
    }
    
    var body: some View {
        Group {
            if isActive, let book = featuredBook {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 16) {
                        // Book cover
                        ZStack {
                            Image(book.posterImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: bookCoverWidth, height: bookCoverHeight)
                                .clipped()
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                            
                            // Badge
                            VStack {
                                HStack {
                                    Spacer()
                                    Text(badgeLabel)
                                        .font(Font.custom("LondrinaSolid-Regular", size: badgeFontSize))
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
                        
                        // Book details
                        VStack(alignment: .leading, spacing: 8) {
                            Text(book.title)
                                .font(Font.custom("LondrinaSolid-Regular", size: titleFontSize))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                            
                            Text(book.details)
                                .font(Font.custom("LondrinaSolid-Light", size: descriptionFontSize))
                                .foregroundColor(.white.opacity(0.9))
                                .lineLimit(isPad ? 6 : 4)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                            // Read button
                            Button(action: {
                                selectedBook = book
                                // Track time-based featured book selection
                                Analytics.logEvent("time_based_featured_book_selected", parameters: [
                                    "book_id": book.id,
                                    "book_title": book.title,
                                    "is_free": book.free,
                                    "source": "time_based_featured"
                                ])
                            }) {
                                HStack(spacing: 8) {
                                    Text("Read Now")
                                        .font(Font.custom("LondrinaSolid-Light", size: buttonFontSize))
                                        .foregroundColor(.white)
                                    
                                    Image(systemName: "arrow.right.circle.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: buttonFontSize))
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 20)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(25)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(20)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.6),
                            Color.black.opacity(0.4)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.3), lineWidth: 3)
            )
            .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 6)
                .padding(.horizontal, 20)
                .padding(.top, 16)
            } else {
                // Empty view when not active
                EmptyView()
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

struct TimeBasedFeaturedSection_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            GradientBackgroundView()
            TimeBasedFeaturedSection(selectedChildId: nil, selectedBook: .constant(nil))
        }
    }
}
