import Foundation
import OneSignalFramework
import FirebaseAnalytics
import UserNotifications

class OneSignalService: ObservableObject {
    static let shared = OneSignalService()
    
    @Published var isNotificationsEnabled = false
    // Removed deviceState property (OSDeviceState no longer exists)
    
    // Add property to store pending permission completion handler
    private var pendingPermissionCompletion: ((Bool) -> Void)?
    
    private init() {
        // You may implement OSNotificationPermissionObserver and OSPushSubscriptionObserver protocols here if you want to observe changes
        // For now, just check notification status directly when needed
    }
    
    // MARK: - User Management
    
    /// Set user ID for targeting and tracking
    func setUserId(_ userId: String) {
        OneSignal.login(userId)
        print("OneSignal: Set user ID: \(userId)")
        
        // Log analytics event
        Analytics.logEvent("onesignal_user_identified", parameters: [
            "user_id": userId
        ])
    }
    
    /// Clear user ID when user signs out
    func clearUserId() {
        OneSignal.logout()
        print("OneSignal: Cleared user ID")
        
        // Log analytics event
        Analytics.logEvent("onesignal_user_logged_out", parameters: [:])
    }
    
    // MARK: - User Tags and Properties
    
    /// Set user tags for segmentation
    func setUserTags(_ tags: [String: String]) {
        OneSignal.User.addTags(tags)
        print("OneSignal: Set user tags: \(tags)")
        
        // Log analytics event
        Analytics.logEvent("onesignal_tags_set", parameters: [
            "tags": tags
        ])
    }
    
    /// Set user properties (use addTags for custom data in v5+)
    func setUserProperties(_ properties: [String: Any]) {
        for (key, value) in properties {
            OneSignal.User.addTag(key: key, value: String(describing: value))
        }
        print("OneSignal: Set user properties: \(properties)")
        
        // Log analytics event
        Analytics.logEvent("onesignal_properties_set", parameters: [
            "properties": properties
        ])
    }
    
    // MARK: - Notification Management
    
    /// Check if notifications are enabled
    func areNotificationsEnabled() -> Bool {
        return OneSignal.User.pushSubscription.optedIn
    }
    
    /// Check if user has already responded to notification permission
    func hasUserRespondedToPermission() -> Bool {
        // Use a semaphore to make this synchronous since we need to return a Bool
        let semaphore = DispatchSemaphore(value: 0)
        var hasResponded = false
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            // User has responded if the status is not .notDetermined
            hasResponded = settings.authorizationStatus != .notDetermined
            print("OneSignal: Notification permission status: \(settings.authorizationStatus.rawValue), hasResponded: \(hasResponded)")
            semaphore.signal()
        }
        
