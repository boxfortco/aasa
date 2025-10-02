//
//  BookView.swift
//  BoxFort
//
//  Created by Matthew Ryan on 4/11/25.
//


//
//  BookView.swift
//  Boxfort Plus
//
//  Created by Matthew Ryan on 9/3/22.
//

import SwiftUI
import FirebaseAnalytics
import SwiftyGif
import FirebaseFirestore
import StoreKit

struct BookView: View {
    @StateObject private var viewModel = BookViewModel()
    @StateObject private var completionService = BookCompletionService.shared
    @StateObject private var reviewService = ReviewService.shared
    @StateObject private var bookAnalytics = BookAnalyticsService.shared
    var book: Book
    @Binding var isPresented: Bool
    let selectedChildId: String?
    @State private var currentPage = 0
    @State private var readPercentage: Double = 0
    @State private var showThumbnails = false
    @State private var forceSinglePage = false
    @State private var hasLoggedCompletion = false
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var showPaywall = false
    @State private var sessionStartTime = Date()
    @State private var sessionId = UUID().uuidString
    @State private var isFirstTimeReading = false
    @State private var showReadTogether = false
    @State private var readTogetherSessionId: String?
    @State private var isReadTogetherActive = false
    
    // New parameter to detect if this is from onboarding
    var isFromOnboarding: Bool = false
    
    private var selectedChild: ChildProfile? {
        guard let user = userViewModel.user else { return nil }
        if let childId = selectedChildId {
            return user.children.first(where: { $0.id == childId })
        }
        return user.children.first
    }
    
    private var isDualPageMode: Bool {
        return sizeClass == .regular && !forceSinglePage && !isReadTogetherActive
    }
    
    private var isPreviewMode: Bool {
        return !book.free && !userViewModel.isSubscriptionActive && !userViewModel.purchasedBooks.contains(book.id)
    }
    
    private var canReadMore: Bool {
        if !isPreviewMode {
            return true
        }
        return currentPage < book.previewPages
    }
    
    private var isCompleted: Bool {
        readPercentage >= 100
    }
    
