//
//  HomePage.swift
//  BoxFort
//
//  Created by Matthew Ryan on 4/11/25.
//


//
//  HomePage.swift
//  Boxfort Plus
//
//  Created by Matthew Ryan on 9/2/22.
//

import SwiftUI
import FirebaseAnalytics
import AVKit
import ConfettiSwiftUI
import RevenueCat
import SwiftyGif
import OneSignalFramework

struct HomePage: View {
    @State var isPaywallPresented = false
    @State private var selectedBook: Book?
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var authService: AuthenticationService
    @StateObject private var completionService = BookCompletionService.shared
    @StateObject private var creatorSupportPleaService = CreatorSupportPleaService.shared
    @Binding var searchText: String
    @State private var showingSearch = false
    @State private var showingAccount = false
    @State private var confettiCounter = 0
    @State private var showQbies = false
    @State private var showingArtyView = false
    @State private var showingKevinView = false
    @State private var showingPatrickView = false
    @State private var showingCatCallCrisis = false
    @State private var selectedChildId: String?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var showingAddChild = false
    @State private var showingProfile = false
    @State private var selectedCollection: BookCollection?
    @State private var showingOnboarding = false
    @State private var showingPhotoUpload = false
    // @State private var showingCharacterCreator = false // Character packs not live yet
    @State private var showNotificationPrompt = false
    
    private var selectedChild: ChildProfile? {
        guard let id = selectedChildId else { 
            // If no child is selected but user is registered, return first child
            if let firstChild = userViewModel.user?.children.first {
                return firstChild
            }
            return nil
        }
        let child = userViewModel.user?.children.first(where: { $0.id == id })
        return child
    }
    
