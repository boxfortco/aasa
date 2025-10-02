//
//  CharacterTag.swift
//  BoxFort
//
//  Created by Matthew Ryan on 4/11/25.
//


//
//  BookDetailView.swift
//  Boxfort Plus
//
//  Created by Matthew Ryan on 9/2/22.
//

import SwiftUI
import StoreKit
import RevenueCat
import FirebaseAnalytics
import SwiftyGif

struct CharacterTag: View {
    let character: String
    let action: () -> Void
    
    private var sentenceCased: String {
        guard !character.isEmpty else { return "" }
        let firstChar = character.prefix(1).uppercased()
        let restOfString = character.dropFirst().lowercased()
        return firstChar + restOfString
    }
    
    var body: some View {
        Button(action: action) {
            Text(sentenceCased)
                .font(Font.custom("LondrinaSolid-Light", size: 18))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.6))
                .cornerRadius(20)
        }
    }
}

struct BookDetailView: View {
    let book: Book
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject var userViewModel: UserViewModel
    @StateObject private var loyaltyService = LoyaltyService.shared
    @StateObject private var completionService = BookCompletionService.shared
    @StateObject private var iapAnalytics = IAPAnalyticsService.shared
    @State private var isPaywallPresented = false
    @State private var isReadingBook = false
    @State private var selectedRelatedBook: Book?
    @State private var isPurchasing = false
    @State private var hasPassedParentalGate = false
    @State private var userAnswer = ""
    @State private var error: String?
    @State private var isLoading = false
    @State private var showError = false
    @State private var showParentalGate = false
    @State private var package: Package?
    @State private var isFavorited: Bool = false
    @State private var showProfileView = false
    @State private var showParticles = false
    @State private var particleScale: CGFloat = 0
    var onCharacterSelected: ((String) -> Void)?
    let dismissToRoot: (() -> Void)?
    let selectedChildId: String?
    @State private var showShareSheet = false
    @State private var shareImage: UIImage?
    @State private var hasPassedShareGate = false
    @State private var shareGateAnswer = ""
    @State private var showEnhancedShareSheet = false
    @State private var previewCard: StoryPreviewCard?
    @StateObject private var storyPreviewService = StoryPreviewService.shared
    var isFromOnboarding: Bool = false
    
    private var selectedChild: ChildProfile? {
        guard let user = userViewModel.user else { return nil }
        if let childId = selectedChildId {
            return user.children.first(where: { $0.id == childId })
        }
        return user.children.first
    }
    
    private func updateFavoriteStatus() {
        if let child = selectedChild {
            isFavorited = child.favorites.contains(book.id)
            print("DEBUG: Updated favorite status for book \(book.id): \(isFavorited)")
        } else {
            isFavorited = false
            print("DEBUG: No child selected, favorite status set to false")
        }
    }
    
    private func toggleFavorite() {
        if let childId = selectedChildId ?? selectedChild?.id {
            withAnimation {
                userViewModel.toggleFavorite(bookId: book.id, for: childId)
                updateFavoriteStatus()
            }
            Analytics.logEvent("book_favorite_toggled", parameters: [
                "book_id": book.id,
                "book_title": book.title,
                "is_favorited": isFavorited,
                "child_id": childId
            ])
        }
    }
    
    private var canAccessBook: Bool {
        if book.free {
            return true
        }
        
        return userViewModel.isSubscriptionActive || userViewModel.purchasedBooks.contains(book.id)
    }
    
    private var purchaseButtonText: String {
        if book.free {
            return "READ"
        } else if userViewModel.isSubscriptionActive {
            return "READ"
        } else if userViewModel.purchasedBooks.contains(book.id) {
            return "READ"
        } else if let price = purchasePrice {
            return "Preview \(book.previewPages) pages • Purchase for \(price)"
        } else {
            return "Preview \(book.previewPages) pages • Purchase"
        }
    }
    
    @State private var purchasePrice: String?
    
    private func fetchPrice() async {
        do {
            let offerings = try await Purchases.shared.offerings()
            if let booksOffering = offerings.offering(identifier: "books"),
               let package = booksOffering.availablePackages.first(where: { 
                   $0.storeProduct.productIdentifier == "book_\(book.id.lowercased())" 
               }) {
                await MainActor.run {
                    self.package = package
                }
            } else {
                print("DEBUG: Book product not found in 'books' offering")
            }
        } catch {
            print("DEBUG: Error fetching price: \(error.localizedDescription)")
        }
    }
    
