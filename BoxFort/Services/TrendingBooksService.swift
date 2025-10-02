//
//  TrendingBooksService.swift
//  BoxFort
//
//  Created by Matthew Ryan on 1/15/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAnalytics

class TrendingBooksService: ObservableObject {
    static let shared = TrendingBooksService()
    
    @Published var trendingBooks: [TrendingBook] = []
    @Published var isLoading = false
    @Published var lastUpdated: Date?
    
    private let db = Firestore.firestore()
    private let cacheKey = "trending_books_cache"
    private let cacheExpirationHours: TimeInterval = 6 // Cache for 6 hours
    
    private init() {
        loadCachedData()
    }
    
    // MARK: - Public Methods
    
    /// Fetch trending books for the current week
    func fetchTrendingBooks() async {
        await MainActor.run {
            isLoading = true
        }
        
        do {
            let books = try await getTrendingBooksForCurrentWeek()
            
            await MainActor.run {
                self.trendingBooks = books
                self.lastUpdated = Date()
                self.isLoading = false
                
                // Cache the results
                self.cacheTrendingBooks(books)
            }
            
            // Track analytics
            Analytics.logEvent("trending_books_fetched", parameters: [
                "book_count": books.count,
                "hot_books_count": books.filter { $0.isHot }.count,
                "total_reads": books.reduce(0) { $0 + $1.readCount }
            ])
            
        } catch {
            print("Error fetching trending books: \(error)")
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
    /// Get trending books from cache or fetch if expired
    func getTrendingBooks() async -> [TrendingBook] {
        if shouldRefreshCache() {
            await fetchTrendingBooks()
        }
        return trendingBooks
    }
    
    // MARK: - Private Methods
    
    private func getTrendingBooksForCurrentWeek() async throws -> [TrendingBook] {
        // First, try to get cached global trending data
        do {
            let cacheDoc = try await db.collection("trending_cache").document("current_week").getDocument()
            
            if cacheDoc.exists, let data = cacheDoc.data() {
                // Check if cache is still valid (less than 6 hours old)
                if let lastUpdated = data["lastUpdated"] as? Timestamp {
                    let cacheAge = Date().timeIntervalSince(lastUpdated.dateValue())
                    if cacheAge < 6 * 3600 { // 6 hours
                        return parseCachedTrendingBooks(data)
                    }
                }
            }
        } catch {
            print("Error fetching cached trending data: \(error)")
        }
        
        // If no valid cache, try to get real-time global data
        return try await getRealTimeGlobalTrendingData()
    }
    
    private func parseCachedTrendingBooks(_ data: [String: Any]) -> [TrendingBook] {
        guard let booksData = data["books"] as? [[String: Any]] else {
            return getFallbackTrendingBooks()
        }
        
        return booksData.compactMap { bookData in
            guard let bookId = bookData["bookId"] as? String,
                  let title = bookData["title"] as? String,
                  let posterImage = bookData["posterImage"] as? String,
                  let readCount = bookData["readCount"] as? Int,
                  let rank = bookData["rank"] as? Int else {
                return nil
            }
            
            return TrendingBook(
                bookId: bookId,
                title: title,
                posterImage: posterImage,
                readCount: readCount,
                rank: rank
            )
        }
    }
    
    private func getRealTimeGlobalTrendingData() async throws -> [TrendingBook] {
        let weekStart = getWeekStart()
        let weekEnd = getWeekEnd()
        
        // Query ALL reading sessions from the current week (global data)
        let sessionsQuery = db.collection("reading_sessions")
            .whereField("startTime", isGreaterThanOrEqualTo: Timestamp(date: weekStart))
            .whereField("startTime", isLessThan: Timestamp(date: weekEnd))
            .whereField("isCompleted", isEqualTo: true)
        
        let snapshot = try await sessionsQuery.getDocuments()
        
        // Aggregate read counts by book (global aggregation)
        var bookReadCounts: [String: Int] = [:]
        var bookTitles: [String: String] = [:]
        var bookPosters: [String: String] = [:]
        
        for document in snapshot.documents {
            let data = document.data()
            guard let bookId = data["bookId"] as? String,
                  let bookTitle = data["bookTitle"] as? String,
                  let posterImage = data["posterImage"] as? String else {
                continue
            }
            
            bookReadCounts[bookId, default: 0] += 1
            bookTitles[bookId] = bookTitle
            bookPosters[bookId] = posterImage
        }
        
        // If we have real data, use it
        if !bookReadCounts.isEmpty {
            let sortedBooks = bookReadCounts
                .sorted { $0.value > $1.value }
                .prefix(10) // Top 10 trending books
            
            var trendingBooks: [TrendingBook] = []
            for (index, element) in sortedBooks.enumerated() {
                let (bookId, readCount) = element
                guard let title = bookTitles[bookId],
                      let posterImage = bookPosters[bookId] else {
                    continue
                }
                
                let trendingBook = TrendingBook(
                    bookId: bookId,
                    title: title,
                    posterImage: posterImage,
                    readCount: readCount,
                    rank: index + 1
                )
                trendingBooks.append(trendingBook)
            }
            
            // Cache the results for future requests
            await cacheGlobalTrendingData(trendingBooks, weekStart: weekStart, weekEnd: weekEnd)
            
            return trendingBooks
        } else {
            // Fallback: Return curated popular books when no real data exists
            return getFallbackTrendingBooks()
        }
    }
    
    private func cacheGlobalTrendingData(_ books: [TrendingBook], weekStart: Date, weekEnd: Date) async {
        let booksData = books.map { book in
            [
                "bookId": book.bookId,
                "title": book.title,
                "posterImage": book.posterImage,
                "readCount": book.readCount,
                "rank": book.rank,
                "isHot": book.isHot
            ]
        }
        
        let cacheData: [String: Any] = [
            "books": booksData,
            "weekStart": weekStart,
            "weekEnd": weekEnd,
            "totalReads": books.reduce(0) { $0 + $1.readCount },
            "lastUpdated": FieldValue.serverTimestamp()
        ]
        
        do {
            try await db.collection("trending_cache").document("current_week").setData(cacheData)
        } catch {
            print("Error caching trending data: \(error)")
        }
    }
    
    /// Fallback trending books when no real analytics data is available
    private func getFallbackTrendingBooks() -> [TrendingBook] {
        // Curated list of popular books that should always show
        let fallbackBooks = [
            ("PatrickTakesOff", "Patrick Takes Off", "PatrickTakesOff"),
            ("TheBigBlueberry", "The Big Blueberry", "TheBigBlueberry"),
            ("Marshmallow", "Marshmallow", "Marshmallow"),
            ("Brave", "Brave", "Brave"),
            ("TheNiblit", "The Niblit", "TheNiblit"),
            ("Hiccup", "Hiccup", "Hiccup"),
            ("Bubblegum", "Bubblegum", "Bubblegum"),
            ("TheExpert", "The Expert", "TheExpert"),
            ("OneMoreThing", "One More Thing", "OneMoreThing"),
            ("TheMove", "The Move", "TheMove")
        ]
        
        return fallbackBooks.enumerated().map { index, book in
            TrendingBook(
                bookId: book.0,
                title: book.1,
                posterImage: book.2,
                readCount: 0, // No real read count for fallback
                rank: index + 1
            )
        }
    }
    
    private func getWeekStart() -> Date {
        let calendar = Calendar.current
        let now = Date()
        let weekday = calendar.component(.weekday, from: now)
        let daysFromMonday = (weekday + 5) % 7 // Convert to Monday = 0
        return calendar.date(byAdding: .day, value: -daysFromMonday, to: now) ?? now
    }
    
    private func getWeekEnd() -> Date {
        let calendar = Calendar.current
        let weekStart = getWeekStart()
        return calendar.date(byAdding: .day, value: 7, to: weekStart) ?? Date()
    }
    
    private func shouldRefreshCache() -> Bool {
        guard let lastUpdated = lastUpdated else { return true }
        return Date().timeIntervalSince(lastUpdated) > cacheExpirationHours * 3600
    }
    
    private func loadCachedData() {
        guard let data = UserDefaults.standard.data(forKey: cacheKey),
              let cachedBooks = try? JSONDecoder().decode([TrendingBook].self, from: data),
              let cacheDate = UserDefaults.standard.object(forKey: "\(cacheKey)_date") as? Date else {
            return
        }
        
        // Check if cache is still valid
        if Date().timeIntervalSince(cacheDate) < cacheExpirationHours * 3600 {
            trendingBooks = cachedBooks
            lastUpdated = cacheDate
        }
    }
    
    private func cacheTrendingBooks(_ books: [TrendingBook]) {
        if let data = try? JSONEncoder().encode(books) {
            UserDefaults.standard.set(data, forKey: cacheKey)
            UserDefaults.standard.set(Date(), forKey: "\(cacheKey)_date")
        }
    }
}

// MARK: - Analytics Integration

extension TrendingBooksService {
    
    /// Track when a trending book is selected
    func trackTrendingBookSelected(_ book: TrendingBook, source: String) {
        Analytics.logEvent("trending_book_selected", parameters: [
            "book_id": book.bookId,
            "book_title": book.title,
            "rank": book.rank,
            "read_count": book.readCount,
            "is_hot": book.isHot,
            "source": source
        ])
    }
    
    /// Track trending section view
    func trackTrendingSectionViewed() {
        Analytics.logEvent("trending_section_viewed", parameters: [
            "book_count": trendingBooks.count,
            "hot_books_count": trendingBooks.filter { $0.isHot }.count
        ])
    }
}
