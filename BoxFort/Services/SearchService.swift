//
//  SearchService.swift
//  BoxFort
//
//  Created by Matthew Ryan on 4/11/25.
//

import Foundation
import FirebaseAnalytics

class SearchService: ObservableObject {
    static let shared = SearchService()
    
    @Published var searchResults: [Book] = []
    @Published var isSearching: Bool = false
    @Published var searchSuggestions: [String] = []
    @Published var recentSearches: [String] = []
    @Published var popularSearches: [String] = []
    
    private let maxRecentSearches = 10
    private let maxSuggestions = 8
    private let searchDebounceTime: TimeInterval = 0.3
    
    private var searchTask: Task<Void, Never>?
    private var allBooks: [Book] = []
    
    private init() {
        loadRecentSearches()
        loadPopularSearches()
        loadAllBooks()
    }
    
    // MARK: - Public Methods
    
    func search(_ query: String) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            clearSearch()
            return
        }
        
        // Cancel previous search
        searchTask?.cancel()
        
        // Start new search with debounce
        searchTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(searchDebounceTime * 1_000_000_000))
            
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                performSearch(query)
            }
        }
    }
    
    func clearSearch() {
        searchTask?.cancel()
        searchResults = []
        isSearching = false
        searchSuggestions = []
    }
    
    func addToRecentSearches(_ query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }
        
        // Remove if already exists
        recentSearches.removeAll { $0.lowercased() == trimmedQuery.lowercased() }
        
        // Add to beginning
        recentSearches.insert(trimmedQuery, at: 0)
        
        // Keep only maxRecentSearches
        if recentSearches.count > maxRecentSearches {
            recentSearches = Array(recentSearches.prefix(maxRecentSearches))
        }
        
        saveRecentSearches()
        
        // Track search analytics
        Analytics.logEvent("search_performed", parameters: [
            "search_query": trimmedQuery,
            "search_results_count": searchResults.count
        ])
    }
    
    func getSearchSuggestions(for query: String) -> [String] {
        guard !query.isEmpty else { return [] }
        
        let lowercaseQuery = query.lowercased()
        var suggestions: Set<String> = []
        
        // Search in book titles
        for book in allBooks {
            if book.title.lowercased().contains(lowercaseQuery) {
                suggestions.insert(book.title)
            }
        }
        
        // Search in characters
        for book in allBooks {
            for character in book.characters {
                if character.lowercased().contains(lowercaseQuery) {
                    suggestions.insert(character.capitalized)
                }
            }
        }
        
        // Search in recent searches
        for recentSearch in recentSearches {
            if recentSearch.lowercased().contains(lowercaseQuery) {
                suggestions.insert(recentSearch)
            }
        }
        
        return Array(suggestions.prefix(maxSuggestions))
    }
    
    // MARK: - Private Methods
    
    private func performSearch(_ query: String) {
        isSearching = true
        
        let lowercaseQuery = query.lowercased()
        let searchTerms = lowercaseQuery.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        
        let filteredBooks = allBooks.filter { book in
            // Handle key terms first
            if handleKeyTerms(query: lowercaseQuery, book: book) {
                return true
            }
            
            // Title match (highest priority)
            let titleMatch = book.title.lowercased().contains(lowercaseQuery)
            
            // Character match
            let characterMatch = book.characters.contains { character in
                character.lowercased().contains(lowercaseQuery)
            }
            
            // Details match
            let detailsMatch = book.details.lowercased().contains(lowercaseQuery)
            
            // Multi-word search
            let multiWordMatch = searchTerms.allSatisfy { term in
                book.title.lowercased().contains(term) ||
                book.characters.contains { $0.lowercased().contains(term) } ||
                book.details.lowercased().contains(term)
            }
            
            return titleMatch || characterMatch || detailsMatch || multiWordMatch
        }
        
        // Sort results by relevance
        let sortedResults = sortSearchResults(filteredBooks, query: lowercaseQuery)
        
        searchResults = sortedResults
        isSearching = false
        
        // Generate suggestions for next search
        searchSuggestions = getSearchSuggestions(for: query)
    }
    
    private func handleKeyTerms(query: String, book: Book) -> Bool {
        // Handle "free" keyword
        if query.contains("free") {
            return book.free ?? false
        }
        
        // Handle "featured" keyword
        if query.contains("featured") {
            return book.featured ?? false
        }
        
        // Handle "new" keyword
        if query.contains("new") {
            return book.new ?? false
        }
        
        // Handle "top rated" or "trending" keywords
        if query.contains("top") || query.contains("rated") || query.contains("trending") {
            return book.topRated ?? false
        }
        
        // Handle "littlebook" or "short" keywords
        if query.contains("little") || query.contains("short") || query.contains("5 minute") {
            return book.littlebook ?? false
        }
        
        return false
    }
    
    private func sortSearchResults(_ books: [Book], query: String) -> [Book] {
        return books.sorted { book1, book2 in
            let score1 = calculateRelevanceScore(book1, query: query)
            let score2 = calculateRelevanceScore(book2, query: query)
            return score1 > score2
        }
    }
    
    private func calculateRelevanceScore(_ book: Book, query: String) -> Int {
        var score = 0
        
        // Title exact match (highest score)
        if book.title.lowercased() == query {
            score += 100
        } else if book.title.lowercased().hasPrefix(query) {
            score += 80
        } else if book.title.lowercased().contains(query) {
            score += 60
        }
        
        // Character match
        for character in book.characters {
            if character.lowercased() == query {
                score += 50
            } else if character.lowercased().contains(query) {
                score += 30
            }
        }
        
        // Featured books get slight boost
        if book.featured {
            score += 10
        }
        
        // Free books get slight boost
        if book.free {
            score += 5
        }
        
        return score
    }
    
    private func loadAllBooks() {
        // Safely load books with error handling
        do {
            allBooks = BookSection.sampleBooks
        } catch {
            print("Error loading books: \(error)")
            allBooks = []
        }
    }
    
    private func loadRecentSearches() {
        if let data = UserDefaults.standard.data(forKey: "recent_searches"),
           let searches = try? JSONDecoder().decode([String].self, from: data) {
            recentSearches = searches
        }
    }
    
    private func saveRecentSearches() {
        if let data = try? JSONEncoder().encode(recentSearches) {
            UserDefaults.standard.set(data, forKey: "recent_searches")
        }
    }
    
    private func loadPopularSearches() {
        // For now, use some default popular searches
        // In a real app, this could be based on analytics data
        popularSearches = [
            "Patrick",
            "Arty",
            "Kevin",
            "Free",
            "Monster",
            "Adventure",
            "Funny",
            "New"
        ]
    }
    
}