    private func handleBookAccess() {
        if canAccessBook {
            self.isReadingBook = true
            // Award loyalty points for reading
            if let userId = userViewModel.user?.id {
                Task {
                    do {
                        try await loyaltyService.awardPointsForReading(userId: userId, bookId: book.id)
                    } catch {
                        print("Failed to award loyalty points: \(error.localizedDescription)")
                    }
                }
            }
            Analytics.logEvent("book_reading_started", parameters: [
                "book_id": book.id,
                "book_title": book.title,
                "access_type": userViewModel.isSubscriptionActive ? "subscription" : (book.free ? "free" : "purchased")
            ])
        } else {
            // Show parental gate for non-free books
            if !book.free {
                hasPassedParentalGate = true  // Set to true to trigger the sheet
                userAnswer = ""
            }
        }
    }
    
    private func purchaseBook() async {
        isLoading = true
        defer { isLoading = false }
        
        let bookProductId = "book_\(book.id.lowercased().replacingOccurrences(of: " ", with: ""))"
        
        // Track purchase attempt
        iapAnalytics.trackBookPurchaseAttempt(
            bookId: book.id,
            bookTitle: book.title,
            productId: bookProductId,
            price: package?.storeProduct.price ?? 0,
            currency: package?.storeProduct.currencyCode ?? "USD",
            source: "book_detail"
        )
        
        do {
            let offerings = try await Purchases.shared.offerings()
            guard let booksOffering = offerings.offering(identifier: "books") else {
                print("DEBUG: 'books' offering not found")
                showError = true
                error = "Unable to find book offering"
                
                iapAnalytics.trackIAPError(
                    errorType: "offering_not_found",
                    errorMessage: "Books offering not found",
                    productId: bookProductId,
                    source: "BookDetailView"
                )
                return
            }
            
            print("DEBUG: Looking for product \(bookProductId) in 'books' offering")
            
            guard let package = booksOffering.availablePackages.first(where: { 
                $0.storeProduct.productIdentifier == bookProductId 
            }) else {
                print("DEBUG: Book product not found in 'books' offering")
                showError = true
                error = "Book product not available"
                
                iapAnalytics.trackIAPError(
                    errorType: "product_not_found",
                    errorMessage: "Book product not found in offering",
                    productId: bookProductId,
                    source: "BookDetailView"
                )
                return
            }
            
            print("DEBUG: Found book package, attempting purchase")
            let result = try await Purchases.shared.purchase(package: package)
            
            // Check both entitlements and transactions to verify purchase
            let isPurchased = result.customerInfo.entitlements["Unlimited"]?.isActive == true || 
                            result.transaction?.productIdentifier == bookProductId
            
            if isPurchased {
                print("DEBUG: Purchase successful")
                await MainActor.run {
                    userViewModel.purchasedBooks.insert(book.id)
                    userViewModel.savePurchasedBooks() // Ensure we save the purchase
                    showParentalGate = false
                    isReadingBook = true
                    hasPassedParentalGate = false // Reset gate state
                }
                
                // Track successful purchase
                iapAnalytics.trackBookPurchase(
                    bookId: book.id,
                    bookTitle: book.title,
                    productId: bookProductId,
                    price: package.storeProduct.price,
                    currency: package.storeProduct.currencyCode ?? "USD",
                    source: "book_detail"
                )
            } else {
                print("DEBUG: Purchase unsuccessful")
                showError = true
                error = "Purchase was unsuccessful"
                
                iapAnalytics.trackBookPurchaseFailure(
                    bookId: book.id,
                    bookTitle: book.title,
                    productId: bookProductId,
                    error: "Purchase verification failed",
                    source: "book_detail"
                )
            }
        } catch {
            print("DEBUG: Purchase error: \(error.localizedDescription)")
            showError = true
            self.error = error.localizedDescription
            
            iapAnalytics.trackBookPurchaseFailure(
                bookId: book.id,
                bookTitle: book.title,
                productId: bookProductId,
                error: error.localizedDescription,
                source: "book_detail"
            )
        }
    }
    