        semaphore.wait()
        return hasResponded
    }
    
    /// Request notification permission with proper iOS system prompt
    func requestNotificationPermission(completion: @escaping (Bool) -> Void = { _ in }) {
        // Only show the one-tap iOS prompt if user hasn't responded yet
        if !hasUserRespondedToPermission() {
            OneSignal.Notifications.requestPermission({ accepted in
                print("OneSignal: User accepted notifications: \(accepted)")
                
                // Log analytics event
                Analytics.logEvent("notification_permission_requested", parameters: [
                    "accepted": accepted
                ])
                
                DispatchQueue.main.async {
                    completion(accepted)
                }
            }, fallbackToSettings: false) // Don't fallback to settings for first-time requests
        } else {
            // User has already responded, check current status
            let isEnabled = areNotificationsEnabled()
            completion(isEnabled)
        }
    }
    
    // MARK: - Enhanced Permission Strategies
    
    /// Check if we should show permission request based on user engagement
    func shouldShowPermissionRequest() -> Bool {
        // Don't show if user has already responded
        if hasUserRespondedToPermission() {
            print("DEBUG: Permission request blocked - user has already responded")
            return false
        }
        
        // Check if user has completed onboarding
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        if !hasCompletedOnboarding {
            print("DEBUG: Permission request blocked - user hasn't completed onboarding")
            return false
        }
        
        // Check if user has completed at least one book (shows they find value)
        let hasCompletedBooks = BookCompletionService.shared.hasCompletedAnyBook
        if !hasCompletedBooks {
            print("DEBUG: Permission request blocked - user hasn't completed any books")
            return false
        }
        
        // Check if user has been active for at least 2 sessions
        let sessionCount = UserDefaults.standard.integer(forKey: "appSessionCount")
        if sessionCount < 2 {
            print("DEBUG: Permission request blocked - user has only \(sessionCount) sessions (need 2+)")
            return false
        }
        
        print("DEBUG: Permission request conditions met - showing prompt")
        return true
    }
    
    /// Show permission request after demonstrating value
    func showPermissionRequestAfterValue(completion: @escaping (Bool) -> Void = { _ in }) {
        // Only show if conditions are met
        guard shouldShowPermissionRequest() else {
            completion(false)
            return
        }
        
        // Show custom permission UI first
        showCustomPermissionUI { accepted in
            if accepted {
                // User accepted our custom prompt, now show iOS system prompt
                self.requestNotificationPermission(completion: completion)
            } else {
                completion(false)
            }
        }
    }
    
    /// Show custom permission UI with better messaging
    private func showCustomPermissionUI(completion: @escaping (Bool) -> Void) {
        // This would be implemented in a custom view
        // For now, we'll use the existing NotificationPermissionView
        // but with better timing and context
        DispatchQueue.main.async {
            // Post notification to show custom permission view
            NotificationCenter.default.post(name: Notification.Name("ShowCustomPermissionRequest"), object: nil)
            self.pendingPermissionCompletion = completion // Store the completion handler
        }
    }
    
    /// Handle user response from NotificationPermissionView
    func handlePermissionResponse(accepted: Bool) {
        if let completion = pendingPermissionCompletion {
            completion(accepted)
            pendingPermissionCompletion = nil
        }
    }
    
    /// Handle permission denied - provide recovery options
    func handlePermissionDenied() {
        // Log analytics
        Analytics.logEvent("notification_permission_denied", parameters: [
            "user_has_completed_books": BookCompletionService.shared.hasCompletedAnyBook,
            "session_count": UserDefaults.standard.integer(forKey: "appSessionCount")
        ])
        
        // Show recovery UI after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            NotificationCenter.default.post(name: Notification.Name("ShowPermissionRecovery"), object: nil)
        }
    }
    
    /// Increment session count for better timing
    func incrementSessionCount() {
        let currentCount = UserDefaults.standard.integer(forKey: "appSessionCount")
        UserDefaults.standard.set(currentCount + 1, forKey: "appSessionCount")
    }
    
    /// Check if user has denied permissions and show recovery
    func checkAndShowPermissionRecovery() {
        let hasResponded = hasUserRespondedToPermission()
        let isEnabled = areNotificationsEnabled()
        
        if hasResponded && !isEnabled {
            // User denied permissions, show recovery options
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                NotificationCenter.default.post(name: Notification.Name("ShowPermissionRecovery"), object: nil)
            }
        }
    }
    
    // MARK: - Analytics and Tracking
    
    /// Log notification received event
    func logNotificationReceived(_ notification: OSNotification) {
        Analytics.logEvent("notification_received", parameters: [
            "notification_id": notification.notificationId ?? "unknown",
            "title": notification.title ?? "unknown",
            "body": notification.body ?? "unknown",
            "additional_data": notification.additionalData ?? [:]
        ])
    }
    
    /// Log notification clicked event
    func logNotificationClicked(_ notification: OSNotification) {
        Analytics.logEvent("notification_clicked", parameters: [
            "notification_id": notification.notificationId ?? "unknown",
            "title": notification.title ?? "unknown",
            "body": notification.body ?? "unknown",
            "additional_data": notification.additionalData ?? [:]
        ])
    }
    
    // MARK: - Deep Link Handling
    
    /// Handle deep links from notifications
    func handleNotificationDeepLink(_ data: [String: Any]) {
        // Handle book deep links
        if let bookId = data["book_id"] as? String {
            print("OneSignal: Handling book deep link for book ID: \(bookId)")
            NotificationCenter.default.post(name: Notification.Name("DeepLinkBook"), object: nil, userInfo: ["bookId": bookId])
            
            // Log analytics event
            Analytics.logEvent("notification_book_deeplink", parameters: [
                "book_id": bookId
            ])
        }
        
        // Handle search deep links
        if let searchQuery = data["search_query"] as? String {
            print("OneSignal: Handling search deep link for query: \(searchQuery)")
            NotificationCenter.default.post(name: Notification.Name("DeepLinkSearch"), object: nil, userInfo: ["searchQuery": searchQuery])
            
            // Log analytics event
            Analytics.logEvent("notification_search_deeplink", parameters: [
                "search_query": searchQuery
            ])
        }
        
        // Handle subscription prompts
        if let action = data["action"] as? String, action == "subscribe" {
            print("OneSignal: Handling subscription prompt")
            NotificationCenter.default.post(name: Notification.Name("ShowPaywall"), object: nil)
            
            // Log analytics event
            Analytics.logEvent("notification_subscription_prompt", parameters: [:])
        }
        
        // Handle other custom actions
        if let customAction = data["custom_action"] as? String {
            print("OneSignal: Handling custom action: \(customAction)")
            
            // Log analytics event
            Analytics.logEvent("notification_custom_action", parameters: [
                "action": customAction
            ])
        }
    }
    
    // MARK: - User Segmentation
    
    /// Set up user segmentation based on user data
    func setupUserSegmentation(user: User) {
        var tags: [String: String] = [:]
        
        // User type
        tags["user_type"] = "authenticated"
        
        // Children count
        tags["children_count"] = "\(user.children.count)"
        
        // User properties
        var properties: [String: Any] = [:]
        properties["email"] = user.email
        properties["full_name"] = user.parentName
        properties["children_count"] = user.children.count
        
        // Set tags and properties
        setUserTags(tags)
        setUserProperties(properties)
        
        print("OneSignal: Set up user segmentation for user: \(user.email)")
    }
    
    /// Check if user has already seen the notification prompt
    func hasSeenNotificationPrompt() -> Bool {
        return UserDefaults.standard.bool(forKey: "hasSeenNotificationPrompt")
    }
    
    /// Mark that the user has seen the notification prompt
    func markNotificationPromptSeen() {
        UserDefaults.standard.set(true, forKey: "hasSeenNotificationPrompt")
    }
    
    /// Reset notification prompt state (for testing)
    func resetNotificationPromptState() {
        UserDefaults.standard.removeObject(forKey: "hasSeenNotificationPrompt")
        print("DEBUG: Reset notification prompt state")
    }
    
    /// Log current notification permission status for debugging
    func logPermissionStatus() {
        let hasResponded = hasUserRespondedToPermission()
        let isEnabled = areNotificationsEnabled()
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        let hasCompletedBooks = BookCompletionService.shared.hasCompletedAnyBook
        let sessionCount = UserDefaults.standard.integer(forKey: "appSessionCount")
        let hasSeenPrompt = hasSeenNotificationPrompt()
        
        print("DEBUG: OneSignal Permission Status:")
        print("  - Has responded to permission: \(hasResponded)")
        print("  - Notifications enabled: \(isEnabled)")
        print("  - Has completed onboarding: \(hasCompletedOnboarding)")
        print("  - Has completed books: \(hasCompletedBooks)")
        print("  - Session count: \(sessionCount)")
        print("  - Has seen notification prompt: \(hasSeenPrompt)")
        print("  - Should show permission request: \(shouldShowPermissionRequest())")
    }

    /// Test method to manually trigger notification permission flow (for debugging)
    func testNotificationPermissionFlow() {
        print("DEBUG: Manually testing notification permission flow")
        logPermissionStatus()
        
        if shouldShowPermissionRequest() {
            print("DEBUG: Conditions met - showing permission prompt")
            showPermissionRequestAfterValue { accepted in
                print("DEBUG: Permission request result: \(accepted)")
            }
        } else {
            print("DEBUG: Conditions not met - cannot show permission prompt")
        }
    }

    /// Force show notification prompt for testing (bypasses normal conditions)
    func forceShowNotificationPrompt() {
        print("DEBUG: Force showing notification prompt for testing")
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("ShowCustomPermissionRequest"), object: nil)
        }
    }
} 