    private func pageView(_ imageName: String, geometry: GeometryProxy) -> some View {
        let thumbnailHeight: CGFloat = showThumbnails ? 80 : 0
        let controlsHeight: CGFloat = 60 // Height for top controls
        let readingBuddyHeight: CGFloat = isCompleted ? 0 : 60 // Height for Reading Buddy
        let availableHeight = geometry.size.height - thumbnailHeight - controlsHeight - readingBuddyHeight
        let pageWidth = isDualPageMode ? geometry.size.width / 2 : geometry.size.width
        
        return ImageView(imageName: imageName)
            .frame(maxWidth: pageWidth, maxHeight: availableHeight)
            .aspectRatio(contentMode: .fit)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                ColorConstants.bookBackground
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Top controls
                    HStack {
                        Button(action: {
                            isPresented = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        .padding()
                        
                        Spacer()
                        
                        if sizeClass == .regular {
                            Button(action: {
                                withAnimation {
                                    forceSinglePage.toggle()
                                    if !forceSinglePage {
                                        currentPage = currentPage - (currentPage % 2)
                                    }
                                }
                            }) {
                                Image(systemName: forceSinglePage ? "rectangle.portrait" : "rectangle.split.2x1")
                                    .font(.title)
                                    .foregroundColor(isReadTogetherActive ? .gray : .white)
                            }
                            .disabled(isReadTogetherActive)
                            .padding()
                        }
                        
                        Button(action: {
                            withAnimation {
                                showThumbnails.toggle()
                            }
                        }) {
                            Image(systemName: showThumbnails ? "rectangle.grid.1x2.fill" : "rectangle.grid.1x2")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        .padding()
                        
                        // Read Together Button - Only for subscribers
                        if userViewModel.isSubscriptionActive {
                            Button(action: {
                                showReadTogether = true
                            }) {
                                Image(systemName: "person.2.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                            .padding()
                        }
                    }
                    .frame(height: 60)
                    .padding(.top, 44)
                    
                    // Reading Buddy - Minimal in-app reading indicator
                    if !isCompleted {
                        ReadingBuddyView(
                            currentPage: currentPage + 1, // Show 1-based page numbers
                            totalPages: book.pages.count,
                            bookTitle: book.title,
                            characterName: "patrick"
                        )
                        .padding(.horizontal, 16)
                        .padding(.bottom, 4)
                    }
                    
                    // Read Together Status Indicator
                    if isReadTogetherActive {
                        VStack(spacing: 4) {
                            HStack {
                                Image(systemName: "person.2.fill")
                                    .foregroundColor(.green)
                                Text("Reading Together Active")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                            
                            if sizeClass == .regular {
                                Text("Single-page mode for better sync")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 4)
                    }
                    
                    // Book Content
                    TabView(selection: $currentPage) {
                        ForEach(0..<book.pages.count, id: \.self) { index in
                            if isDualPageMode && index % 2 == 0 {
                                HStack(spacing: 0) {
                                    pageView(book.pages[index], geometry: geometry)
                                    if index + 1 < book.pages.count {
                                        pageView(book.pages[index + 1], geometry: geometry)
                                    }
                                }
                                .tag(index)
                            } else if !isDualPageMode {
                                pageView(book.pages[index], geometry: geometry)
                                    .tag(index)
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .onChange(of: currentPage) { newPage in
                        // Sync page changes to Read Together session if active
                        if isReadTogetherActive, let sessionId = readTogetherSessionId {
                            ReadTogetherSessionManager.shared.updatePage(sessionId: sessionId, page: newPage)
                        }
                        if isPreviewMode && newPage >= book.previewPages {
                            showPaywall = true
                            currentPage = book.previewPages - 1
                        }
                        updateReadPercentage()
                    }
                    
                    // Thumbnails
                    if showThumbnails {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(Array(book.pages.enumerated()), id: \.element) { index, page in
                                    Button(action: {
                                        if isDualPageMode {
                                            currentPage = index - (index % 2)
                                        } else {
                                            currentPage = index
                                        }
                                    }) {
                                        ImageView(imageName: page)
                                            .frame(height: 60)
                                            .cornerRadius(4)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 4)
                                                    .stroke(currentPage == (isDualPageMode ? (index - index % 2) : index) ? Color.blue : Color.clear, lineWidth: 2)
                                            )
                                    }
                                    .disabled(isPreviewMode && index >= book.previewPages)
                                }
                            }
                            .padding()
                        }
                        .frame(height: 80)
                        .background(Color.black.opacity(0.7))
                    }
                }
            }
        }
        .onChange(of: currentPage) { _ in
            updateReadPercentage()
        }
        .onAppear {
            // Log the screen view with book details
            Analytics.logEvent(AnalyticsEventScreenView, parameters: [
                AnalyticsParameterScreenName: "Book View",
                AnalyticsParameterScreenClass: String(describing: BookView.self),
                "book_id": book.id,
                "book_title": book.title,
                "is_free": book.free,
                "is_subscribed": userViewModel.isSubscriptionActive,
                "is_purchased": userViewModel.purchasedBooks.contains(book.id),
                "is_from_onboarding": isFromOnboarding,
                "total_pages": book.pages.count,
                "preview_pages": book.previewPages
            ])
            
            // Track reading session start
            sessionStartTime = Date()
            sessionId = UUID().uuidString
            
            // Check if this is first time reading this book
            isFirstTimeReading = !completionService.hasCompletedBook(book.id)
            
            // Track book view
            bookAnalytics.trackBookView(
                bookId: book.id,
                bookTitle: book.title,
                source: isFromOnboarding ? "onboarding" : "normal",
                isFree: book.free,
                totalPages: book.pages.count
            )
            
            // Track reading session start
            bookAnalytics.trackReadingSessionStart(
                bookId: book.id,
                bookTitle: book.title,
                sessionId: sessionId,
                isFree: book.free
            )
            
            // Track unique reader if first time
            if isFirstTimeReading, let userId = userViewModel.user?.id {
                bookAnalytics.trackUniqueReader(
                    bookId: book.id,
                    bookTitle: book.title,
                    userId: userId
                )
            } else if !isFirstTimeReading, let userId = userViewModel.user?.id {
                // Track re-read
                let readCount = UserDefaults.standard.integer(forKey: "read_count_\(book.id)")
                bookAnalytics.trackBookReread(
                    bookId: book.id,
                    bookTitle: book.title,
                    userId: userId,
                    readCount: readCount + 1
                )
            }
        }
        .onDisappear {
            // Track reading session end
            let timeSpent = Date().timeIntervalSince(sessionStartTime)
            let isCompleted = readPercentage >= 100
            
            bookAnalytics.trackReadingSessionEnd(
                bookId: book.id,
                bookTitle: book.title,
                sessionId: sessionId,
                timeSpentSeconds: timeSpent,
                pagesRead: currentPage + 1,
                totalPages: book.pages.count,
                isCompleted: isCompleted
            )
            
            // Save reading session to Firestore
            if let userId = userViewModel.user?.id {
                bookAnalytics.saveReadingSession(
                    bookId: book.id,
                    bookTitle: book.title,
                    userId: userId,
                    sessionId: sessionId,
                    startTime: sessionStartTime,
                    endTime: Date(),
                    pagesRead: currentPage + 1,
                    totalPages: book.pages.count,
                    isCompleted: isCompleted,
                    posterImage: book.posterImage
                )
            }
            
            // Track abandonment if not completed
            if !isCompleted && timeSpent > 30 { // Only track if spent more than 30 seconds
                bookAnalytics.trackBookAbandonment(
                    bookId: book.id,
                    bookTitle: book.title,
                    lastPageRead: currentPage + 1,
                    totalPages: book.pages.count,
                    timeSpentSeconds: timeSpent
                )
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(isPaywallPresented: $showPaywall)
        }
        .sheet(isPresented: $showReadTogether) {
            ReadTogetherView(
                book: book, 
                isPresented: $showReadTogether,
                sessionId: $readTogetherSessionId,
                isActive: $isReadTogetherActive
            )
            .environmentObject(userViewModel)
        }

    }
    
    private func updateReadPercentage() {
        readPercentage = Double(currentPage + 1) / Double(book.pages.count) * 100
        
        // Store reading progress in Firestore
        if let userId = userViewModel.user?.id,
           let childId = selectedChild?.id {
            let db = Firestore.firestore()
            let progressData: [String: Any] = [
                "userId": userId,
                "childId": childId,
                "bookId": book.id,
                "currentPage": currentPage,
                "totalPages": book.pages.count,
                "percentage": readPercentage,
                "timestamp": FieldValue.serverTimestamp(),
                "completed": readPercentage >= 100
            ]
            
            db.collection("reading_progress").addDocument(data: progressData) { error in
                if let error = error {
                    print("Error saving reading progress: \(error.localizedDescription)")
                }
            }
        }
        
        // Log reading progress at key milestones
        if readPercentage >= 25 && readPercentage < 26 {
            let parameters: [String: Any] = [
                "book_id": book.id,
                "book_title": book.title,
                "progress_percentage": 25
            ]
            Analytics.logEvent("book_reading_progress", parameters: parameters)
            print("📊 Book Analytics: Progress 25% - \(book.title)")
            print("📊 Book Analytics: Parameters: \(parameters)")
        } else if readPercentage >= 50 && readPercentage < 51 {
            let parameters: [String: Any] = [
                "book_id": book.id,
                "book_title": book.title,
                "progress_percentage": 50
            ]
            Analytics.logEvent("book_reading_progress", parameters: parameters)
            print("📊 Book Analytics: Progress 50% - \(book.title)")
            print("📊 Book Analytics: Parameters: \(parameters)")
        } else if readPercentage >= 75 && readPercentage < 76 {
            let parameters: [String: Any] = [
                "book_id": book.id,
                "book_title": book.title,
                "progress_percentage": 75
            ]
            Analytics.logEvent("book_reading_progress", parameters: parameters)
            print("📊 Book Analytics: Progress 75% - \(book.title)")
            print("📊 Book Analytics: Parameters: \(parameters)")
        }
        
        // Log completion when reaching the end
        if readPercentage >= 100 && !hasLoggedCompletion {
            hasLoggedCompletion = true
            let parameters: [String: Any] = [
                "book_id": book.id,
                "book_title": book.title,
                "total_pages": book.pages.count
            ]
            Analytics.logEvent("book_reading_completed", parameters: parameters)
            print("📊 Book Analytics: Book completed - \(book.title)")
            print("📊 Book Analytics: Parameters: \(parameters)")
            markBookAsRead()
            
            // Mark book as completed in BookCompletionService
            Task {
                await completionService.markBookAsCompleted(
                    bookId: book.id,
                    userId: userViewModel.user?.id,
                    childId: selectedChild?.id
                )
            }
            
            // Check for review prompt after book completion
            reviewService.checkForReviewPrompt(afterBookCompletion: book.id)
            
            
            // Note: Paywall removed from onboarding flow - users can complete onboarding without being prompted to subscribe
        }
    }
    
    private func markBookAsRead() {
        BookManager.markBookAsRead(book)
        print("Marked book as read: \(book.title)")
        
        // Track read count for re-read analytics
        let currentReadCount = UserDefaults.standard.integer(forKey: "read_count_\(book.id)")
        UserDefaults.standard.set(currentReadCount + 1, forKey: "read_count_\(book.id)")
        
        // Show notification permission request after first book completion
        if !BookCompletionService.shared.hasCompletedAnyBook {
            // This is their first book completion - perfect time to ask for notifications
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                OneSignalService.shared.showPermissionRequestAfterValue { accepted in
                    if accepted {
                        print("User accepted notifications after first book completion")
                    } else {
                        print("User declined notifications after first book completion")
                    }
                }
            }
        }
    }
    
}

struct BookView_Previews: PreviewProvider {
    static var previews: some View {
        BookView(book: Book.promos[0],
                 isPresented: .constant(true),
                 selectedChildId: nil)
    }
}

struct ImageView: View {
    let imageName: String
    
    var body: some View {
        SwiftyGifView(imageName: imageName)
            .aspectRatio(contentMode: .fit) // Force correct aspect ratio
    }
}

struct SwiftyGifView: UIViewRepresentable {
    let imageName: String
    
    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        // Configure SwiftyGifManager for this view
        let manager = SwiftyGifManager(memoryLimit: 60)
        
        // Try loading from asset catalog first
        if let asset = NSDataAsset(name: imageName) {
            do {
                let gif = try UIImage(gifData: asset.data)
                imageView.setGifImage(gif, manager: manager)
                
                // Ensure the GIF starts playing
                imageView.startAnimatingGif()
            } catch {
                print("Error loading gif from asset: \(error)")
                if let image = UIImage(named: imageName) {
                    imageView.image = image
                }
            }
        } else {
            if let image = UIImage(named: imageName) {
                imageView.image = image
            }
        }
        
        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {
        // Ensure animation continues when view updates
        uiView.startAnimatingGif()
    }
}