    private var childFavorites: [Book] {
        // For unregistered users or users without children
        if userViewModel.user == nil || userViewModel.user?.children.isEmpty == true {
            return []
        }
        
        // For registered users with children
        guard let child = selectedChild else {
            return []
        }
        
        let favorites = child.favorites.compactMap { favoriteId in
            BookSection.sampleBooks.first(where: { $0.id == favoriteId })
        }
        return favorites
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    // Background
                    GradientBackgroundView()
                        .edgesIgnoringSafeArea(.all)
                    
                    // Main Content
                    mainScrollContent
                    
                    // Kid Profile Selector FAB
                    profileSwitcherFAB
                }
            }
            .modifier(HomePageModifiers(
                horizontalSizeClass: horizontalSizeClass,
                isPaywallPresented: $isPaywallPresented,
                showingProfile: $showingProfile,
                showingOnboarding: $showingOnboarding,
                confettiCounter: $confettiCounter,
                showingArtyView: showingArtyView,
                completionService: completionService,
                selectedBook: $selectedBook,
                selectedChildId: selectedChildId,
                selectedCollection: $selectedCollection,
                // showingCharacterCreator: $showingCharacterCreator, // Character packs not live yet
                userViewModel: userViewModel,
                authService: authService,
                showNotificationPrompt: $showNotificationPrompt,
                showingSearch: $showingSearch,
                searchText: $searchText
            ))
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            // Select the first child by default if one exists
            if selectedChildId == nil, let firstChild = userViewModel.user?.children.first {
                selectedChildId = firstChild.id
            }
            checkAndShowConfetti()
            checkOnboardingStatus()
            checkBookCompletionStatus()
            
            // Check if creator support plea should be shown
            creatorSupportPleaService.checkShouldShowPlea()
            
            // Track screen view
            Analytics.logEvent(AnalyticsEventScreenView, parameters: [
                "screen_name": "HomePage",
                "screen_class": "HomePage"
            ])
            
            // Increment session count for better permission timing
            OneSignalService.shared.incrementSessionCount()
            
            // Show notification prompt with improved strategy
            if OneSignalService.shared.shouldShowPermissionRequest() && !OneSignalService.shared.hasSeenNotificationPrompt() {
                showNotificationPrompt = true
                OneSignalService.shared.markNotificationPromptSeen()
            } else {
            }
            
            // Check for permission recovery if user denied previously
            OneSignalService.shared.checkAndShowPermissionRecovery()
            
            // Debug logging for notification permission status
            OneSignalService.shared.logPermissionStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ShowCustomPermissionRequest"))) { _ in
            showNotificationPrompt = true
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ShowPermissionRecovery"))) { _ in
            showNotificationPrompt = true
        }
        .onChange(of: selectedChildId) { _ in
            checkBookCompletionStatus()
        }
        .onChange(of: userViewModel.user) { _ in
            checkBookCompletionStatus()
        }
        .sheet(isPresented: horizontalSizeClass == .compact ? $showingKevinView : .constant(false)) {
            KevinView()
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: horizontalSizeClass == .regular ? $showingKevinView : .constant(false)) {
            KevinView()
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
        }
        .sheet(isPresented: horizontalSizeClass == .compact ? $showingPatrickView : .constant(false)) {
            PatrickView()
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: horizontalSizeClass == .regular ? $showingPatrickView : .constant(false)) {
            PatrickView()
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $showingCatCallCrisis) {
            CatCallCrisisGameView()
        }
    }
    
    // MARK: - View Components
    
    private var mainContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Netflix-style Hero Section
            NetflixStyleHeroSection(selectedChildId: selectedChildId, selectedBook: $selectedBook)
            
            // Trending Books Section (Netflix style)
            TrendingBooksView(selectedBook: $selectedBook, selectedChildId: selectedChildId)
                .padding(.top, 20)
            
            // Prominent Free Books Carousel (if user is not subscribed)
            if !userViewModel.isSubscriptionActive {
                ProminentFreeBooksCarousel(selectedChildId: selectedChildId)
                    .padding(.top, 16)
            }
            
            // Favorites Section
            favoritesSection
            
            // Character Creator Section
            /*
            VStack(alignment: .leading, spacing: 16) {
                Text("Character Creator")
                    .font(Font.custom("LondrinaSolid-Light", size: 32))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                
                Button(action: {
                    showingCharacterCreator = true
                }) {
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Create Your Character!")
                                    .font(Font.custom("LondrinaSolid-Regular", size: 28))
                                    .foregroundColor(.white)
                                
                                Text("Mix and match heads, bodies, and legs")
                                    .font(Font.custom("LondrinaSolid-Light", size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                        
                        Text("Unlock new character parts by reading stories! Create fun combinations and share your creations.")
                            .font(Font.custom("LondrinaSolid-Light", size: 16))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 24)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 16)
            .background(ColorConstants.ctaColor)
            .cornerRadius(20)
            .padding(.horizontal, 20)
            */
            
            // Featured Collections Section (moved below Favorites)
            /*
            VStack(alignment: .leading, spacing: 16) {
                Text("Featured Collections")
                    .font(Font.custom("LondrinaSolid-Light", size: 32))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(BookCollection.sampleCollections) { collection in
                            CollectionCard(collection: collection) {
                                selectedCollection = collection
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                }
            }
            .padding(.vertical, 16)
            .background(ColorConstants.mintyColor)
            .cornerRadius(28)
            .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 4)
            .padding(.horizontal, 20)
            */
            
            // Cat Call Crisis Minigame Section
            /*
            VStack(alignment: .leading, spacing: 16) {
                Text("Fun & Games")
                    .font(Font.custom("LondrinaSolid-Light", size: 32))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                
                ChannelView(showingCatCallCrisis: $showingCatCallCrisis)
                    .padding(.horizontal, 32)
            }
            .padding(.vertical, 16)
            .background(Color.black.opacity(0.3))
            .cornerRadius(28)
            .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 4)
            .padding(.horizontal, 20)
            */
            
            // Photo Upload CTA Section
            /*
            VStack(alignment: .leading, spacing: 16) {
                Button(action: {
                    showingPhotoUpload = true
                }) {
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Add Patrick to Your Photos!")
                                    .font(Font.custom("LondrinaSolid-Regular", size: 28))
                                    .foregroundColor(.white)
                                
                                Text("Create magical memories with AI")
                                    .font(Font.custom("LondrinaSolid-Light", size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                        
                        Text("Select a photo and watch Patrick join the fun! Your creations are saved in your personal scrapbook.")
                            .font(Font.custom("LondrinaSolid-Light", size: 16))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 24)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 16)
            */
            
            // Featured Section
            FeaturedSection(selectedChildId: selectedChildId, selectedBook: $selectedBook)
                .padding(.top, 20)
            
            // Character Sections
            characterSections
                .padding(.horizontal)

            // Read Aloud Section
            ReadAloudSection()
                .padding(.horizontal)
                .padding(.top, 8)
            
            // Main Sections
            mainSections
            
            // More Sections (5 Minute Storybooks)
            moreSections
            
            // All Stories Section
            allStoriesSection
                .padding(.top, 24)
            
            Color.clear.frame(height: 20)
        }
    }
    
    private var mainScrollContent: some View {
        VStack(spacing: 0) {
            // Subscribe button outside ScrollView to avoid gesture conflicts
            if !userViewModel.isSubscriptionActive {
                subscribeButtonSection
            }
            
            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                    
                    // Search functionality commented out
                    /*
                    searchSection
                    
                    if isSearching {
                        SearchResultsSection(
                            searchText: $searchText,
                            isSearching: $isSearching,
                            selectedChildId: selectedChildId
                        )
                        .padding(.top, 20)
                    } else {
                    */
                    
                    // Creator Support Plea (after user has engaged meaningfully)
                    if creatorSupportPleaService.shouldShowPlea {
                        CreatorSupportPlea()
                            .padding(.top, 12)
                            .padding(.bottom, 20)
                    }
                    
                    mainContent
                    
                    // Add bottom padding to account for the FAB
                    Spacer()
                        .frame(height: 80)
                    /*
                    }
                    */
                }
            }
            .refreshable {
                await refreshSubscriptionState()
            }
        }
    }
    
    private var profileSwitcherFAB: some View {
        VStack {
            Spacer()
            if let user = userViewModel.user, !user.children.isEmpty {
                HStack {
                    ProfileSwitcher(selectedChildId: $selectedChildId)
                        .frame(width: 44, height: 44)
                        .padding(.leading, 20)
                    Spacer()
                }
                .padding(.bottom, 20)
            }
        }
    }
    
    private var headerSection: some View {
        Group {
            if userViewModel.isSubscriptionActive {
                VStack(spacing: 16) {
                    // Search Button
                    Button(action: {
                        showingSearch = true
                    }) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            
                            Text("Search storybooks")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Spacer()
                        }
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    HeaderView(selectedChildId: $selectedChildId)
                }
            }
        }
    }
    
    private var subscribeButtonSection: some View {
        Button(action: {
            print("DEBUG: Subscribe button tapped!")
            self.isPaywallPresented = true
        }) {
            VStack(spacing: 16) {
                Text("Not Your Regular\nStorybooks")
                    .font(Font.custom("LondrinaSolid-Regular", size: 32))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                Text("Subscribe to unlock 40+ delightful, giggly, happy little storybooks.")
                    .font(Font.custom("LondrinaSolid-Light", size: 24))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                HStack {
                    Text("Unlock Unlimited Access")
                        .font(Font.custom("LondrinaSolid-Light", size: 28))
                        .foregroundColor(.white)
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .background(Color.black)
                .cornerRadius(25)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(ColorConstants.ctaColor)
            .cornerRadius(15)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
        .padding(.bottom, 24) // Add spacing below subscribe block
    }
    
    private var searchSection: some View {
        VStack(spacing: 0) {
            // Search functionality completely commented out
            /*
            // Spotlight Section (commented out)
            SpotlightView(selectedChildId: selectedChildId)
                .padding(.top, 24)
            
            // Weekly Books Section (for subscribed users) - TEMPORARILY DISABLED
            if userViewModel.isSubscriptionActive {
                WeeklyBooksSection(selectedChildId: selectedChildId)
                    .padding(.top, 16)
            }
            
            // Test Button
            Button(action: {
                print("DEBUG: TEST BUTTON TAPPED!")
                showingSearch = true
            }) {
                Text("🔴 TEST SEARCH BUTTON - TAP ME")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .buttonStyle(PlainButtonStyle())
            .contentShape(Rectangle())
            .allowsHitTesting(true)
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Fake Search Bar Button
            FakeSearchBarButton(searchText: $searchText, showingSearch: $showingSearch)
                .padding(.bottom, 30)
            */
        }
    }
    
    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if userViewModel.user == nil {
                // CTA for unregistered users
                Button(action: {
                    showingProfile = true
                }) {
                    VStack(spacing: 12) {
                        Text("Create Your Account")
                            .font(Font.custom("LondrinaSolid-Regular", size: 32))
                            .foregroundColor(.white)
                        
                        Text("Save your favorite stories and create profiles for your little ones!")
                            .font(Font.custom("LondrinaSolid-Light", size: 18))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                        
                        HStack {
                            Text("Get Started")
                                .font(Font.custom("LondrinaSolid-Light", size: 24))
                                .foregroundColor(.white)
                            
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 24))
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(25)
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 32)
                    .frame(maxWidth: .infinity)
                }
            } else if !childFavorites.isEmpty {
                // Existing favorites view for registered users
                Text("\(selectedChild?.name ?? "My")'s Favorites")
                    .font(Font.custom("LondrinaSolid-Light", size: 32))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(childFavorites) { book in
                            BookCard(book: book, 
                                   selectedBook: $selectedBook,
                                   selectedChildId: selectedChildId)
                        }
                    }
                    .padding(.horizontal, 32)
                }
            }
        }
        .padding(.vertical, 16)
        .background(Color.black.opacity(0.3))
        .cornerRadius(20)
        .padding(.horizontal, 20)
    }
    
    private var mainSections: some View {
        ForEach(BookSection.sections, id: \.id) { section in
            if section.sectionName != "Read for Free" && 
               !section.sectionName.contains("Meet") && 
               !section.sectionName.contains("Featuring") {
                BookSectionView(bookSection: section,
                              selectedChildId: selectedChildId)
                    .padding(.horizontal)
            }
        }
    }
    
    private var moreSections: some View {
        ForEach(BookSection.moreSections, id: \.id) { section in
            BookSectionView(bookSection: section,
                          selectedChildId: selectedChildId)
                .padding(.horizontal)
                .padding(.top, 16)
        }
    }
    
    private var characterSections: some View {
        VStack(spacing: 20) {
            // Patrick Section
            characterSection(title: "Meet Patrick", imageName: "Patrick", books: BookSection.patrick.books)
            
            // Kevin Section
            characterSection(title: "Meet Kevin", imageName: "Kevin", books: BookSection.kevin.books)
            
            // Arty Section
            characterSection(title: "Meet Arty", imageName: "Arty", books: BookSection.arty.books)
            
            // Dr Toast Section
            characterSection(title: "Meet Dr Toast", imageName: "DrToast", books: BookSection.drToast.books)
        }
    }
    
    private func characterSection(title: String, imageName: String, books: [Book]) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(Font.custom("LondrinaSolid-Light", size: 32))
                .foregroundColor(.white)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    // Character static image with swipe indicator
                    ZStack {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                        
                        // Right-pointing arrow overlay to encourage swiping
                        HStack {
                            Spacer()
                            VStack {
                                Spacer()
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.black)
                                    .background(Color.white.opacity(0.9))
                                    .clipShape(Circle())
                                    .padding(.trailing, 8)
                                    .padding(.bottom, 8)
                            }
                        }
                    }
                    
                    // Book covers
                    ForEach(books) { book in
                        Button(action: {
                            self.selectedBook = book
                        }) {
                            Image(book.posterImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var qbiesPromoSection: some View {
        VStack(alignment: .leading) {
            Button(action: {
                if let url = URL(string: "https://apps.apple.com/us/app/qbies-marshmallow-collector/id6738206052") {
                    UIApplication.shared.open(url)
                }
            }) {
                ZStack {
                    Image("qbies_promo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .cornerRadius(10)
                        .clipped()
                    
                    VStack(spacing: 8) {
                        HStack {
                            Text("Introducing Qbies")
                                .font(Font.custom("LondrinaSolid-Regular", size: 24))
                                .foregroundColor(.white)
                            
                            Image(systemName: "arrow.up.forward.app")
                                .foregroundColor(.white)
                        }
                        
                        Text("Roll, Collect, Play, and S'More!\nEnter code MRTACO in the Shop for an exclusive pet.")
                            .font(Font.custom("LondrinaSolid-Light", size: 18))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 20)
    }
    
    private var allStoriesSection: some View {
        VStack(alignment: .leading) {
            Text("All Stories")
                .font(Font.custom("LondrinaSolid-Light", size: 32))
                .foregroundColor(.white)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 15)
            ], spacing: 15) {
                ForEach(BookSection.sampleBooks.sorted(by: { $0.title < $1.title })) { book in
                    Button(action: {
                        self.selectedBook = book
                        // Track all books section book selection
                        Analytics.logEvent("all_books_selected", parameters: [
                            "book_id": book.id,
                            "book_title": book.title,
                            "is_free": book.free,
                            "source": "all_books_section"
                        ])
                    }) {
                        Image(book.posterImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.top, 20)
    }
    
    private func checkAndShowConfetti() {
        let hasShownConfetti = UserDefaults.standard.bool(forKey: "hasShownSubscriptionConfetti")
        if userViewModel.isSubscriptionActive && !hasShownConfetti {
            confettiCounter += 1
            UserDefaults.standard.set(true, forKey: "hasShownSubscriptionConfetti")
        }
    }
    
    private func checkOnboardingStatus() {
        // Don't show onboarding if the user is already subscribed.
        if !userViewModel.isSubscriptionActive && completionService.shouldShowOnboarding() {
            showingOnboarding = true
        }
    }
    
    private func checkBookCompletionStatus() {
        if let userId = userViewModel.user?.id,
           let childId = selectedChildId ?? userViewModel.user?.children.first?.id {
            Task {
                await completionService.checkBookCompletionStatus(for: userId, childId: childId)
                
                // Check if creator support plea should be shown after book completion status update
                DispatchQueue.main.async {
                    self.creatorSupportPleaService.checkShouldShowPlea()
                }
            }
        }
    }
    
    private func refreshSubscriptionState() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            DispatchQueue.main.async {
                self.userViewModel.isSubscriptionActive = customerInfo.entitlements.all["Unlimited"]?.isActive == true
            }
        } catch {
            print("Error refreshing subscription state: \(error.localizedDescription)")
        }
    }
}

// Helper Views
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(Font.custom("LondrinaSolid-Light", size: 32))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 10)
    }
}

struct FakeSearchBarButton: View {
    @Binding var searchText: String
    @Binding var showingSearch: Bool
    
    var body: some View {
        Button(action: {
            print("DEBUG: Fake search bar tapped - opening search screen")
            showingSearch = true
        }) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                Text("Search storybooks")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
            }
            .padding(10)
            .background(Color.white)
            .cornerRadius(10)
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
        .allowsHitTesting(true)
        .highPriorityGesture(
            TapGesture()
                .onEnded { _ in
                    print("DEBUG: High priority tap on fake search bar")
                    showingSearch = true
                }
        )
        .onTapGesture {
            print("DEBUG: onTapGesture on fake search bar")
            showingSearch = true
        }
    }
}

struct SearchScreen: View {
    @Binding var searchText: String
    @Binding var isSearching: Bool
    let selectedChildId: String?
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextFieldFocused: Bool
    @State private var selectedBook: Book?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackgroundView()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Search Bar at top
                    searchBarSection
                    
                    // Search Results
                    if isSearching {
                        searchResultsSection
                    } else {
                        emptyStateSection
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            // Auto-focus the search field when the screen appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isTextFieldFocused = true
            }
        }
    }
    
    private var searchBarSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search storybooks", text: $searchText)
                .foregroundColor(.gray)
                .focused($isTextFieldFocused)
                .onChange(of: searchText) { newValue in
                    isSearching = !newValue.isEmpty
                }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(10)
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 20)
    }
    
    private var searchResultsSection: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150, maximum: 200))], spacing: 16) {
                ForEach(getFilteredBooks()) { book in
                    Button(action: {
                        selectedBook = book
                    }) {
                        VStack(spacing: 8) {
                            Image(book.posterImage)
                                .resizable()
                                .cornerRadius(10)
                                .aspectRatio(contentMode: .fit)
                                .padding(.horizontal, 8)
                            
                            Text(book.title)
                                .font(.caption)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 4)
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
        }
        .sheet(item: horizontalSizeClass == .compact ? $selectedBook : .constant(nil)) { book in
            BookDetailView(book: book,
                         dismissToRoot: {
                             selectedBook = nil
                         },
                         selectedChildId: selectedChildId)
        }
        .fullScreenCover(item: horizontalSizeClass == .regular ? $selectedBook : .constant(nil)) { book in
            BookDetailView(book: book,
                         dismissToRoot: {
                             selectedBook = nil
                         },
                         selectedChildId: selectedChildId)
        }
    }
    
    private var emptyStateSection: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.6))
            
            Text("Search for Books")
                .font(Font.custom("LondrinaSolid-Light", size: 28))
                .foregroundColor(.white)
            
            Text("Type to find your favorite stories")
                .font(Font.custom("LondrinaSolid-Light", size: 18))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
    
    private func getFilteredBooks() -> [Book] {
        guard !searchText.isEmpty else { return [] }
        return BookSection.sampleBooks.filter { book in
            let titleMatch = book.title.lowercased().contains(searchText.lowercased())
            let characterMatch = book.characters.contains { character in
                character.lowercased().contains(searchText.lowercased())
            }
            return titleMatch || characterMatch
        }
    }
}

