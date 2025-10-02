//
//  PaywallView.swift
//  BoxFort
//
//  Created by Matthew Ryan on 4/11/25.
//

import SwiftUI
import RevenueCat
import RevenueCatUI
import StoreKit
import FirebaseAnalytics

// MARK: - Notification Extensions
extension Notification.Name {
    static let purchaseCompleted = Notification.Name("purchaseCompleted")
    static let purchaseFailed = Notification.Name("purchaseFailed")
}

// MARK: - Subscription Period Extensions
extension RevenueCat.SubscriptionPeriod {
    var asReadableString: String {
        let unitString: String
        switch unit {
        case .day: unitString = value == 1 ? "day" : "days"
        case .week: unitString = value == 1 ? "week" : "weeks"
        case .month: unitString = value == 1 ? "month" : "months"
        case .year: unitString = value == 1 ? "year" : "years"
        @unknown default: unitString = "period"
        }
        return "\(value) \(unitString)"
    }
}

extension RevenueCat.SubscriptionPeriod.Unit {
    var asReadableString: String {
        switch self {
        case .day: return "day"
        case .week: return "week"
        case .month: return "month"
        case .year: return "year"
        @unknown default: return "period"
        }
    }
}

struct PaywallView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var isPaywallPresented: Bool
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var currentOffering: Offering?
    @State private var hasPassedParentalGate = false
    @State private var userAnswer = ""
    @State private var paywallStartTime = Date()
    @State private var purchaseAttempted = false
    @State private var lastPurchaseInfo: [AnyHashable: Any]?
    @StateObject private var iapAnalytics = IAPAnalyticsService.shared
    
    var body: some View {
        Group {
            if !hasPassedParentalGate {
                ZStack(alignment: .topTrailing) {
                    ParentalGateView(userAnswer: $userAnswer) { correctAnswer in
                        hasPassedParentalGate = correctAnswer
                    }
                    
                    // Close button for parental gate
                    Button(action: {
                        dismissPaywall(dismissalMethod: "parental_gate_close")
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white.opacity(0.8))
                            .padding()
                    }
                }
                .interactiveDismissDisabled(false)
            } else {
                ZStack(alignment: .topTrailing) {
                    if horizontalSizeClass == .regular {
                        // iPad: full screen cover
                        if let offering = currentOffering {
                            RevenueCatUI.PaywallView(offering: offering)
                                .edgesIgnoringSafeArea(.all)
                                .onReceive(NotificationCenter.default.publisher(for: .purchaseCompleted)) { notification in
                                    lastPurchaseInfo = notification.userInfo
                                    handlePurchaseCompleted()
                                }
                        } else {
                            ProgressView()
                                .onAppear {
                                    loadOfferings()
                                }
                        }
                    } else {
                        // iPhone: sheet style
                        if let offering = currentOffering {
                            RevenueCatUI.PaywallView(offering: offering)
                                .onReceive(NotificationCenter.default.publisher(for: .purchaseCompleted)) { notification in
                                    lastPurchaseInfo = notification.userInfo
                                    handlePurchaseCompleted()
                                }
                        } else {
                            ProgressView()
                                .onAppear {
                                    loadOfferings()
                                }
                        }
                    }
                    
                    // Close button for paywall (only show on iPad)
                    if horizontalSizeClass == .regular {
                        Button(action: {
                            dismissPaywall(dismissalMethod: "close_button")
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white.opacity(0.8))
                                .padding()
                        }
                    }
                }
                .interactiveDismissDisabled(false)
            }
        }
        .onAppear {
            paywallStartTime = Date()
            purchaseAttempted = false
            lastPurchaseInfo = nil
            loadOfferings()
            
            // Track paywall shown
            iapAnalytics.trackPaywallShown(
                source: "paywall_view",
                userType: "non_subscriber"
            )
        }
        .onDisappear {
            // Only track dismissal if no purchase was completed
            if !purchaseAttempted {
                let timeSpent = Date().timeIntervalSince(paywallStartTime)
                iapAnalytics.trackPaywallDismissedWithoutPurchase(
                    source: "paywall_view",
                    timeSpent: timeSpent,
                    userType: "non_subscriber",
                    dismissalMethod: "sheet_dismiss"
                )
            }
        }
    }
    
    private func dismissPaywall(dismissalMethod: String) {
        let timeSpent = Date().timeIntervalSince(paywallStartTime)
        iapAnalytics.trackPaywallDismissedWithoutPurchase(
            source: "paywall_view",
            timeSpent: timeSpent,
            userType: "non_subscriber",
            dismissalMethod: dismissalMethod
        )
        isPaywallPresented = false
    }
    
    private func handlePurchaseCompleted() {
        purchaseAttempted = true
        let timeSpent = Date().timeIntervalSince(paywallStartTime)
        
        // Get product details from the stored notification info
        if let userInfo = lastPurchaseInfo,
           let productId = userInfo["productId"] as? String {
            
            // Track paywall purchase completed with actual product details
            iapAnalytics.trackPaywallPurchaseCompleted(
                source: "paywall_view",
                productId: productId,
                price: 0, // Will be updated when we get product details
                currency: "USD",
                userType: "non_subscriber"
            )
        } else {
            // Fallback tracking
            iapAnalytics.trackPaywallPurchaseCompleted(
                source: "paywall_view",
                productId: "subscription",
                price: 0,
                currency: "USD",
                userType: "non_subscriber"
            )
        }
        
        // Close the paywall after successful purchase
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isPaywallPresented = false
        }
    }
    
    private func loadOfferings() {
        // Clear RevenueCat cache
        Purchases.shared.invalidateCustomerInfoCache()
        
        Purchases.shared.getOfferings { offerings, error in
            if let error = error {
                print("RevenueCat Offerings Error: \(error.localizedDescription)")
                return
            }
            
            if let offering = offerings?.current {
                print("RevenueCat: Successfully loaded offering - \(offering)")
                // Debug print all packages and their prices
                for package in offering.availablePackages {
                    print("Package: \(package.identifier)")
                    print("Product ID: \(package.storeProduct.productIdentifier)")
                    print("Price: \(package.storeProduct.price)")
                    print("Localized Price: \(package.storeProduct.localizedPriceString)")
                    print("Subscription Period: \(package.storeProduct.subscriptionPeriod?.unit.asReadableString ?? "none")")
                    print("---")
                }
                currentOffering = offering
            } else {
                print("RevenueCat: No offerings available")
            }
        }
    }
} 