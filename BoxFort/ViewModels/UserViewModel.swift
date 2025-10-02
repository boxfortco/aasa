//
//  UserViewModel.swift
//  BoxFort
//
//  Created by Matthew Ryan on 4/11/25.
//


//
//  UserViewModel.swift
//  Boxfort Plus
//
//  Created by Matthew Ryan on 9/27/22.
//

import Foundation
import SwiftUI
import RevenueCat
import FirebaseAuth
import FirebaseFirestore
import Combine
import FirebaseAnalytics

class UserViewModel: NSObject, ObservableObject {
    
    @Published var user: User?
    @Published var isSubscriptionActive = false
    @Published var purchasedBooks: Set<String> = []
    private let purchasedBooksKey = "purchasedBooks"
    private let db = Firestore.firestore()
    private var authService: AuthenticationService?
    private var cancellables = Set<AnyCancellable>()
    @StateObject private var iapAnalytics = IAPAnalyticsService.shared
    
    override init() {
        super.init()
        // Enable debug logs for RevenueCat
        Purchases.logLevel = .debug
        
        // Set up a delegate to handle subscription changes
        Purchases.shared.delegate = self
        
        // Load local purchases first
        loadPurchasedBooks()
    }
    
    func setupAuthService(_ service: AuthenticationService) {
        self.authService = service
        // Observe auth service changes
        service.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.user = service.currentUser
            }
        }.store(in: &cancellables)
    }
    
    func checkSubscriptionStatus() {
        Task {
            await refreshPurchases()
        }
    }
    
    func refreshPurchases() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            
            await MainActor.run {
                // Track customer info update
                iapAnalytics.trackCustomerInfoUpdate(customerInfo)
                
                // Update subscription status
                let wasSubscriptionActive = self.isSubscriptionActive
                self.isSubscriptionActive = customerInfo.entitlements.all["Unlimited"]?.isActive == true
                
                // Track subscription status changes
                if !wasSubscriptionActive && self.isSubscriptionActive {
                    // New subscription activated
                    if let entitlement = customerInfo.entitlements.all["Unlimited"] {
                        let productId = entitlement.productIdentifier
                        // Get product details from offerings for accurate tracking
                        Task {
                            await trackSubscriptionPurchaseWithDetails(productId: productId)
                        }
                    }
                }
                
                // Convert non-consumable purchases to book IDs
                let revenueCatPurchases = customerInfo.nonConsumablePurchases.compactMap { productId -> String in
                    guard productId.hasPrefix("book_") else { return "" }
                    return String(productId.dropFirst(5)) // Remove "book_" prefix
                }.filter { !$0.isEmpty }
                
                // Track newly restored book purchases
                let newPurchases = Set(revenueCatPurchases).subtracting(self.purchasedBooks)
                for bookId in newPurchases {
                    iapAnalytics.trackBookPurchaseRestored(
                        bookId: bookId,
                        bookTitle: bookId, // You might want to get the actual title
                        productId: "book_\(bookId)"
                    )
                }
                
                // Merge with existing purchases
                self.purchasedBooks.formUnion(revenueCatPurchases)
                self.savePurchasedBooks()
                
                print("DEBUG: Refreshed purchases - Found \(revenueCatPurchases.count) books")
            }
        } catch {
            print("DEBUG: Failed to refresh purchases: \(error.localizedDescription)")
            iapAnalytics.trackIAPError(
                errorType: "refresh_purchases_failed",
                errorMessage: error.localizedDescription,
                source: "UserViewModel"
            )
        }
    }
    
    func restorePurchases() async {
        do {
            print("DEBUG: Starting purchase restoration")
            try await Purchases.shared.restorePurchases()
            await refreshPurchases()
            print("DEBUG: Purchase restoration completed")
            
            // Track successful restoration
            iapAnalytics.trackPurchaseRestoration(success: true)
        } catch {
            print("DEBUG: Failed to restore purchases: \(error.localizedDescription)")
            iapAnalytics.trackPurchaseRestoration(success: false)
            iapAnalytics.trackIAPError(
                errorType: "restore_purchases_failed",
                errorMessage: error.localizedDescription,
                source: "UserViewModel"
            )
        }
    }
    
    func hasAccessToBook(_ book: Book) -> Bool {
        return book.free || isSubscriptionActive || purchasedBooks.contains(book.id)
    }
    
    private func loadPurchasedBooks() {
        if let savedBooks = UserDefaults.standard.array(forKey: purchasedBooksKey) as? [String] {
            purchasedBooks = Set(savedBooks)
            print("DEBUG: Loaded \(savedBooks.count) purchased books from local storage")
        }
    }
    
    func savePurchasedBooks() {
        UserDefaults.standard.set(Array(purchasedBooks), forKey: purchasedBooksKey)
        print("DEBUG: Saved \(purchasedBooks.count) purchased books to local storage")
    }
    
    func addPurchasedBook(_ bookId: String) {
        purchasedBooks.insert(bookId)
        savePurchasedBooks()
        print("DEBUG: Added book \(bookId) to purchased books")
    }
    
    /// Track subscription purchase with detailed product information
    private func trackSubscriptionPurchaseWithDetails(productId: String?) async {
        guard let productId = productId else {
            print("DEBUG: No product ID available for subscription tracking")
            return
        }
        
        do {
            let offerings = try await Purchases.shared.offerings()
            
            // Find the product in any offering
            var foundProduct: StoreProduct?
            for offering in offerings.all.values {
                for package in offering.availablePackages {
                    if package.storeProduct.productIdentifier == productId {
                        foundProduct = package.storeProduct
                        break
                    }
                }
                if foundProduct != nil { break }
            }
            
            if let product = foundProduct {
                iapAnalytics.trackSubscriptionPurchase(
                    productId: productId,
                    price: product.price,
                    currency: product.currencyCode ?? "USD",
                    period: product.subscriptionPeriod?.unit.asReadableString ?? "unknown"
                )
            } else {
                // Fallback if product not found in offerings
                iapAnalytics.trackSubscriptionPurchase(
                    productId: productId,
                    price: 0,
                    currency: "USD",
                    period: "unknown"
                )
            }
        } catch {
            print("DEBUG: Failed to get product details for tracking: \(error.localizedDescription)")
            // Fallback tracking
            iapAnalytics.trackSubscriptionPurchase(
                productId: productId,
                price: 0,
                currency: "USD",
                period: "unknown"
            )
        }
    }
    
    func toggleFavorite(bookId: String, for childId: String) {
        print("DEBUG: Starting toggleFavorite for book \(bookId) and child \(childId)")
        
        guard let userId = Auth.auth().currentUser?.uid else {
            print("DEBUG: No authenticated user found")
            return
        }
        
        guard var user = user else {
            print("DEBUG: No user object found")
            return
        }
        
        guard let childIndex = user.children.firstIndex(where: { $0.id == childId }) else {
            print("DEBUG: Could not find child with ID \(childId)")
            return
        }
        
        print("DEBUG: Current favorites for child: \(user.children[childIndex].favorites)")
        
        // Toggle the favorite
        if user.children[childIndex].favorites.contains(bookId) {
            user.children[childIndex].favorites.removeAll { $0 == bookId }
            print("DEBUG: Removed favorite \(bookId) for child \(user.children[childIndex].name)")
        } else {
            user.children[childIndex].favorites.append(bookId)
            print("DEBUG: Added favorite \(bookId) for child \(user.children[childIndex].name)")
        }
        
        // Update local state immediately
        self.user = user
        print("DEBUG: Updated local state. New favorites count: \(user.children[childIndex].favorites.count)")
        print("DEBUG: New favorites list: \(user.children[childIndex].favorites)")
        
        // Update Firestore
        let userRef = db.collection("users").document(userId)
        
        // Create an array of child data to update
        let childrenData = user.children.map { child -> [String: Any] in
            return [
                "id": child.id,
                "name": child.name,
                "age": child.age,
                "avatarId": child.avatarId,
                "favorites": child.favorites,
                "lastReadDate": child.lastReadDate ?? Date()
            ]
        }
        
        userRef.updateData([
            "children": childrenData
        ]) { error in
            if let error = error {
                print("DEBUG: Error updating favorites in Firestore: \(error.localizedDescription)")
            } else {
                print("DEBUG: Successfully updated favorites in Firestore")
            }
        }
    }
}