    private var errorBanner: some View {
        Group {
            if let error = error {
                VStack {
                    Text(error)
                        .font(Font.custom("LondrinaSolid-Light", size: 18))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color.white, lineWidth: 2)
                        )
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(1)
                .animation(.easeInOut(duration: 0.3), value: error)
            }
        }
    }
    
    private func generatePreviewCard() async {
        let card = await storyPreviewService.generatePreviewCard(for: book)
        await MainActor.run {
            self.previewCard = card
        }
        Analytics.logEvent("book_shared", parameters: [
            "book_id": book.id,
            "book_title": book.title,
            "share_type": "enhanced_preview"
        ])
    }
    
    private func shareBook() {
        hasPassedShareGate = true
        shareGateAnswer = ""
    }
    
    var body: some View {
        mainContent
            .edgesIgnoringSafeArea(.all)
            .sheet(isPresented: horizontalSizeClass == .compact ? $isPaywallPresented : .constant(false)) {
                PaywallView(isPaywallPresented: $isPaywallPresented)
                    .interactiveDismissDisabled(false)
            }
            .fullScreenCover(isPresented: horizontalSizeClass == .regular ? $isPaywallPresented : .constant(false)) {
                PaywallView(isPaywallPresented: $isPaywallPresented)
                    .interactiveDismissDisabled(false)
            }
            .sheet(isPresented: $showProfileView) {
                ProfileView()
                    .interactiveDismissDisabled()
            }
            .fullScreenCover(isPresented: $isReadingBook) {
                BookView(book: book, isPresented: $isReadingBook, selectedChildId: selectedChildId, isFromOnboarding: isFromOnboarding)
                    .edgesIgnoringSafeArea(.all)
                    .onDisappear {
                        // If this was from onboarding and the book view was dismissed, complete onboarding
                        if isFromOnboarding {
                            completionService.markOnboardingComplete()
                            if let dismissToRoot = dismissToRoot {
                                dismissToRoot()
                            }
                        }
                    }
            }
            .sheet(item: horizontalSizeClass == .compact ? $selectedRelatedBook : .constant(nil)) { book in
                BookDetailView(book: book,
                             dismissToRoot: {
                                 selectedRelatedBook = nil
                             },
                             selectedChildId: selectedChildId)
            }
            .fullScreenCover(item: horizontalSizeClass == .regular ? $selectedRelatedBook : .constant(nil)) { book in
                BookDetailView(book: book,
                             dismissToRoot: {
                                 selectedRelatedBook = nil
                             },
                             selectedChildId: selectedChildId)
            }
            .interactiveDismissDisabled(true)
            .onAppear(perform: onAppearAction)
            .onReceive(userViewModel.$user) { _ in
                updateFavoriteStatus()
            }
            .sheet(isPresented: $hasPassedParentalGate) {
                ParentalGateView(userAnswer: $userAnswer, completion: { correctAnswer in
                    if correctAnswer {
                        Task {
                            await purchaseBook()
                        }
                    }
                    hasPassedParentalGate = false  // Reset after completion
                })
                .presentationBackground(.ultraThinMaterial)
                .presentationCornerRadius(0)
                .presentationDragIndicator(.hidden)
                .interactiveDismissDisabled()
            }
            .sheet(isPresented: $hasPassedShareGate) {
                shareGateSheet
            }
            .sheet(isPresented: $showShareSheet) {
                if let image = shareImage {
                    ShareSheet(activityItems: [
                        image,
                        "Check out \(book.title) on BoxFort! Download the app: https://apps.apple.com/us/app/boxfort-kids-books/id6443570027"
                    ])
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .ignoresSafeArea()
                }
            }
            .sheet(isPresented: $showEnhancedShareSheet) {
                if let card = previewCard {
                    EnhancedShareSheet(previewCard: card)
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                        .ignoresSafeArea()
                }
            }
            .onChange(of: previewCard) { newCard in
                if newCard != nil {
                    showEnhancedShareSheet = true
                }
            }
    }
    
    // MARK: - Main Content
    
    private var mainContent: some View {
        ZStack {
            GradientBackgroundView()
            
            if horizontalSizeClass == .regular {
                iPadLayout
            } else {
                iPhoneLayout
            }
        }
    }
    
    // MARK: - Share Gate Sheet
    
    private var shareGateSheet: some View {
        ZStack(alignment: .topTrailing) {
            ParentalGateView(userAnswer: $shareGateAnswer, completion: { correctAnswer in
                if correctAnswer {
                    Task {
                        await generatePreviewCard()
                    }
                }
                hasPassedShareGate = false
            })
            
            // Close button
            HStack {
                Spacer()
                Button(action: {
                    if let dismissToRoot = dismissToRoot {
                        dismissToRoot()
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white.opacity(0.8))
                        .padding()
                }
            }
            .padding(.top, 16)
        }
        .presentationBackground(.ultraThinMaterial)
        .presentationCornerRadius(0)
        .presentationDragIndicator(.hidden)
        .interactiveDismissDisabled(false)
    }
    
    // MARK: - On Appear Action
    
    private func onAppearAction() {
        updateFavoriteStatus()
        
        // Verify purchase status
        if userViewModel.purchasedBooks.contains(book.id) {
            print("DEBUG: Book \(book.id) is already purchased")
        }
        
        // Fetch price from RevenueCat
        Task {
            await fetchPrice()
        }
        
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: "BookDetail",
            AnalyticsParameterScreenClass: String(describing: BookDetailView.self),
            "book_id": book.id,
            "book_title": book.title,
            "is_free": book.free,
            "is_subscribed": userViewModel.isSubscriptionActive,
            "is_purchased": userViewModel.purchasedBooks.contains(book.id)
        ])
    }
    
    // MARK: - Layout Components
    
    private var iPadLayout: some View {
        HStack(spacing: 0) {
            // Left side - Book cover
            VStack {
                SwiftyGifView(imageName: book.posterImage)
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(10)
                    .padding()
            }
            .frame(width: UIScreen.main.bounds.width * 0.4)
            
            // Right side - Details
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    navigationButtons
                    titleAndDetails
                    actionButtons
                    relatedBooksSection
                }
                .padding(40)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private var iPhoneLayout: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading) {
                ZStack(alignment: .top) {
                    SwiftyGifView(imageName: book.promoImage)
                        .aspectRatio(contentMode: .fill)
                    
                    HStack {
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(Color.white.opacity(0.8))
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(book.title)
                        .font(Font.custom("LondrinaSolid-Light", size: 38))
                        .foregroundColor(.white)
                    
                    Text(book.details)
                        .foregroundColor(.white)
                        .font(Font.custom("LondrinaSolid-Light", size: 22))
                    
                    actionButtons
                    
                    Text("Related Books")
                        .font(Font.custom("LondrinaSolid-Light", size: 24))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(relatedBooks(for: book), id: \.id) { relatedBook in
                                Button(action: {
                                    selectedRelatedBook = relatedBook
                                }) {
                                    SwiftyGifView(imageName: relatedBook.posterImage)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 150)
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    private var navigationButtons: some View {
        HStack {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                HStack {
                    Image(systemName: "chevron.backward")
                    Text("Back")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(12)
                .background(Color.blue.opacity(0.6))
                .cornerRadius(10)
            }
            
            Spacer()
            
            Button(action: {
                dismissToRoot?()
            }) {
                HStack {
                    Image(systemName: "house.fill")
                    Text("Back to Home")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(12)
                .background(Color.blue.opacity(0.6))
                .cornerRadius(10)
            }
        }
        .padding(.top, 40)
        .padding(.horizontal, 20)
    }
    
    private var titleAndDetails: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(book.title)
                .font(Font.custom("LondrinaSolid-Light", size: 48))
                .foregroundColor(.white)
                .padding(.bottom, 8)
            
            // Character tags
            if !book.characters.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Featured Characters")
                        .font(Font.custom("LondrinaSolid-Light", size: 24))
                        .foregroundColor(.white.opacity(0.8))
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(book.characters, id: \.self) { character in
                                CharacterTag(character: character) {
                                    onCharacterSelected?(character)
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            
            Text(book.details)
                .foregroundColor(.white)
                .font(Font.custom("LondrinaSolid-Light", size: 24))
                .lineSpacing(8)
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            if hasPassedParentalGate {
                purchaseButton
            } else {
                if !canAccessBook {
                    purchaseButton
                    sampleButton
                }
                
                if canAccessBook {
                    readButton
                }
            }
            
            errorBanner

            if !book.free && !userViewModel.isSubscriptionActive {
                subscribeButton
            }
            
            HStack {
                Spacer()
                favoriteButton
                Spacer()
                shareButton
                Spacer()
            }
        }
        .padding(.top, 20)
    }
    
    private var purchaseButton: some View {
        Button(action: {
            if hasPassedParentalGate {
                Task {
                    await purchaseBook()
                }
            } else {
                hasPassedParentalGate = true
            }
        }) {
            HStack {
                if isPurchasing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(purchasePrice != nil ? "Purchase for \(purchasePrice!)" : "Purchase")
                        .font(Font.custom("LondrinaSolid-Light", size: 24))
                }
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.red)
            .cornerRadius(15)
        }
        .disabled(isPurchasing)
    }
    
    private var sampleButton: some View {
        Button(action: {
            isReadingBook = true
        }) {
            Text("Sample")
                .font(Font.custom("LondrinaSolid-Light", size: 24))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .cornerRadius(15)
        }
    }
    
    private var readButton: some View {
        Button(action: {
            isReadingBook = true
        }) {
            Text("Read")
                .font(Font.custom("LondrinaSolid-Light", size: 24))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(15)
        }
    }
    
    private var subscribeButton: some View {
        Button(action: {
            isPaywallPresented = true
        }) {
            HStack {
                Text("Subscribe to Unlock All Books")
                    .font(Font.custom("LondrinaSolid-Light", size: 20))
                Image(systemName: "arrow.right.circle.fill")
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue.opacity(0.6))
            .cornerRadius(15)
        }
    }
    
    private var favoriteButton: some View {
        ZStack {
            Button(action: {
                if userViewModel.user != nil {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isFavorited.toggle()
                        showParticles = true
                        particleScale = 1
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.easeOut(duration: 0.2)) {
                            particleScale = 0
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showParticles = false
                    }
                    toggleFavorite()
                } else {
                    showProfileView = true
                }
            }) {
                VStack(spacing: 4) {
                    Image(systemName: isFavorited ? "heart.fill" : "heart")
                        .foregroundColor(.red)
                        .font(.system(size: 30))
                        .padding(12)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                    
                    if userViewModel.user == nil {
                        Text("Sign in to favorite")
                            .font(Font.custom("LondrinaSolid-Light", size: 12))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if showParticles {
                ForEach(0..<8) { index in
                    Circle()
                        .fill(Color.red.opacity(0.6))
                        .frame(width: 4, height: 4)
                        .offset(
                            x: cos(CGFloat(index) * .pi / 4) * 20 * particleScale,
                            y: sin(CGFloat(index) * .pi / 4) * 20 * particleScale
                        )
                        .opacity(1 - particleScale)
                }
            }
        }
    }
    
    private var shareButton: some View {
        Button(action: shareBook) {
            VStack(spacing: 4) {
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(.blue)
                    .font(.system(size: 30))
                    .padding(12)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
                
                Text("Share")
                    .font(Font.custom("LondrinaSolid-Light", size: 12))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var relatedBooksSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Related Books")
                .font(Font.custom("LondrinaSolid-Light", size: 32))
                .foregroundColor(.white)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 180, maximum: 220))], spacing: 20) {
                ForEach(relatedBooks(for: book), id: \.id) { relatedBook in
                    Button(action: {
                        selectedRelatedBook = relatedBook
                    }) {
                        VStack {
                            SwiftyGifView(imageName: relatedBook.posterImage)
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(10)
                            
                            Text(relatedBook.title)
                                .font(Font.custom("LondrinaSolid-Light", size: 16))
                                .foregroundColor(.white)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
            }
        }
        .padding(.top, 20)
    }
    
    func relatedBooks(for book: Book, count: Int = 4) -> [Book] {
        return BookSection.sampleBooks.filter { $0.id != book.id }.prefix(count).map { $0 }
    }
}

struct PurchaseView: View {
    let book: Book
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var isPurchasing = false
    @State private var error: String?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Purchase \(book.title)")
                .font(.title2)
                .bold()
            
            Text("Get unlimited access to this storybook")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if let error = error {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button(action: {
                Task {
                    await purchaseBook()
                }
            }) {
                if isPurchasing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Purchase for $\(book.price, specifier: "%.2f")")
                        .bold()
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isPurchasing)
            
            Button("Cancel", role: .cancel) {
                dismiss()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
    
    private func purchaseBook() async {
        isPurchasing = true
        error = nil
        
        do {
            // Get the product from RevenueCat
            let offerings = try await Purchases.shared.offerings()
            
            // Find the specific book product
            let bookProductId = "book_\(book.id.lowercased().replacingOccurrences(of: " ", with: ""))"
            guard let package = offerings.current?.availablePackages.first(where: { $0.identifier == bookProductId }) else {
                error = "Product not available"
                isPurchasing = false
                return
            }
            
            let result = try await Purchases.shared.purchase(package: package)
            
            // Check if the purchase was successful
            if result.customerInfo.entitlements["Unlimited"]?.isActive == true {
                // Update local state
                userViewModel.purchasedBooks.insert(book.id)
                userViewModel.savePurchasedBooks()
                
                // Log purchase event
                Analytics.logEvent("book_purchased", parameters: [
                    "book_id": book.id,
                    "book_title": book.title,
                    "price": book.price
                ])
                
                dismiss()
            } else {
                error = "Purchase failed. Please try again."
            }
        } catch {
            self.error = error.localizedDescription
        }
        
        isPurchasing = false
    }
}

// AnimatedImage implementation
struct AnimatedImage: UIViewRepresentable {
    let name: String?
    let data: Data?
    
    init(name: String) {
        self.name = name
        self.data = nil
    }
    
    init(data: Data) {
        self.data = data
        self.name = nil
    }
    
    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {
        if let data = data {
            uiView.image = UIImage.gifImageWithData(data)
        } else if let name = name {
            uiView.image = UIImage.gifImageWithName(name)
        }
    }
}

// UIImage extension for GIF support
extension UIImage {
    class func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        return UIImage.animatedImageWithSource(source)
    }
    
    class func gifImageWithName(_ name: String) -> UIImage? {
        guard let bundleURL = Bundle.main.url(forResource: name, withExtension: "gif") else { return nil }
        guard let imageData = try? Data(contentsOf: bundleURL) else { return nil }
        return gifImageWithData(imageData)
    }
    
    class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            let delaySeconds = UIImage.delayForImageAtIndex(Int(i), source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Convert to milliseconds
        }
        
        let duration: Int = {
            var sum = 0
            for delay in delays { sum += delay }
            return sum
        }()
        
        let gcd = delays.reduce(0) { gcd, value in UIImage.gcdForPair(abs(gcd), value) }
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        let animation = UIImage.animatedImage(with: frames,
                                            duration: Double(duration) / 1000.0)
        return animation
    }
    
    class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionary = unsafeBitCast(CFDictionaryGetValue(cfProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()), to: CFDictionary.self)
        
        var delayObject: AnyObject = unsafeBitCast(CFDictionaryGetValue(gifProperties, Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()), to: AnyObject.self)
        
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        delay = delayObject as? Double ?? 0
        if delay < 0.1 { delay = 0.1 }
        
        return delay
    }
    
    class func gcdForPair(_ a: Int, _ b: Int) -> Int {
        var a = a
        var b = b
        if b == 0 { return a }
        while true {
            let r = a % b
            if r == 0 { return b }
            a = b
            b = r
        }
    }
}

// MARK: - Book Collection Models and Views

struct BookCollection: Identifiable {
    let id: String
    let title: String
    let description: String
    let coverImage: String
    let headerImage: String
    let books: [Book]
    let theme: CollectionTheme
    
    enum CollectionTheme {
        case makeamess
        case figureitout
        case authorfavorites
    }
}

struct CollectionCard: View {
    let collection: BookCollection
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Image(collection.coverImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 160, height: 240)
                    .cornerRadius(20)
                    .shadow(radius: 5)
                
                Text(collection.title)
                    .font(Font.custom("LondrinaSolid-Light", size: 18))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .frame(width: 160, alignment: .leading)
            }
        }
    }
}

struct CollectionDetailView: View {
    let collection: BookCollection
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var selectedBook: Book? = nil
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            GradientBackgroundView()
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header image, always fits device width
                    Image(collection.headerImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width, height: 340)
                        .clipped()
                    
                    // Big collection name and description
                    let screenWidth = UIScreen.main.bounds.width
                    let dynamicFontSize = min(72, screenWidth * 0.12)
                    VStack(alignment: .leading, spacing: 16) {
                        Text(collection.title)
                            .font(.system(size: dynamicFontSize, weight: .thin))
                            .foregroundColor(.white)
                            .padding(.top, 32)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        if !collection.description.isEmpty {
                            Text(collection.description)
                                .font(Font.custom("LondrinaSolid-Light", size: 28))
                                .foregroundColor(.white.opacity(0.85))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                    .frame(maxWidth: 900, alignment: .leading)
                    
                    // Book grid
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 180, maximum: 240), spacing: 32)
                    ], spacing: 32) {
                        ForEach(collection.books) { book in
                            Button(action: {
                                selectedBook = book
                                // Track collection detail book selection
                                Analytics.logEvent("collection_detail_book_selected", parameters: [
                                    "book_id": book.id,
                                    "book_title": book.title,
                                    "is_free": book.free,
                                    "collection_name": collection.title,
                                    "source": "collection_detail"
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
                    .padding(.bottom, 40)
                }
                .frame(maxWidth: .infinity) // Constrain all content to screen width
            }
            // Back button pinned to top left
            Button(action: { dismiss() }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Back to Stories")
                }
                .font(Font.custom("LondrinaSolid-Light", size: 18))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.3))
                .cornerRadius(20)
                .shadow(radius: 2)
            }
            .padding(.top, 24)
            .padding(.leading, 20)
        }
        .sheet(item: horizontalSizeClass == .compact ? $selectedBook : .constant(nil)) { book in
            BookDetailView(book: book, dismissToRoot: { selectedBook = nil }, selectedChildId: nil)
                .environmentObject(userViewModel)
        }
        .fullScreenCover(item: horizontalSizeClass == .regular ? $selectedBook : .constant(nil)) { book in
            BookDetailView(book: book, dismissToRoot: { selectedBook = nil }, selectedChildId: nil)
                .environmentObject(userViewModel)
        }
    }
}

