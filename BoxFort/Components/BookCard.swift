import SwiftUI
import FirebaseAnalytics

struct BookCard: View {
    let book: Book
    @Binding var selectedBook: Book?
    @EnvironmentObject var userViewModel: UserViewModel
    let selectedChildId: String?
    
    private var selectedChild: ChildProfile? {
        // If no user, return nil
        guard let user = userViewModel.user else { 
            print("DEBUG: No user found")
            return nil 
        }
        
        // Use the provided selectedChildId
        if let childId = selectedChildId,
           let child = user.children.first(where: { $0.id == childId }) {
            print("DEBUG: Using selected child: \(child.name)")
            return child
        }
        
        // Fallback to first child if no selection
        if let firstChild = user.children.first {
            print("DEBUG: No child selected, falling back to first child: \(firstChild.name)")
            return firstChild
        }
        
        print("DEBUG: No children found")
        return nil
    }
    
    private var isFavorite: Bool {
        guard let child = selectedChild else { return false }
        print("DEBUG: Checking favorite status for book \(book.id) for child \(child.name)")
        return child.favorites.contains(book.id)
    }
    
    var body: some View {
        Button(action: { 
            selectedBook = book
            // Track book selection
            let parameters: [String: Any] = [
                "book_id": book.id,
                "book_title": book.title,
                "is_free": book.free,
                "is_subscribed": userViewModel.isSubscriptionActive,
                "is_purchased": userViewModel.purchasedBooks.contains(book.id),
                "is_favorite": isFavorite,
                "source": "book_card"
            ]
            Analytics.logEvent("book_selected", parameters: parameters)
            print("📊 Book Analytics: Book selected - \(book.title)")
            print("📊 Book Analytics: Parameters: \(parameters)")
        }) {
            VStack(alignment: .leading, spacing: 8) {
                // Container with fixed height for the image
                VStack {
                    Image(book.posterImage)
                        .resizable()
                        .aspectRatio(2/3, contentMode: .fit)
                        .frame(width: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                .frame(height: 240) // Fixed height container
                .frame(maxHeight: .infinity, alignment: .top) // Align to top
                
                Text(book.title)
                    .font(Font.custom("LondrinaSolid-Regular", size: 18))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .frame(width: 160, alignment: .leading)
            }
        }
    }
    
    private func toggleFavorite(for child: ChildProfile) {
        userViewModel.toggleFavorite(bookId: book.id, for: child.id)
    }
} 