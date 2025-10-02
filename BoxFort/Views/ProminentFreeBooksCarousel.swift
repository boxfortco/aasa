import SwiftUI
import FirebaseAnalytics

struct ProminentFreeBooksCarousel: View {
    @State private var selectedBook: Book?
    @State private var currentIndex = 0
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let selectedChildId: String?
    
    private let freeBooks = BookSection.freeBooks.books
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Welcome to BoxFort!")
                    .font(Font.custom("LondrinaSolid-Regular", size: 36))
                    .foregroundColor(.white)
                
                Text("Choose from these delightful free stories")
                    .font(Font.custom("LondrinaSolid-Light", size: 20))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 20)
            
            // Carousel
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(Array(freeBooks.enumerated()), id: \.element.id) { index, book in
                        ProminentBookCard(
                            book: book,
                            isSelected: false // Remove selection scaling to prevent size differences
                        ) {
                            selectedBook = book
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
        }
        .padding(.vertical, 32)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.4),
                    Color.black.opacity(0.2)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(20)
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
        .onAppear {
            Analytics.logEvent("prominent_free_books_shown", parameters: [
                "free_books_count": freeBooks.count
            ])
        }
    }
}

struct ProminentBookCard: View {
    let book: Book
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            onTap()
            // Track prominent book selection
            Analytics.logEvent("prominent_book_selected", parameters: [
                "book_id": book.id,
                "book_title": book.title,
                "is_free": book.free,
                "source": "prominent_carousel"
            ])
        }) {
            VStack(spacing: 8) {
                // Book cover without white blur effect
                ZStack {
                    Image(book.posterImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 160, height: 224)
                        .clipped()
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.3), 
                               radius: 8, 
                               x: 0, 
                               y: 4)
                    
                    // Free badge
                    VStack {
                        HStack {
                            Spacer()
                            Text("FREE")
                                .font(Font.custom("LondrinaSolid-Regular", size: 14))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green)
                                .cornerRadius(8)
                        }
                        Spacer()
                    }
                    .padding(8)
                }
                
                // Book title
                Text(book.title)
                    .font(Font.custom("LondrinaSolid-Regular", size: 16))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 40) // Fixed height to prevent layout shifts
                
                // Read button with proper containment
                HStack(spacing: 4) {
                    Text("Read Now")
                        .font(Font.custom("LondrinaSolid-Light", size: 14))
                        .foregroundColor(.white)
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.white.opacity(0.2))
                .cornerRadius(20)
                .frame(maxWidth: .infinity) // Ensure button doesn't overflow
            }
            .frame(width: 160, height: 320) // Fixed height to prevent overflow
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSelected)
    }
}

struct ProminentFreeBooksCarousel_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            GradientBackgroundView()
            ProminentFreeBooksCarousel(selectedChildId: nil)
        }
    }
} 