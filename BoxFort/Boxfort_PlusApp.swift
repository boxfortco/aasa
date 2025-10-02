//
//  AppDelegate.swift
//  BoxFort
//
//  Created by Matthew Ryan on 4/11/25.
//


//
//  Boxfort_PlusApp.swift
//  Boxfort Plus
//
//  Created by Matthew Ryan on 9/2/22.
//

import SwiftUI
import RevenueCat
import OneSignalFramework
import Firebase
import FirebaseAnalytics
import FirebaseAppCheck
import FirebaseDatabase
import StoreKit

class AppDelegate: NSObject, UIApplicationDelegate, OSNotificationClickListener {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // --- App Check and Firebase initialization (merged from BoxFortApp.swift) ---
        #if DEBUG
        // Use debug provider only in debug builds
        if let debugToken = ProcessInfo.processInfo.environment["FIRAUTH_APP_CHECK_DEBUG_TOKEN"] {
            print("App Check: Debug token found: \(debugToken.prefix(8))...")
            let providerFactory = AppCheckDebugProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
            print("App Check: Using debug provider with token")
        } else {
            print("App Check: Debug token not found in environment variables")
            print("App Check: Available environment variables: \(ProcessInfo.processInfo.environment.keys.joined(separator: ", "))")
            let providerFactory = DeviceCheckProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
            print("App Check: Using device check provider")
        }
        #else
        // Use production provider for release builds
        let providerFactory = DeviceCheckProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        print("App Check: Using production device check provider")
        #endif
        
        FirebaseApp.configure()
        
        // Configure Firebase Realtime Database persistence (must be called before any database operations)
        Database.database().isPersistenceEnabled = true
        
        // --- End App Check and Firebase initialization ---
        
        // OneSignal initialization - same for debug and production
        OneSignal.Debug.setLogLevel(.LL_VERBOSE)
        OneSignal.initialize("fd180212-5b86-413e-924c-ec2f56c697c0", withLaunchOptions: launchOptions)
        
        // Register AppDelegate as notification click listener only
        OneSignal.Notifications.addClickListener(self)
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // CoreDataStack.shared.saveContext() - Removed as CoreData is no longer needed
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("DEBUG: AppDelegate received URL: \(url)")
        
        // Handle custom URL schemes (boxfort://)
        if url.scheme == "boxfort" {
            print("DEBUG: URL scheme matches 'boxfort'")
            
            // Handle search deep links (new structure)
            if let searchQuery = StoryPreviewService.shared.parseSearchDeepLink(from: url) {
                print("DEBUG: Parsed search query: '\(searchQuery)'")
                NotificationCenter.default.post(name: Notification.Name("DeepLinkSearch"), object: nil, userInfo: ["searchQuery": searchQuery])
                return true
            }
            
            // Handle book-specific deep links (backward compatibility)
            if let bookId = StoryPreviewService.shared.parseBookDeepLink(from: url) {
                print("DEBUG: Parsed bookId: '\(bookId)'")
                NotificationCenter.default.post(name: Notification.Name("DeepLinkBook"), object: nil, userInfo: ["bookId": bookId])
                return true
            }
            
            // Handle legacy search deep links (backward compatibility)
            if let query = url.queryParameters?["search"] {
                print("DEBUG: Parsed legacy search query: '\(query)'")
                NotificationCenter.default.post(name: Notification.Name("DeepLinkSearch"), object: nil, userInfo: ["searchQuery": query])
                return true
            }
            
            return true
        }
        
        // Handle Universal Links (https://boxfortco.github.io)
        if url.host == "boxfortco.github.io" {
            print("DEBUG: Universal Link received for boxfortco.github.io")
            
            // Handle search deep links from Universal Links
            if let searchQuery = StoryPreviewService.shared.parseSearchDeepLink(from: url) {
                print("DEBUG: Parsed Universal Link search query: '\(searchQuery)'")
                NotificationCenter.default.post(name: Notification.Name("DeepLinkSearch"), object: nil, userInfo: ["searchQuery": searchQuery])
                return true
            }
            
            // Handle book-specific deep links from Universal Links
            if let bookId = StoryPreviewService.shared.parseBookDeepLink(from: url) {
                print("DEBUG: Parsed Universal Link bookId: '\(bookId)'")
                NotificationCenter.default.post(name: Notification.Name("DeepLinkBook"), object: nil, userInfo: ["bookId": bookId])
                return true
            }
            
            return true
        }
        
        print("DEBUG: URL scheme does not match 'boxfort' and host is not 'boxfort.co'")
        return false
    }
    
    // MARK: - OneSignal Notification Click Listener
    func onClick(event: OSNotificationClickEvent) {
        print("OneSignal: Notification clicked!")
        print("OneSignal: Clicked notification data: \(event.notification.additionalData ?? [:])")
        OneSignalService.shared.logNotificationClicked(event.notification)
        if let additionalData = event.notification.additionalData as? [String: Any] {
            OneSignalService.shared.handleNotificationDeepLink(additionalData)
        }
    }
}

@main
struct Boxfort_PlusApp: App {
    @StateObject var userViewModel = UserViewModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_mDyxdbERngifIAKgyNIlMDHeADQ")
    }
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(userViewModel)
                .onAppear {
                    checkSubscriptionStatus()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    // Check for review submission when app becomes active
                    ReviewService.shared.checkForReviewSubmission(userId: userViewModel.user?.id)
                }
        }
    }
    
    private func checkSubscriptionStatus() {
        if !userViewModel.isSubscriptionActive {
            print("User is not subscribed")
        }
    }
}

