//
//  ProfileView.swift
//  BoxFort
//
//  Created by Matthew Ryan on 4/11/25.
//

import SwiftUI
import StoreKit
import FirebaseAnalytics
import FirebaseAuth
import Foundation

// Main Profile View
struct ProfileView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var authService: AuthenticationService
    @Environment(\.presentationMode) var presentationMode
    @State private var showingAddChild = false
    @State private var showingPhotoUpload = false
    @State private var showingCharacterCreator = false
    @State private var showingDebugPanel = false
    @State private var showingLoginSheet = false
    @State private var showingRegisterSheet = false
    @State private var showingDeleteConfirmation = false
    @State private var isDeleting = false
    @State private var deleteErrorMessage: String?
    @State private var isRestoring = false
    @State private var restorationMessage: String?
    @StateObject private var iapAnalytics = IAPAnalyticsService.shared
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                VStack(spacing: 20) {
                    Text("Account")
                        .font(Font.custom("LondrinaSolid-Regular", size: 38))
                        .foregroundColor(.white)
                        .padding(.top, 40)
                    
                    // Group links in sections
                    VStack(spacing: 25) {
                        authenticationSection
                        subscriptionSection
                        debugSection
                        qbiesPromoSection
                    }
                }
                .padding(.horizontal)
            }
            .background(GradientBackgroundView())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .sheet(isPresented: $showingLoginSheet) {
            LoginView(authService: authService)
        }
        .sheet(isPresented: $showingRegisterSheet) {
            RegisterView(authService: authService)
        }
        #if DEBUG
        .sheet(isPresented: $showingDebugPanel) {
            DebugAnalyticsView()
        }
        #endif
        .alert("Delete Account", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("Are you sure you want to delete your account? This action cannot be undone.")
        }
        .alert("Error", isPresented: .constant(deleteErrorMessage != nil)) {
            Button("OK") {
                deleteErrorMessage = nil
            }
        } message: {
            if let error = deleteErrorMessage {
                Text(error)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var authenticationSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Account")
                .font(Font.custom("LondrinaSolid-Regular", size: 24))
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal)
            
            if !authService.isAuthenticated {
                VStack(spacing: 12) {
                    loginButton
                    registerButton
                }
            } else {
                VStack(spacing: 12) {
                    userInfoRow
                    deleteAccountButton
                }
            }
        }
    }
    
    private var loginButton: some View {
        Button(action: { showingLoginSheet = true }) {
            HStack {
                Image(systemName: "person.fill")
                    .foregroundColor(.white)
                Text("Login")
                    .font(Font.custom("LondrinaSolid-Light", size: 18))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .opacity(0.7)
            }
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
    
    private var registerButton: some View {
        Button(action: { showingRegisterSheet = true }) {
            HStack {
                Image(systemName: "person.badge.plus")
                    .foregroundColor(.white)
                Text("Register")
                    .font(Font.custom("LondrinaSolid-Light", size: 18))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .opacity(0.7)
            }
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
    
    private var userInfoRow: some View {
        HStack {
            Image(systemName: "person.fill")
                .foregroundColor(.white)
            Text(authService.currentUser?.email ?? "User")
                .font(Font.custom("LondrinaSolid-Light", size: 18))
                .foregroundColor(.white)
            Spacer()
            Button(action: { authService.logout() }) {
                Text("Logout")
                    .font(Font.custom("LondrinaSolid-Light", size: 16))
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var deleteAccountButton: some View {
        Button(action: { showingDeleteConfirmation = true }) {
            HStack {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                Text("Delete Account")
                    .font(Font.custom("LondrinaSolid-Light", size: 18))
                Spacer()
            }
            .foregroundColor(.red)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
    
    private var subscriptionSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Subscription")
                .font(Font.custom("LondrinaSolid-Regular", size: 24))
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal)
            
            // Restore Purchases Button
            Button(action: {
                Task {
                    isRestoring = true
                    restorationMessage = "Restoring purchases..."
                    await userViewModel.restorePurchases()
                    restorationMessage = "Purchases restored!"
                    // Show success message briefly
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        restorationMessage = nil
                    }
                    isRestoring = false
                }
            }) {
                HStack {
                    if isRestoring {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.trailing, 8)
                    }
                    Text("Restore Purchases")
                        .font(Font.custom("LondrinaSolid-Light", size: 20))
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(10)
            }
            .disabled(isRestoring)
            
            if let message = restorationMessage {
                Text(message)
                    .font(Font.custom("LondrinaSolid-Light", size: 18))
                    .foregroundColor(.white)
                    .transition(.opacity)
                    .animation(.easeInOut, value: restorationMessage)
            }
        }
    }
    
    private var debugSection: some View {
        #if DEBUG
        VStack(alignment: .leading, spacing: 15) {
            Text("Debug")
                .font(Font.custom("LondrinaSolid-Regular", size: 24))
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal)
            
            Button(action: { showingDebugPanel = true }) {
                HStack {
                    Image(systemName: "ladybug")
                        .foregroundColor(.white)
                    Text("Analytics Debug")
                        .font(Font.custom("LondrinaSolid-Light", size: 18))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .opacity(0.7)
                }
                .foregroundColor(.white)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            
            
        }
        #else
        EmptyView()
        #endif
    }
    
    private var qbiesPromoSection: some View {
        VStack(alignment: .leading) {
            Button(action: {
                if let url = URL(string: "https://apps.apple.com/us/app/qbies-marshmallow-collector/id6738206052") {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack {
                    Image("qbies_promo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .cornerRadius(10)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Qbies: Marshmallow Collector")
                            .font(Font.custom("LondrinaSolid-Light", size: 18))
                            .foregroundColor(.white)
                        Text("Collect marshmallows in this cozy puzzle game!")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func deleteAccount() {
        isDeleting = true
        authService.deleteAccount { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Account deleted successfully
                    break
                case .failure(let error):
                    deleteErrorMessage = error.localizedDescription
                }
                isDeleting = false
            }
        }
    }
}

// MARK: - Debug Analytics View
#if DEBUG
struct DebugAnalyticsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var iapAnalytics = IAPAnalyticsService.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Analytics Debug Panel")
                        .font(.title)
                        .padding()
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Recent Events Sent:")
                            .font(.headline)
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("• app_store_subscription_convert")
                                Text("• app_store_subscription_purchase")
                                Text("• app_store_subscription_trial_started")
                                Text("• paywall_shown")
                                Text("• paywall_dismissed")
                                Text("• book_reading_completed")
                                Text("• onboarding_book_selected")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .frame(maxHeight: 200)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    VStack(spacing: 10) {
                        Text("Test Events:")
                            .font(.headline)
                        
                        Button("Test Subscription Convert") {
                            iapAnalytics.trackSubscriptionConvert(
                                productId: "debug_test",
                                price: Decimal(9.99),
                                currency: "USD",
                                period: "month",
                                previousStatus: "trial"
                            )
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Test Trial Started") {
                            iapAnalytics.trackSubscriptionTrialStarted(
                                productId: "debug_test",
                                trialDuration: "7_days",
                                source: "debug_test"
                            )
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Test Paywall Shown") {
                            iapAnalytics.trackPaywallShown(
                                source: "debug_test",
                                userType: "non_subscriber"
                            )
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
#endif

// Helper view for consistent link styling
struct LinkButton: View {
    let icon: String
    let text: String
    let url: String
    
    var body: some View {
        Link(destination: URL(string: url)!) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white)
                Text(text)
                    .font(Font.custom("LondrinaSolid-Light", size: 18))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .opacity(0.7)
            }
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
}


