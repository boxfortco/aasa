import Foundation
import FirebaseAnalytics
import RevenueCat

class IAPAnalyticsService: ObservableObject {
    static let shared = IAPAnalyticsService()
    
    private init() {}
    
    // MARK: - Subscription Analytics
    
    /// Track subscription conversion (free trial to paid)
    func trackSubscriptionConvert(
        productId: String,
        price: Decimal,
        currency: String,
        period: String,
        previousStatus: String = "none"
    ) {
        Analytics.logEvent("app_store_subscription_convert", parameters: [
            "product_id": productId,
            "price": price as NSDecimalNumber,
            "currency": currency,
            "subscription_period": period,
            "previous_status": previousStatus,
            "conversion_source": "paywall"
        ])
        
        print("📊 IAP Analytics: Subscription converted - \(productId) (\(price) \(currency))")
    }
    
    /// Track subscription purchase (new subscription)
    func trackSubscriptionPurchase(
        productId: String,
        price: Decimal,
        currency: String,
        period: String,
        source: String = "paywall"
    ) {
        Analytics.logEvent("app_store_subscription_purchase", parameters: [
            "product_id": productId,
            "price": price as NSDecimalNumber,
            "currency": currency,
            "subscription_period": period,
            "purchase_source": source,
            "is_first_subscription": true
        ])
        
        print("📊 IAP Analytics: Subscription purchased - \(productId) (\(price) \(currency))")
    }
    
    /// Track subscription renewal
    func trackSubscriptionRenewal(
        productId: String,
        price: Decimal,
        currency: String,
        period: String,
        renewalCount: Int
    ) {
        Analytics.logEvent("app_store_subscription_renewal", parameters: [
            "product_id": productId,
            "price": price as NSDecimalNumber,
            "currency": currency,
            "subscription_period": period,
            "renewal_count": renewalCount
        ])
        
        print("📊 IAP Analytics: Subscription renewed - \(productId) (renewal #\(renewalCount))")
    }
    
    /// Track subscription cancellation
    func trackSubscriptionCancellation(
        productId: String,
        reason: String? = nil,
        subscriptionDuration: Int? = nil
    ) {
        var parameters: [String: Any] = [
            "product_id": productId
        ]
        
        if let reason = reason {
            parameters["cancellation_reason"] = reason
        }
        
        if let duration = subscriptionDuration {
            parameters["subscription_duration_days"] = duration
        }
        
        Analytics.logEvent("app_store_subscription_cancelled", parameters: parameters)
        
        print("📊 IAP Analytics: Subscription cancelled - \(productId)")
    }
    
    /// Track subscription restoration
    func trackSubscriptionRestoration(
        productId: String,
        price: Decimal,
        currency: String,
        period: String
    ) {
        Analytics.logEvent("app_store_subscription_restored", parameters: [
            "product_id": productId,
            "price": price as NSDecimalNumber,
            "currency": currency,
            "subscription_period": period
        ])
        
        print("📊 IAP Analytics: Subscription restored - \(productId)")
    }
    
    /// Track subscription trial started
    func trackSubscriptionTrialStarted(
        productId: String,
        trialDuration: String,
        source: String = "paywall"
    ) {
        Analytics.logEvent("app_store_subscription_trial_started", parameters: [
            "product_id": productId,
            "trial_duration": trialDuration,
            "trial_source": source
        ])
        
        print("📊 IAP Analytics: Trial started - \(productId) (\(trialDuration))")
    }
    
    /// Track subscription trial converted
    func trackSubscriptionTrialConverted(
        productId: String,
        price: Decimal,
        currency: String,
        period: String,
        trialDuration: String
    ) {
        Analytics.logEvent("app_store_subscription_trial_converted", parameters: [
            "product_id": productId,
            "price": price as NSDecimalNumber,
            "currency": currency,
            "subscription_period": period,
            "trial_duration": trialDuration
        ])
        
        print("📊 IAP Analytics: Trial converted - \(productId)")
    }
    