// MARK: - PurchasesDelegate
extension UserViewModel: PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        Task {
            await refreshPurchases()
            
            // Track subscription status changes more comprehensively
            await trackSubscriptionChanges(customerInfo: customerInfo)
        }
    }
    
    /// Track subscription changes including conversions and renewals
    private func trackSubscriptionChanges(customerInfo: CustomerInfo) async {
        let wasSubscriptionActive = self.isSubscriptionActive
        let isNowSubscriptionActive = customerInfo.entitlements.all["Unlimited"]?.isActive == true
        
        // Track new subscription activation
        if !wasSubscriptionActive && isNowSubscriptionActive {
            if let entitlement = customerInfo.entitlements.all["Unlimited"] {
                let productId = entitlement.productIdentifier
                
                // Determine if this is a trial conversion or new purchase
                let isTrialConversion = customerInfo.originalPurchaseDate != customerInfo.latestExpirationDate
                
                if isTrialConversion {
                    // Track trial conversion
                    await trackTrialConversion(productId: productId, customerInfo: customerInfo)
                } else {
                    // Track new subscription purchase
                    await trackSubscriptionPurchaseWithDetails(productId: productId)
                }
                
                // Post notification for paywall tracking
                await MainActor.run {
                    NotificationCenter.default.post(name: .purchaseCompleted, object: nil, userInfo: [
                        "productId": productId,
                        "isTrialConversion": isTrialConversion
                    ])
                }
            }
        }
        
        // Track subscription renewal
        if wasSubscriptionActive && isNowSubscriptionActive {
            if let entitlement = customerInfo.entitlements.all["Unlimited"] {
                await trackSubscriptionRenewal(productId: entitlement.productIdentifier, customerInfo: customerInfo)
            }
        }
        
        // Track subscription cancellation
        if wasSubscriptionActive && !isNowSubscriptionActive {
            if let entitlement = customerInfo.entitlements.all["Unlimited"] {
                await trackSubscriptionCancellation(productId: entitlement.productIdentifier, customerInfo: customerInfo)
            }
        }
    }
    
    /// Track trial conversion with detailed information
    private func trackTrialConversion(productId: String, customerInfo: CustomerInfo) async {
        do {
            let offerings = try await Purchases.shared.offerings()
            
            // Find the product in any offering
            var foundProduct: StoreProduct?
            for offering in offerings.all.values {
                for package in offering.availablePackages {
                    if package.storeProduct.productIdentifier == productId {
                        foundProduct = package.storeProduct
                        break
                    }
                }
                if foundProduct != nil { break }
            }
            
            if let product = foundProduct {
                // Calculate trial duration
                let trialDuration = calculateTrialDuration(customerInfo: customerInfo)
                
                iapAnalytics.trackSubscriptionConvert(
                    productId: productId,
                    price: product.price,
                    currency: product.currencyCode ?? "USD",
                    period: product.subscriptionPeriod?.unit.asReadableString ?? "unknown",
                    previousStatus: "trial"
                )
                
                // Also track trial conversion event
                iapAnalytics.trackSubscriptionTrialConverted(
                    productId: productId,
                    price: product.price,
                    currency: product.currencyCode ?? "USD",
                    period: product.subscriptionPeriod?.unit.asReadableString ?? "unknown",
                    trialDuration: trialDuration
                )
            } else {
                // Fallback tracking
                iapAnalytics.trackSubscriptionConvert(
                    productId: productId,
                    price: 0,
                    currency: "USD",
                    period: "unknown",
                    previousStatus: "trial"
                )
            }
        } catch {
            print("DEBUG: Failed to get product details for trial conversion tracking: \(error.localizedDescription)")
            // Fallback tracking
            iapAnalytics.trackSubscriptionConvert(
                productId: productId,
                price: 0,
                currency: "USD",
                period: "unknown",
                previousStatus: "trial"
            )
        }
    }
    
    /// Track subscription renewal
    private func trackSubscriptionRenewal(productId: String, customerInfo: CustomerInfo) async {
        do {
            let offerings = try await Purchases.shared.offerings()
            
            // Find the product in any offering
            var foundProduct: StoreProduct?
            for offering in offerings.all.values {
                for package in offering.availablePackages {
                    if package.storeProduct.productIdentifier == productId {
                        foundProduct = package.storeProduct
                        break
                    }
                }
                if foundProduct != nil { break }
            }
            
            if let product = foundProduct {
                // Calculate renewal count (this is a simplified approach)
                let renewalCount = calculateRenewalCount(customerInfo: customerInfo)
                
                iapAnalytics.trackSubscriptionRenewal(
                    productId: productId,
                    price: product.price,
                    currency: product.currencyCode ?? "USD",
                    period: product.subscriptionPeriod?.unit.asReadableString ?? "unknown",
                    renewalCount: renewalCount
                )
            }
        } catch {
            print("DEBUG: Failed to get product details for renewal tracking: \(error.localizedDescription)")
        }
    }
    
    /// Track subscription cancellation
    private func trackSubscriptionCancellation(productId: String, customerInfo: CustomerInfo) async {
        // Calculate subscription duration
        let duration = calculateSubscriptionDuration(customerInfo: customerInfo)
        
        iapAnalytics.trackSubscriptionCancellation(
            productId: productId,
            reason: "user_cancelled",
            subscriptionDuration: duration
        )
    }
    
    /// Calculate trial duration in days
    private func calculateTrialDuration(customerInfo: CustomerInfo) -> String {
        guard let originalDate = customerInfo.originalPurchaseDate,
              let expirationDate = customerInfo.latestExpirationDate else {
            return "unknown"
        }
        
        let duration = Calendar.current.dateComponents([.day], from: originalDate, to: expirationDate).day ?? 0
        return "\(duration)_days"
    }
    
    /// Calculate renewal count (simplified)
    private func calculateRenewalCount(customerInfo: CustomerInfo) -> Int {
        // This is a simplified approach - you might want to track this more accurately
        // For now, we'll estimate based on time since original purchase
        guard let originalDate = customerInfo.originalPurchaseDate else { return 1 }
        
        let daysSinceOriginal = Calendar.current.dateComponents([.day], from: originalDate, to: Date()).day ?? 0
        
        // Assume monthly subscriptions for this calculation
        return max(1, daysSinceOriginal / 30)
    }
    
    /// Calculate subscription duration in days
    private func calculateSubscriptionDuration(customerInfo: CustomerInfo) -> Int? {
        guard let originalDate = customerInfo.originalPurchaseDate else { return nil }
        
        let daysSinceOriginal = Calendar.current.dateComponents([.day], from: originalDate, to: Date()).day ?? 0
        return daysSinceOriginal
    }
}
