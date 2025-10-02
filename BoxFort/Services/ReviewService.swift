import Foundation
import StoreKit
import FirebaseAnalytics

class ReviewService: ObservableObject {
    static let shared = ReviewService()
    
    private let reviewTriggerKey = "reviewTriggerCount"
    private let lastReviewRequestKey = "lastReviewRequestDate"
    private let booksCompletedForReviewKey = "booksCompletedForReview"
    
    private init() {}
    
    /// Check if we should show the review prompt after a book completion
    func checkForReviewPrompt(afterBookCompletion bookId: String) {
        // Get current completion count
        let completedBooks = getCompletedBooksForReview()
        let newCompletedBooks = completedBooks.union([bookId])
        
        // Save updated completion list
        saveCompletedBooksForReview(newCompletedBooks)
        
        // Check if we should show review prompt (after 3 unique book completions)
        if newCompletedBooks.count >= 3 && shouldShowReviewPrompt() {
            requestReview()
        }
    }
    
    /// Request App Store review
    private func requestReview() {
        // Check if enough time has passed since last request
        guard shouldShowReviewPrompt() else {
            print("ReviewService: Not enough time has passed since last review request")
            return
        }
        
        // Request the review
        SKStoreReviewController.requestReview()
        
        // Update tracking
        updateReviewRequestTracking()
        
        // Log analytics
        Analytics.logEvent("review_prompt_shown", parameters: [
            "completed_books_count": getCompletedBooksForReview().count,
            "total_completed_books": getCompletedBooksForReview().joined(separator: ",")
        ])
        
        print("ReviewService: Review prompt requested")
    }
    
    /// Check if we should show the review prompt based on timing
    private func shouldShowReviewPrompt() -> Bool {
        let lastRequest = UserDefaults.standard.object(forKey: lastReviewRequestKey) as? Date
        
        // If never requested before, allow it
        guard let lastRequest = lastRequest else {
            return true
        }
        
        // Check if at least 30 days have passed since last request
        let calendar = Calendar.current
        let daysSinceLastRequest = calendar.dateComponents([.day], from: lastRequest, to: Date()).day ?? 0
        
        return daysSinceLastRequest >= 30
    }
    
    /// Update tracking after review request
    private func updateReviewRequestTracking() {
        UserDefaults.standard.set(Date(), forKey: lastReviewRequestKey)
        
        // Increment trigger count
        let currentCount = UserDefaults.standard.integer(forKey: reviewTriggerKey)
        UserDefaults.standard.set(currentCount + 1, forKey: reviewTriggerKey)
    }
    
    /// Get completed books for review tracking
    private func getCompletedBooksForReview() -> Set<String> {
        let bookIds = UserDefaults.standard.stringArray(forKey: booksCompletedForReviewKey) ?? []
        return Set(bookIds)
    }
    
    /// Save completed books for review tracking
    private func saveCompletedBooksForReview(_ books: Set<String>) {
        UserDefaults.standard.set(Array(books), forKey: booksCompletedForReviewKey)
    }
    
    /// Reset review tracking (useful for testing)
    func resetReviewTracking() {
        UserDefaults.standard.removeObject(forKey: reviewTriggerKey)
        UserDefaults.standard.removeObject(forKey: lastReviewRequestKey)
        UserDefaults.standard.removeObject(forKey: booksCompletedForReviewKey)
        UserDefaults.standard.removeObject(forKey: "hasAwardedPointsForReview")
        print("ReviewService: Review tracking reset")
    }
    
    /// Test method to simulate book completions (for debugging)
    func simulateBookCompletion(bookId: String) {
        print("ReviewService: Simulating completion of book: \(bookId)")
        checkForReviewPrompt(afterBookCompletion: bookId)
    }
    
    /// Get current review statistics
    func getReviewStats() -> (completedBooks: Int, lastRequestDate: Date?, triggerCount: Int) {
        let completedBooks = getCompletedBooksForReview().count
        let lastRequestDate = UserDefaults.standard.object(forKey: lastReviewRequestKey) as? Date
        let triggerCount = UserDefaults.standard.integer(forKey: reviewTriggerKey)
        
        return (completedBooks, lastRequestDate, triggerCount)
    }
    
    /// Check if user has recently submitted a review and award points
    func checkForReviewSubmission(userId: String?) {
        // This is a simplified approach - in a real app, you might want to:
        // 1. Check app store review status through your backend
        // 2. Use a more sophisticated detection method
        // 3. Implement a server-side verification system
        
        // For now, we'll award points when the app becomes active after a review request
        // This is not perfect but provides a reasonable approximation
        
        let lastRequest = UserDefaults.standard.object(forKey: lastReviewRequestKey) as? Date
        let hasAwardedPointsKey = "hasAwardedPointsForReview"
        let hasAwardedPoints = UserDefaults.standard.bool(forKey: hasAwardedPointsKey)
        
        // If we recently requested a review and haven't awarded points yet
        if let lastRequest = lastRequest, !hasAwardedPoints {
            let timeSinceRequest = Date().timeIntervalSince(lastRequest)
            
            // If it's been more than 5 minutes since the review request, assume they might have reviewed
            if timeSinceRequest > 300 { // 5 minutes
                awardReviewPoints(userId: userId)
                UserDefaults.standard.set(true, forKey: hasAwardedPointsKey)
            }
        }
    }
    
    /// Award loyalty points for review submission
    private func awardReviewPoints(userId: String?) {
        guard let userId = userId else {
            print("ReviewService: Cannot award points - no user ID")
            return
        }
        
        Task {
            do {
                try await LoyaltyService.shared.awardPointsForReview(userId: userId)
                print("ReviewService: Awarded loyalty points for review submission")
            } catch {
                print("ReviewService: Failed to award loyalty points: \(error.localizedDescription)")
            }
        }
    }
} 