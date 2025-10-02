import Foundation
import FirebaseAnalytics
import FirebaseFirestore

class BookAnalyticsService: ObservableObject {
    static let shared = BookAnalyticsService()
    
    private init() {}
    
    // MARK: - Book Performance Tracking
    
    /// Track book view (when user sees book details)
    func trackBookView(
        bookId: String,
        bookTitle: String,
        source: String,
        isFree: Bool,
        totalPages: Int
    ) {
        let parameters: [String: Any] = [
            "book_id": bookId,
            "book_title": bookTitle,
            "source": source,
            "is_free": isFree,
            "total_pages": totalPages
        ]
        
        Analytics.logEvent("book_viewed", parameters: parameters)
        
        // Debug logging
        print("📊 Book Analytics: Book viewed - \(bookTitle) from \(source)")
        print("📊 Book Analytics: Parameters sent: \(parameters)")
    }
    
    /// Track book reading session start
    func trackReadingSessionStart(
        bookId: String,
        bookTitle: String,
        sessionId: String,
        isFree: Bool
    ) {
        let parameters: [String: Any] = [
            "book_id": bookId,
            "book_title": bookTitle,
            "session_id": sessionId,
            "is_free": isFree,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        Analytics.logEvent("book_reading_session_started", parameters: parameters)
        
        print("📊 Book Analytics: Reading session started - \(bookTitle)")
        print("📊 Book Analytics: Session parameters: \(parameters)")
    }
    
    /// Track book reading session end with time spent
    func trackReadingSessionEnd(
        bookId: String,
        bookTitle: String,
        sessionId: String,
        timeSpentSeconds: TimeInterval,
        pagesRead: Int,
        totalPages: Int,
        isCompleted: Bool
    ) {
        Analytics.logEvent("book_reading_session_ended", parameters: [
            "book_id": bookId,
            "book_title": bookTitle,
            "session_id": sessionId,
            "time_spent_seconds": timeSpentSeconds,
            "pages_read": pagesRead,
            "total_pages": totalPages,
            "is_completed": isCompleted,
            "completion_percentage": Double(pagesRead) / Double(totalPages) * 100
        ])
        
        print("📊 Book Analytics: Reading session ended - \(bookTitle) (\(Int(timeSpentSeconds))s)")
    }
    
    /// Track unique reader (first time reading this book)
    func trackUniqueReader(
        bookId: String,
        bookTitle: String,
        userId: String
    ) {
        Analytics.logEvent("book_unique_reader", parameters: [
            "book_id": bookId,
            "book_title": bookTitle,
            "user_id": userId,
            "is_first_time": true
        ])
        
        print("📊 Book Analytics: Unique reader - \(bookTitle)")
    }
    
    /// Track book re-read (user reading book again)
    func trackBookReread(
        bookId: String,
        bookTitle: String,
        userId: String,
        readCount: Int
    ) {
        Analytics.logEvent("book_reread", parameters: [
            "book_id": bookId,
            "book_title": bookTitle,
            "user_id": userId,
            "read_count": readCount
        ])
        
        print("📊 Book Analytics: Book re-read - \(bookTitle) (read \(readCount) times)")
    }
    
    /// Track book abandonment (user stops reading)
    func trackBookAbandonment(
        bookId: String,
        bookTitle: String,
        lastPageRead: Int,
        totalPages: Int,
        timeSpentSeconds: TimeInterval,
        abandonmentReason: String? = nil
    ) {
        var parameters: [String: Any] = [
            "book_id": bookId,
            "book_title": bookTitle,
            "last_page_read": lastPageRead,
            "total_pages": totalPages,
            "abandonment_percentage": Double(lastPageRead) / Double(totalPages) * 100,
            "time_spent_seconds": timeSpentSeconds
        ]
        
        if let reason = abandonmentReason {
            parameters["abandonment_reason"] = reason
        }
        
        Analytics.logEvent("book_abandoned", parameters: parameters)
        
        print("📊 Book Analytics: Book abandoned - \(bookTitle) at page \(lastPageRead)/\(totalPages)")
    }
    
    /// Track book sharing
    func trackBookShared(
        bookId: String,
        bookTitle: String,
        shareMethod: String
    ) {
        Analytics.logEvent("book_shared", parameters: [
            "book_id": bookId,
            "book_title": bookTitle,
            "share_method": shareMethod
        ])
        
        print("📊 Book Analytics: Book shared - \(bookTitle) via \(shareMethod)")
    }
    
    /// Track book favorited
    func trackBookFavorited(
        bookId: String,
        bookTitle: String,
        isFavorited: Bool
    ) {
        Analytics.logEvent("book_favorited", parameters: [
            "book_id": bookId,
            "book_title": bookTitle,
            "is_favorited": isFavorited
        ])
        
        print("📊 Book Analytics: Book favorited - \(bookTitle) (\(isFavorited ? "added" : "removed"))")
    }
    
    // MARK: - Book Performance Analytics
    
    /// Get book performance summary
    func getBookPerformanceSummary(bookId: String) async -> BookPerformanceSummary? {
        let db = Firestore.firestore()
        
        do {
            // Get reading sessions for this book
            let sessionsSnapshot = try await db.collection("reading_sessions")
                .whereField("bookId", isEqualTo: bookId)
                .getDocuments()
            
            let sessions = sessionsSnapshot.documents
            
            // Calculate metrics
            let totalSessions = sessions.count
            let totalTimeSpent = sessions.compactMap { $0.data()["timeSpentSeconds"] as? TimeInterval }.reduce(0, +)
            let completedSessions = sessions.filter { $0.data()["isCompleted"] as? Bool == true }.count
            let uniqueReaders = Set(sessions.compactMap { $0.data()["userId"] as? String }).count
            
            return BookPerformanceSummary(
                bookId: bookId,
                totalSessions: totalSessions,
                totalTimeSpent: totalTimeSpent,
                completedSessions: completedSessions,
                uniqueReaders: uniqueReaders,
                averageTimePerSession: totalSessions > 0 ? totalTimeSpent / Double(totalSessions) : 0,
                completionRate: totalSessions > 0 ? Double(completedSessions) / Double(totalSessions) * 100 : 0
            )
        } catch {
            print("Error getting book performance summary: \(error)")
            return nil
        }
    }
    
    /// Save reading session to Firestore
    func saveReadingSession(
        bookId: String,
        bookTitle: String,
        userId: String,
        sessionId: String,
        startTime: Date,
        endTime: Date,
        pagesRead: Int,
        totalPages: Int,
        isCompleted: Bool,
        posterImage: String? = nil
    ) {
        let db = Firestore.firestore()
        let timeSpent = endTime.timeIntervalSince(startTime)
        
        var sessionData: [String: Any] = [
            "bookId": bookId,
            "bookTitle": bookTitle,
            "userId": userId,
            "sessionId": sessionId,
            "startTime": startTime,
            "endTime": endTime,
            "timeSpentSeconds": timeSpent,
            "pagesRead": pagesRead,
            "totalPages": totalPages,
            "isCompleted": isCompleted,
            "completionPercentage": Double(pagesRead) / Double(totalPages) * 100
        ]
        
        // Add poster image if provided
        if let posterImage = posterImage {
            sessionData["posterImage"] = posterImage
        }
        
        db.collection("reading_sessions").addDocument(data: sessionData) { error in
            if let error = error {
                print("Error saving reading session: \(error)")
            } else {
                print("Reading session saved successfully")
            }
        }
    }
}

// MARK: - Data Models

struct BookPerformanceSummary {
    let bookId: String
    let totalSessions: Int
    let totalTimeSpent: TimeInterval
    let completedSessions: Int
    let uniqueReaders: Int
    let averageTimePerSession: TimeInterval
    let completionRate: Double
    
    var formattedTimeSpent: String {
        let minutes = Int(totalTimeSpent) / 60
        let seconds = Int(totalTimeSpent) % 60
        return "\(minutes)m \(seconds)s"
    }
    
    var formattedAverageTime: String {
        let minutes = Int(averageTimePerSession) / 60
        let seconds = Int(averageTimePerSession) % 60
        return "\(minutes)m \(seconds)s"
    }
}