// Sample Collections
extension BookCollection {
    static let sampleCollections: [BookCollection] = [
        BookCollection(
            id: "makeamess",
            title: "Make a Mess",
            description: "Sometimes the gang can get into all kinds of sticky situations.",
            coverImage: "makeamess_collection",
            headerImage: "makeamess_header",
            books: BookSection.sampleBooks.filter {
                let title = $0.title.lowercased()
                return title.contains("spot of bother") ||
                    title.contains("bubblegum") ||
                    title.contains("tastrophe") ||
                    title.contains("big blueberry") ||
                    title.contains("very hairy little") ||
                    title.contains("surprise")
            },
            theme: .makeamess
        ),
        BookCollection(
            id: "figureitout",
            title: "Figure It Out",
            description: "More often that not, the best way to figure something out will involve a bagel.",
            coverImage: "figureitout_collection",
            headerImage: "figureitout_header",
            books: BookSection.sampleBooks.filter {
                let title = $0.title.lowercased()
                return title.contains("fireworks") ||
                    title.contains("footprints") ||
                    title.contains("found a something") ||
                    title.contains("something to do with") ||
                    title.contains("expert") ||
                    title.contains("impossible door")
            },
            theme: .figureitout
        ),
        BookCollection(
            id: "authorfavorites",
            title: "Author Favorites",
            description: "My own personal favorite storybooks.",
            coverImage: "authorfavorites_collection",
            headerImage: "authorfavorites_header",
            books: BookSection.sampleBooks.filter {
                let title = $0.title.lowercased()
                return title.contains("impossible door") ||
                    title.contains("the box") ||
                    title.contains("big blueberry") ||
                    title.contains("costume party") ||
                    title.contains("bubblegum") ||
                    title.contains("case of the missing")
            },
            theme: .authorfavorites
        )
    ]
}