    /// Track subscription trial cancelled
    func trackSubscriptionTrialCancelled(
        productId: String,
        trialDuration: String,
        reason: String? = nil
    ) {
        var parameters: [String: Any] = [
            "product_id": productId,
            "trial_duration": trialDuration
        ]
        
        if let reason = reason {
            parameters["cancellation_reason"] = reason
        }
        
        Analytics.logEvent("app_store_subscription_trial_cancelled", parameters: parameters)
        
        print("📊 IAP Analytics: Trial cancelled - \(productId)")
    }
    
    // MARK: - Book Purchase Analytics
    
    /// Track individual book purchase
    func trackBookPurchase(
        bookId: String,
        bookTitle: String,
        productId: String,
        price: Decimal,
        currency: String,
        source: String = "book_detail"
    ) {
        Analytics.logEvent("app_store_book_purchase", parameters: [
            "book_id": bookId,
            "book_title": bookTitle,
            "product_id": productId,
            "price": price as NSDecimalNumber,
            "currency": currency,
            "purchase_source": source
        ])
        
        print("📊 IAP Analytics: Book purchased - \(bookTitle) (\(price) \(currency))")
    }
    
    /// Track book purchase attempt
    func trackBookPurchaseAttempt(
        bookId: String,
        bookTitle: String,
        productId: String,
        price: Decimal,
        currency: String,
        source: String = "book_detail"
    ) {
        Analytics.logEvent("app_store_book_purchase_attempt", parameters: [
            "book_id": bookId,
            "book_title": bookTitle,
            "product_id": productId,
            "price": price as NSDecimalNumber,
            "currency": currency,
            "purchase_source": source
        ])
        
        print("📊 IAP Analytics: Book purchase attempted - \(bookTitle)")
    }
    
    /// Track book purchase failure
    func trackBookPurchaseFailure(
        bookId: String,
        bookTitle: String,
        productId: String,
        error: String,
        source: String = "book_detail"
    ) {
        Analytics.logEvent("app_store_book_purchase_failed", parameters: [
            "book_id": bookId,
            "book_title": bookTitle,
            "product_id": productId,
            "error_message": error,
            "purchase_source": source
        ])
        
        print("📊 IAP Analytics: Book purchase failed - \(bookTitle) (\(error))")
    }
    
    /// Track book purchase restoration
    func trackBookPurchaseRestored(
        bookId: String,
        bookTitle: String,
        productId: String
    ) {
        Analytics.logEvent("app_store_book_purchase_restored", parameters: [
            "book_id": bookId,
            "book_title": bookTitle,
            "product_id": productId
        ])
        
        print("📊 IAP Analytics: Book purchase restored - \(bookTitle)")
    }
    
    // MARK: - Paywall Analytics
    
    /// Track paywall shown
    func trackPaywallShown(
        source: String,
        userType: String = "non_subscriber",
        booksInLibrary: Int = 0
    ) {
        Analytics.logEvent("paywall_shown", parameters: [
            "paywall_source": source,
            "user_type": userType,
            "books_in_library": booksInLibrary
        ])
        
        print("📊 IAP Analytics: Paywall shown - \(source)")
    }
    
    /// Track paywall dismissed without purchase (user explicitly closed)
    func trackPaywallDismissedWithoutPurchase(
        source: String,
        timeSpent: TimeInterval? = nil,
        userType: String = "non_subscriber",
        dismissalMethod: String = "close_button"
    ) {
        var parameters: [String: Any] = [
            "paywall_source": source,
            "user_type": userType,
            "dismissal_method": dismissalMethod
        ]
        
        if let timeSpent = timeSpent {
            parameters["time_spent_seconds"] = timeSpent
        }
        
        Analytics.logEvent("paywall_dismissed_without_purchase", parameters: parameters)
        
        print("📊 IAP Analytics: Paywall dismissed without purchase - \(source) (\(dismissalMethod))")
    }
    
    /// Track paywall purchase attempt started
    func trackPaywallPurchaseAttempt(
        source: String,
        productId: String,
        userType: String = "non_subscriber"
    ) {
        Analytics.logEvent("paywall_purchase_attempt", parameters: [
            "paywall_source": source,
            "product_id": productId,
            "user_type": userType
        ])
        
        print("📊 IAP Analytics: Paywall purchase attempt - \(productId) from \(source)")
    }
    
