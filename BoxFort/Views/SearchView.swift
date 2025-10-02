//
//  SearchView.swift
//  BoxFort
//
//  Created by Matthew Ryan on 4/11/25.
//

import SwiftUI
import FirebaseAnalytics

struct SearchView: View {
    @Binding var searchText: String
    @State private var selectedBook: Book?
    @State private var isReadingBook = false
    @StateObject private var searchService = SearchService.shared
    @State private var showingSuggestions = false
    @EnvironmentObject var userViewModel: UserViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.presentationMode) var presentationMode
    @FocusState private var isSearchFieldFocused: Bool
    
    // Computed property for filtered books based on search
    private var filteredBooks: [Book] {
        return searchService.searchResults
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackgroundView()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Search Header
                    searchHeader
                    
                    // Search Results or Suggestions
                    if searchText.isEmpty {
                        if searchService.recentSearches.isEmpty && searchService.popularSearches.isEmpty {
                            exploreContent
                        } else {
                            suggestionsContent
                        }
                    } else {
                        searchResultsContent
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            Analytics.logEvent(AnalyticsEventScreenView, parameters: [
                AnalyticsParameterScreenName: "Search",
                AnalyticsParameterScreenClass: String(describing: SearchView.self)
            ])
            isSearchFieldFocused = true
        }
        .onChange(of: searchText) { _, newValue in
            if !newValue.isEmpty {
                searchService.search(newValue)
                showingSuggestions = true
            } else {
                searchService.clearSearch()
                showingSuggestions = false
            }
        }
        .sheet(item: horizontalSizeClass == .compact ? $selectedBook : .constant(nil)) { book in
            BookDetailView(book: book,
                         dismissToRoot: {
                             selectedBook = nil
                         },
                         selectedChildId: userViewModel.user?.children.first?.id)
        }
        .fullScreenCover(item: horizontalSizeClass == .regular ? $selectedBook : .constant(nil)) { book in
            BookDetailView(book: book,
                         dismissToRoot: {
                             selectedBook = nil
                         },
                         selectedChildId: userViewModel.user?.children.first?.id)
        }
    }
    
    // MARK: - Search Header
    
    private var searchHeader: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search storybooks", text: $searchText)
                    .foregroundColor(.black)
                    .focused($isSearchFieldFocused)
                    .onSubmit {
                        if !searchText.isEmpty {
                            searchService.addToRecentSearches(searchText)
                        }
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        searchService.clearSearch()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(10)
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Explore Content (when no search history)
    
    private var exploreContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Featured Stories
                VStack(alignment: .leading, spacing: 16) {
                    Text("Featured Stories")
                        .font(Font.custom("LondrinaSolid-Light", size: 24))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(BookSection.sampleBooks.filter { $0.featured }.prefix(10)) { book in
                                BookCard(book: book, 
                                       selectedBook: $selectedBook,
                                       selectedChildId: userViewModel.user?.children.first?.id)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                // Popular Searches
                if !searchService.popularSearches.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Popular Searches")
                            .font(Font.custom("LondrinaSolid-Light", size: 28))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 12) {
                            ForEach(searchService.popularSearches, id: \.self) { searchTerm in
                                Button(action: {
                                    searchText = searchTerm
                                    searchService.addToRecentSearches(searchTerm)
                                }) {
                                    Text(searchTerm)
                                        .font(Font.custom("LondrinaSolid-Light", size: 16))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.white.opacity(0.2))
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Suggestions Content (when there's search history)
    
    private var suggestionsContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Recent Searches
                if !searchService.recentSearches.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Recent Searches")
                                .font(Font.custom("LondrinaSolid-Light", size: 28))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button("Clear") {
                                searchService.recentSearches.removeAll()
                            }
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.horizontal, 20)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 12) {
                            ForEach(searchService.recentSearches, id: \.self) { searchTerm in
                                Button(action: {
                                    searchText = searchTerm
                                    searchService.addToRecentSearches(searchTerm)
                                }) {
                                    HStack {
                                        Image(systemName: "clock")
                                            .font(.caption)
                                        Text(searchTerm)
                                            .font(Font.custom("LondrinaSolid-Light", size: 16))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                // Popular Searches
                if !searchService.popularSearches.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Popular Searches")
                            .font(Font.custom("LondrinaSolid-Light", size: 28))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 12) {
                            ForEach(searchService.popularSearches, id: \.self) { searchTerm in
                                Button(action: {
                                    searchText = searchTerm
                                    searchService.addToRecentSearches(searchTerm)
                                }) {
                                    Text(searchTerm)
                                        .font(Font.custom("LondrinaSolid-Light", size: 16))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.white.opacity(0.2))
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Search Results Content
    
    private var searchResultsContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if searchService.isSearching {
                    HStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        Text("Searching...")
                            .font(Font.custom("LondrinaSolid-Light", size: 16))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 40)
                } else if searchService.searchResults.isEmpty {
                    // No results found
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text("No results found")
                            .font(Font.custom("LondrinaSolid-Light", size: 24))
                            .foregroundColor(.white)
                        
                        Text("Try searching for a character name or story title")
                            .font(Font.custom("LondrinaSolid-Light", size: 16))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 60)
                } else {
                    // Search results
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150, maximum: 200))], spacing: 16) {
                        ForEach(filteredBooks) { book in
                            Button(action: {
                                selectedBook = book
                                searchService.addToRecentSearches(searchText)
                                
                                // Track search result selection
                                Analytics.logEvent("search_result_selected", parameters: [
                                    "book_id": book.id,
                                    "book_title": book.title,
                                    "search_query": searchText,
                                    "is_free": book.free
                                ])
                            }) {
                                VStack(spacing: 8) {
                                    Image(book.posterImage)
                                        .resizable()
                                        .scaledToFit()
                                        .cornerRadius(10)
                                        .shadow(radius: 4)
                                    
                                    Text(book.title)
                                        .font(Font.custom("LondrinaSolid-Light", size: 14))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .padding(.bottom, 100)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(searchText: .constant(""))
    }
}