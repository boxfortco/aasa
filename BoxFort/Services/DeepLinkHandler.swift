import Foundation
import SwiftUI

class DeepLinkHandler: ObservableObject {
    static let shared = DeepLinkHandler()
    
    @Published var pendingBookId: String?
    @Published var shouldNavigateToBook = false
    @Published var pendingSearchQuery: String?
    @Published var shouldNavigateToSearch = false
    
    private init() {
        setupNotificationObservers()
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            forName: Notification.Name("DeepLinkBook"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let bookId = notification.userInfo?["bookId"] as? String {
                self?.handleBookDeepLink(bookId: bookId)
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: Notification.Name("DeepLinkSearch"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let searchQuery = notification.userInfo?["searchQuery"] as? String {
                self?.handleSearchDeepLink(searchQuery: searchQuery)
            }
        }
    }
    
    func handleBookDeepLink(bookId: String) {
        print("DEBUG: DeepLinkHandler received bookId: '\(bookId)'")
        print("DEBUG: Available books: \(BookSection.sampleBooks.map { $0.id })")
        
        // Find the book in the available books
        let book = BookSection.sampleBooks.first { $0.id == bookId }
        
        if book != nil {
            print("DEBUG: Found book '\(bookId)', setting up navigation")
            pendingBookId = bookId
            shouldNavigateToBook = true
            
            // Reset after a short delay to allow navigation
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.shouldNavigateToBook = false
            }
        } else {
            print("DEBUG: Book with ID '\(bookId)' not found in sampleBooks")
        }
    }
    
    func handleSearchDeepLink(searchQuery: String) {
        print("DEBUG: DeepLinkHandler received searchQuery: '\(searchQuery)'")
        
        pendingSearchQuery = searchQuery
        shouldNavigateToSearch = true
        
        // Reset after a short delay to allow navigation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.shouldNavigateToSearch = false
        }
    }
    
    func getBookFromDeepLink() -> Book? {
        guard let bookId = pendingBookId else { return nil }
        return BookSection.sampleBooks.first { $0.id == bookId }
    }
    
    func getSearchQueryFromDeepLink() -> String? {
        return pendingSearchQuery
    }
    
    func clearPendingBook() {
        pendingBookId = nil
        shouldNavigateToBook = false
    }
    
    func clearPendingSearch() {
        pendingSearchQuery = nil
        shouldNavigateToSearch = false
    }
} 