    /// Track paywall purchase completed
    func trackPaywallPurchaseCompleted(
        source: String,
        productId: String,
        price: Decimal,
        currency: String,
        userType: String = "non_subscriber"
    ) {
        Analytics.logEvent("paywall_purchase_completed", parameters: [
            "paywall_source": source,
            "product_id": productId,
            "price": price as NSDecimalNumber,
            "currency": currency,
            "user_type": userType
        ])
        
        print("📊 IAP Analytics: Paywall purchase completed - \(productId) (\(price) \(currency))")
    }
    
    /// Track paywall purchase failed
    func trackPaywallPurchaseFailed(
        source: String,
        productId: String,
        errorMessage: String,
        userType: String = "non_subscriber"
    ) {
        Analytics.logEvent("paywall_purchase_failed", parameters: [
            "paywall_source": source,
            "product_id": productId,
            "error_message": errorMessage,
            "user_type": userType
        ])
        
        print("📊 IAP Analytics: Paywall purchase failed - \(productId): \(errorMessage)")
    }
    
    /// Track paywall interaction (button taps, scrolling, etc.)
    func trackPaywallInteraction(
        source: String,
        interactionType: String,
        productId: String? = nil
    ) {
        var parameters: [String: Any] = [
            "paywall_source": source,
            "interaction_type": interactionType
        ]
        
        if let productId = productId {
            parameters["product_id"] = productId
        }
        
        Analytics.logEvent("paywall_interaction", parameters: parameters)
        
        print("📊 IAP Analytics: Paywall interaction - \(interactionType) on \(source)")
    }
    
    // MARK: - Legacy Methods (for backward compatibility)
    
    /// Track paywall dismissed (legacy - use specific methods above instead)
    func trackPaywallDismissed(
        source: String,
        timeSpent: TimeInterval? = nil,
        userType: String = "non_subscriber"
    ) {
        var parameters: [String: Any] = [
            "paywall_source": source,
            "user_type": userType
        ]
        
        if let timeSpent = timeSpent {
            parameters["time_spent_seconds"] = timeSpent
        }
        
        Analytics.logEvent("paywall_dismissed", parameters: parameters)
        
        print("📊 IAP Analytics: Paywall dismissed - \(source)")
    }
    
    // MARK: - RevenueCat Integration
    
    /// Track RevenueCat customer info updates
    func trackCustomerInfoUpdate(_ customerInfo: CustomerInfo) {
        let entitlements = customerInfo.entitlements.all
        let activeEntitlements = entitlements.filter { $0.value.isActive }
        
        Analytics.logEvent("revenuecat_customer_info_updated", parameters: [
            "active_entitlements_count": activeEntitlements.count,
            "total_entitlements_count": entitlements.count,
            "has_active_subscription": customerInfo.entitlements.all["Unlimited"]?.isActive == true,
            "purchased_products_count": customerInfo.nonConsumablePurchases.count
        ])
        
        print("📊 IAP Analytics: Customer info updated - \(activeEntitlements.count) active entitlements")
    }
    
    /// Track purchase restoration
    func trackPurchaseRestoration(success: Bool, restoredItems: Int = 0) {
        Analytics.logEvent("purchase_restoration", parameters: [
            "restoration_success": success,
            "restored_items_count": restoredItems
        ])
        
        print("📊 IAP Analytics: Purchase restoration - success: \(success), items: \(restoredItems)")
    }
    
    // MARK: - Error Tracking
    
    /// Track IAP errors
    func trackIAPError(
        errorType: String,
        errorMessage: String,
        productId: String? = nil,
        source: String = "unknown"
    ) {
        var parameters: [String: Any] = [
            "error_type": errorType,
            "error_message": errorMessage,
            "error_source": source
        ]
        
        if let productId = productId {
            parameters["product_id"] = productId
        }
        
        Analytics.logEvent("iap_error", parameters: parameters)
        
        print("📊 IAP Analytics: Error - \(errorType): \(errorMessage)")
    }
} 