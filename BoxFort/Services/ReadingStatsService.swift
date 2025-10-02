import Foundation
import FirebaseFirestore
import FirebaseAnalytics

class ReadingStatsService {
    static let shared = ReadingStatsService()
    private let db = Firestore.firestore()
    private let newsletterService = NewsletterService.shared
    
    private init() {}
    
    struct ReadingStats {
        let childName: String
        let booksRead: Int
        let totalPagesRead: Int
        let favoriteBook: String?
    }
    
    func generateWeeklyStats(for userId: String) async throws -> [ReadingStats] {
        let userRef = db.collection("users").document(userId)
        let userDoc = try await userRef.getDocument()
        
        guard let user = try? userDoc.data(as: User.self) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
        
        var stats: [ReadingStats] = []
        
        // Get analytics data for the past week
        let calendar = Calendar.current
        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        
        // For each child, gather their reading stats
        for child in user.children {
            let childStats = try await getChildReadingStats(child: child, since: oneWeekAgo)
            stats.append(childStats)
        }
        
        return stats
    }
    
    private func getChildReadingStats(child: ChildProfile, since date: Date) async throws -> ReadingStats {
        // Query Firebase Analytics for reading events
        let analytics = Analytics.self
        
        // Get books read count
        let booksRead = try await getBooksReadCount(for: child.id, since: date)
        
        // Get total pages read
        let totalPagesRead = try await getTotalPagesRead(for: child.id, since: date)
        
        // Get favorite book (most read)
        let favoriteBook = try await getFavoriteBook(for: child.id, since: date)
    
        
        return ReadingStats(
            childName: child.name,
            booksRead: booksRead,
            totalPagesRead: totalPagesRead,
            favoriteBook: favoriteBook
        )
    }
    
    private func getBooksReadCount(for childId: String, since date: Date) async throws -> Int {
        // Query Firebase Analytics for book completion events
        // This is a placeholder - you'll need to implement the actual analytics query
        return 0
    }
    
    private func getTotalPagesRead(for childId: String, since date: Date) async throws -> Int {
        // Query Firebase Analytics for page reading events
        // This is a placeholder - you'll need to implement the actual analytics query
        return 0
    }
    
    private func getFavoriteBook(for childId: String, since date: Date) async throws -> String? {
        // Query Firebase Analytics for most frequently read book
        // This is a placeholder - you'll need to implement the actual analytics query
        return nil
    }
    
    func sendWeeklyStatsEmail(to email: String, stats: [ReadingStats]) async throws {
        // Generate email content
        let emailContent = generateEmailContent(stats: stats)
        
        // Send via KIT
        // Note: You'll need to implement the actual email sending through KIT's API
        print("Would send email to \(email) with content: \(emailContent)")
    }
    
    private func generateEmailContent(stats: [ReadingStats]) -> String {
        var content = "Your Child's Reading Progress This Week\n\n"
        
        for stat in stats {
            content += "📚 \(stat.childName)'s Reading Stats:\n"
            content += "• Books Read: \(stat.booksRead)\n"
            content += "• Total Pages: \(stat.totalPagesRead)\n"
            if let favorite = stat.favoriteBook {
                content += "• Favorite Book: \(favorite)\n"
            }
        }
        
        content += "Keep up the great reading! 📖✨"
        return content
    }
} 
