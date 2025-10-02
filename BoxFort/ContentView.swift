//
//  ContentView.swift
//  Boxfort Plus
//
//  Created by Matthew Ryan on 9/2/22.
//

import SwiftUI

struct ContentView: View {
    @State private var searchText = ""
    @State private var showingAccount = false
    @State private var selectedBook: Book?
    @EnvironmentObject var userViewModel: UserViewModel
    @StateObject private var authService = AuthenticationService()
    @StateObject private var deepLinkHandler = DeepLinkHandler.shared
    
    var body: some View {
        ZStack {
            NavigationView {
                HomePage(searchText: $searchText)
                    .environmentObject(authService)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            
            // FAB for Account
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showingAccount = true }) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding()
                    .sheet(isPresented: $showingAccount) {
                        ProfileView()
                            .environmentObject(authService)
                    }
                }
            }
        }
        .onAppear {
            userViewModel.setupAuthService(authService)
        }
        .onReceive(deepLinkHandler.$shouldNavigateToBook) { shouldNavigate in
            if shouldNavigate, let book = deepLinkHandler.getBookFromDeepLink() {
                selectedBook = book
                deepLinkHandler.clearPendingBook()
            }
        }
        .onReceive(deepLinkHandler.$shouldNavigateToSearch) { shouldNavigate in
            if shouldNavigate, let searchQuery = deepLinkHandler.getSearchQueryFromDeepLink() {
                print("DEBUG: Deep link search triggered with query: '\(searchQuery)'")
                // Set the search text to trigger search
                searchText = searchQuery
                print("DEBUG: Search text set to: '\(searchText)'")
                deepLinkHandler.clearPendingSearch()
            }
        }
        .fullScreenCover(item: $selectedBook) { book in
            BookDetailView(book: book, dismissToRoot: { selectedBook = nil }, selectedChildId: nil)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