struct SearchResultsSection: View {
    @Binding var searchText: String
    @Binding var isSearching: Bool
    @State private var selectedBook: Book?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let selectedChildId: String?
    
    var body: some View {
        VStack(spacing: 0) {
            // Back button to exit search
            HStack {
                Button(action: {
                    searchText = ""
                    isSearching = false
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                        Text("Back to Stories")
                            .font(Font.custom("LondrinaSolid-Light", size: 18))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(20)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150, maximum: 200))], spacing: 16) {
                ForEach(getFilteredBooks()) { book in
                    Button(action: {
                        self.selectedBook = book
                        // Track search result book selection
                        Analytics.logEvent("search_book_selected", parameters: [
                            "book_id": book.id,
                            "book_title": book.title,
                            "is_free": book.free,
                            "search_query": searchText,
                            "source": "search_results"
                        ])
                    }) {
                        VStack(spacing: 8) {
                            Image(book.posterImage)
                                .resizable()
                                .cornerRadius(10)
                                .aspectRatio(contentMode: .fit)
                                .padding(.horizontal, 8)
                            
                            // Show matching characters if the title doesn't match
                            if !book.title.lowercased().contains(searchText.lowercased()),
                               let matchingCharacter = book.characters.first(where: { 
                                   $0.lowercased().contains(searchText.lowercased())
                               }) {
                                Text("Features: \(matchingCharacter)")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 4)
                                    .padding(.bottom, 4)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
        }
        .sheet(item: horizontalSizeClass == .compact ? $selectedBook : .constant(nil)) { book in
            BookDetailView(book: book,
                         dismissToRoot: {
                             selectedBook = nil
                             searchText = ""
                             isSearching = false
                         },
                         selectedChildId: selectedChildId)
        }
        .fullScreenCover(item: horizontalSizeClass == .regular ? $selectedBook : .constant(nil)) { book in
            BookDetailView(book: book,
                         dismissToRoot: {
                             selectedBook = nil
                             searchText = ""
                             isSearching = false
                         },
                         selectedChildId: selectedChildId)
        }
    }
    
    private func getFilteredBooks() -> [Book] {
        guard !searchText.isEmpty else { 
            return [] 
        }
        let filteredBooks = BookSection.sampleBooks.filter { book in
            let titleMatch = book.title.lowercased().contains(searchText.lowercased())
            let characterMatch = book.characters.contains { character in
                character.lowercased().contains(searchText.lowercased())
            }
            return titleMatch || characterMatch
        }
        return filteredBooks
    }
}

struct FeaturedSection: View {
    let selectedChildId: String?
    @Binding var selectedBook: Book?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Featured Stories")
                .font(Font.custom("LondrinaSolid-Light", size: 32))
                .foregroundColor(.white)
                .padding(.horizontal)
            
            MainPromoScroller(selectedChildId: selectedChildId, selectedBook: $selectedBook)
        }
    }
}

struct ReadAloudSection: View {
    let videoStory: [Book] = Book.videoStory.shuffled()
    @State private var selectedBook: Book?
    @State private var showingVideo = false
    @State private var currentVideoURL: URL?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Read Aloud Stories")
                .font(Font.custom("LondrinaSolid-Light", size: 32))
                .foregroundColor(.white)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(videoStory) { book in
                        Button(action: {
                            self.selectedBook = book
                            if let url = videoURL(from: book.bookUrl) {
                                self.currentVideoURL = url
                                self.showingVideo = true
                            }
                        }) {
                            ZStack {
                                Image(book.posterImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .cornerRadius(10)
                                
                                Image(systemName: "play.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(
            Group {
                if let url = currentVideoURL {
                    FullScreenVideoPlayer(videoURL: url, presented: $showingVideo)
                }
            }
        )
    }
    
    private func videoURL(from videoName: String) -> URL? {
        if let videosURL = Bundle.main.url(forResource: "video", withExtension: nil) {
            let fileURL = videosURL.appendingPathComponent(videoName)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                return fileURL
            }
        }
        return Bundle.main.url(forResource: videoName, withExtension: nil)
    }
}

struct BookCollectionSection: View {
    @State private var selectedBook: Book?
    let selectedChildId: String?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("All Stories")
                .font(Font.custom("LondrinaSolid-Light", size: 32))
                .foregroundColor(.white)
                .padding(.horizontal)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150, maximum: 200))]) {
                ForEach(BookSection.sampleBooks) { book in
                    Button(action: {
                        self.selectedBook = book
                        // Track collection section book selection
                        Analytics.logEvent("collection_book_selected", parameters: [
                            "book_id": book.id,
                            "book_title": book.title,
                            "is_free": book.free,
                            "source": "collection_section"
                        ])
                    }) {
                        Image(book.posterImage)
                            .resizable()
                            .cornerRadius(10)
                            .aspectRatio(contentMode: .fit)
                            .padding()
                    }
                }
            }
            .sheet(item: $selectedBook) { book in
                BookDetailView(book: book,
                             dismissToRoot: { selectedBook = nil },
                             selectedChildId: selectedChildId)
            }
        }
    }
}

