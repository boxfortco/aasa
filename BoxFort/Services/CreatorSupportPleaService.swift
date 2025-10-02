//
//  CreatorSupportPleaService.swift
//  BoxFort
//
//  Created by Matthew Ryan on 1/15/25.
//

import Foundation
import FirebaseAnalytics

class CreatorSupportPleaService: ObservableObject {
    static let shared = CreatorSupportPleaService()
    
    private let dismissedPermanentlyKey = "creator_plea_dismissed_permanently"
    private let firstShownDateKey = "creator_plea_first_shown_date"
    private let lastShownDateKey = "creator_plea_last_shown_date"
    private let showCountKey = "creator_plea_show_count"
    
    @Published var shouldShowPlea = false
    
    private init() {
        checkShouldShowPlea()
    }
    
    // MARK: - Public Methods
    
    func checkShouldShowPlea() {
        // Don't show if permanently dismissed
        if UserDefaults.standard.bool(forKey: dismissedPermanentlyKey) {
            shouldShowPlea = false
            return
        }
        
        // Check engagement criteria
        let meetsEngagementCriteria = checkEngagementCriteria()
        
        // Check timing criteria (don't show too frequently)
        let meetsTimingCriteria = checkTimingCriteria()
        
        shouldShowPlea = meetsEngagementCriteria && meetsTimingCriteria
        
        if shouldShowPlea {
            trackPleaEligibility()
        }
    }
    
    func markPleaDismissedPermanently() {
        UserDefaults.standard.set(true, forKey: dismissedPermanentlyKey)
        shouldShowPlea = false
        
        Analytics.logEvent("creator_support_plea_dismissed_permanently", parameters: [
            "timestamp": Date().timeIntervalSince1970
        ])
    }
    
    func markPleaShown() {
        let now = Date()
        UserDefaults.standard.set(now, forKey: lastShownDateKey)
        
        // Set first shown date if this is the first time
        if UserDefaults.standard.object(forKey: firstShownDateKey) == nil {
            UserDefaults.standard.set(now, forKey: firstShownDateKey)
        }
        
        // Increment show count
        let currentCount = UserDefaults.standard.integer(forKey: showCountKey)
        UserDefaults.standard.set(currentCount + 1, forKey: showCountKey)
    }
    
    // MARK: - Private Methods
    
    private func checkEngagementCriteria() -> Bool {
        let completionService = BookCompletionService.shared
        
        // Must have completed at least 3 books
        let hasCompleted3Books = completionService.completedBooks.count >= 3
        
        // Must have been using the app for at least 7 days
        let hasBeenActive7Days = checkDaysSinceFirstUse() >= 7
        
        // Must have favorited at least 2 books (if we have that data)
        let hasFavoritedBooks = checkHasFavoritedBooks()
        
        // Must have a reading streak of at least 3 days (if we have that data)
        let hasReadingStreak = checkHasReadingStreak()
        
        return hasCompleted3Books && hasBeenActive7Days && (hasFavoritedBooks || hasReadingStreak)
    }
    
    private func checkTimingCriteria() -> Bool {
        // Don't show more than once per week
        if let lastShown = UserDefaults.standard.object(forKey: lastShownDateKey) as? Date {
            let daysSinceLastShown = Calendar.current.dateComponents([.day], from: lastShown, to: Date()).day ?? 0
            return daysSinceLastShown >= 7
        }
        
        // If never shown before, it's okay to show
        return true
    }
    
    private func checkDaysSinceFirstUse() -> Int {
        // Try to get from UserDefaults first
        if let firstUseDate = UserDefaults.standard.object(forKey: "app_first_use_date") as? Date {
            return Calendar.current.dateComponents([.day], from: firstUseDate, to: Date()).day ?? 0
        }
        
        // Fallback: check if user has completed any books (indicates they've been using the app)
        let completionService = BookCompletionService.shared
        if completionService.hasCompletedAnyBook {
            // Estimate based on completion count (rough approximation)
            return max(7, completionService.completedBooks.count * 2)
        }
        
        return 0
    }
    
    private func checkHasFavoritedBooks() -> Bool {
        // This would need to be implemented based on your favorites system
        // For now, return true if user has completed books (they're engaged)
        return BookCompletionService.shared.completedBooks.count >= 2
    }
    
    private func checkHasReadingStreak() -> Bool {
        // This would need to be implemented based on your reading streak system
        // For now, return true if user has completed multiple books (indicates regular usage)
        return BookCompletionService.shared.completedBooks.count >= 3
    }
    
    private func trackPleaEligibility() {
        let completionService = BookCompletionService.shared
        
        Analytics.logEvent("creator_support_plea_eligible", parameters: [
            "completed_books_count": completionService.completedBooks.count,
            "days_since_first_use": checkDaysSinceFirstUse(),
            "has_favorited_books": checkHasFavoritedBooks(),
            "has_reading_streak": checkHasReadingStreak(),
            "timestamp": Date().timeIntervalSince1970
        ])
    }
    
    // MARK: - Reset Methods (for testing)
    
    func resetPleaState() {
        UserDefaults.standard.removeObject(forKey: dismissedPermanentlyKey)
        UserDefaults.standard.removeObject(forKey: firstShownDateKey)
        UserDefaults.standard.removeObject(forKey: lastShownDateKey)
        UserDefaults.standard.removeObject(forKey: showCountKey)
        checkShouldShowPlea()
    }
    
    func forceShowPlea() {
        UserDefaults.standard.removeObject(forKey: dismissedPermanentlyKey)
        UserDefaults.standard.removeObject(forKey: lastShownDateKey)
        shouldShowPlea = true
    }
    
    // MARK: - Debug Helpers
    
    func getDebugInfo() -> [String: Any] {
        let completionService = BookCompletionService.shared
        
        return [
            "shouldShowPlea": shouldShowPlea,
            "completedBooksCount": completionService.completedBooks.count,
            "hasCompletedAnyBook": completionService.hasCompletedAnyBook,
            "daysSinceFirstUse": checkDaysSinceFirstUse(),
            "hasFavoritedBooks": checkHasFavoritedBooks(),
            "hasReadingStreak": checkHasReadingStreak(),
            "isPermanentlyDismissed": UserDefaults.standard.bool(forKey: dismissedPermanentlyKey),
            "lastShownDate": UserDefaults.standard.object(forKey: lastShownDateKey) as? Date ?? "Never",
            "showCount": UserDefaults.standard.integer(forKey: showCountKey)
        ]
    }
    
    func simulateEngagedUser() {
        // Simulate a user who has completed 5 books and been active for 10 days
        UserDefaults.standard.set(Date().addingTimeInterval(-10 * 24 * 60 * 60), forKey: "app_first_use_date")
        
        // Add some fake completed books
        let fakeBookIds = ["book1", "book2", "book3", "book4", "book5"]
        UserDefaults.standard.set(fakeBookIds, forKey: "localCompletedBooks")
        
        // Reset plea state
        resetPleaState()
        
        print("DEBUG: Simulated engaged user - 5 books completed, 10 days active")
    }
}