struct HomePageModifiers: ViewModifier {
    let horizontalSizeClass: UserInterfaceSizeClass?
    @Binding var isPaywallPresented: Bool
    @Binding var showingProfile: Bool
    @Binding var showingOnboarding: Bool
    @Binding var confettiCounter: Int
    let showingArtyView: Bool
    let completionService: BookCompletionService
    @Binding var selectedBook: Book?
    let selectedChildId: String?
    @Binding var selectedCollection: BookCollection?
    // @Binding var showingCharacterCreator: Bool // Character packs not live yet
    let userViewModel: UserViewModel
    let authService: AuthenticationService
    @Binding var showNotificationPrompt: Bool
    @Binding var showingSearch: Bool
    @Binding var searchText: String
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: horizontalSizeClass == .compact ? $isPaywallPresented : .constant(false)) {
                PaywallView(isPaywallPresented: $isPaywallPresented)
            }
            .fullScreenCover(isPresented: horizontalSizeClass == .regular ? $isPaywallPresented : .constant(false)) {
                PaywallView(isPaywallPresented: $isPaywallPresented)
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView()
                    .environmentObject(authService)
            }
            .fullScreenCover(isPresented: $showingOnboarding) {
                OnboardingCarouselView(isPresented: $showingOnboarding)
            }
            .confettiCannon(trigger: $confettiCounter,
                           num: 50,
                           openingAngle: Angle(degrees: 0),
                           closingAngle: Angle(degrees: 360),
                           radius: 200)
            .overlay(
                Group {
                    if showingArtyView {
                        ArtyView()
                            .transition(.move(edge: .trailing))
                            .animation(.spring(), value: showingArtyView)
                    }
                }
            )
            // Character pack unlock animation - not live yet
            /*
            .overlay(
                Group {
                    if let newlyUnlockedPack = completionService.newlyUnlockedPack {
                        UnlockAnimationView(pack: newlyUnlockedPack) {
                            completionService.clearNewlyUnlockedPack()
                        }
                    }
                }
            )
            */
            .sheet(item: horizontalSizeClass == .compact ? $selectedBook : .constant(nil)) { book in
                BookDetailView(book: book,
                             dismissToRoot: {
                                 selectedBook = nil
                             },
                             selectedChildId: selectedChildId)
            }
            .fullScreenCover(item: horizontalSizeClass == .regular ? $selectedBook : .constant(nil)) { book in
                BookDetailView(book: book,
                             dismissToRoot: {
                                 selectedBook = nil
                             },
                             selectedChildId: selectedChildId)
            }
            .fullScreenCover(item: $selectedCollection) { collection in
                CollectionDetailView(collection: collection)
            }
            // Character creator sheet - not live yet
            /*
            .sheet(isPresented: $showingCharacterCreator) {
                CharacterCreatorView()
                    .environmentObject(userViewModel)
            }
            */
            .sheet(isPresented: $showNotificationPrompt) {
                NotificationPermissionView()
            }
            .fullScreenCover(isPresented: $showingSearch) {
                SearchView(searchText: $searchText)
                    .environmentObject(userViewModel)
            }
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage(searchText: .constant(""))
            .environmentObject(UserViewModel())
    }
}

struct BookCollectionSection_Previews: PreviewProvider {
    static var previews: some View {
        BookCollectionSection(selectedChildId: nil)
    }
}


