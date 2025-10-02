//
//  CreatorSupportPlea.swift
//  BoxFort
//
//  Created by Matthew Ryan on 1/15/25.
//

import SwiftUI
import FirebaseAnalytics

struct CreatorSupportPlea: View {
    @State private var isMinimized = false
    @State private var hasBeenDismissed = false
    @State private var showingShareSheet = false
    @State private var activityItems: [Any] = []
    @State private var isPreparingShare = false
    
    var body: some View {
        if !hasBeenDismissed {
            VStack(spacing: 0) {
                if !isMinimized {
                    fullPleaView
                } else {
                    minimizedPleaView
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
            )
            .cornerRadius(16)
            .padding(.horizontal, 20)
            .onAppear {
                trackPleaShown()
            }
            .sheet(isPresented: $showingShareSheet) {
                if !activityItems.isEmpty {
                    ShareSheet(activityItems: activityItems)
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                        .onDisappear {
                            // Track if sharing was completed
                            trackPleaShareCompleted()
                        }
                }
            }
        }
    }
    
    private var fullPleaView: some View {
        VStack(spacing: 16) {
            // Header with creator icon and minimize button
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.orange)
                    
                    Text("From the creator")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                // Minimize button
                Button(action: minimizePlea) {
                    Image(systemName: "chevron.up")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Main message
            VStack(alignment: .leading, spacing: 12) {
                Text("Hi! 👋 I'm Matthew Ryan, I write, illustrate, and animate all the stories in BoxFort.")
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Text("Thank you so much for reading. If you have a moment, please consider sharing the app with friends and family. I really appreciate your support!")
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
            }
            
            // CTA buttons
            VStack(spacing: 12) {
                Button(action: showShareSheet) {
                    HStack(spacing: 8) {
                        if isPreparingShare {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "square.and.arrow.up")
                        }
                        Text(isPreparingShare ? "Preparing..." : "Share with Friends")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [Color.orange, Color.orange.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: Color.orange.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                .disabled(isPreparingShare)
                
                Button(action: dismissPlea) {
                    Text("Maybe Later")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(20)
    }
    
    private var minimizedPleaView: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.orange)
                
                Text("Support the creator - share with friends!")
                    .font(.caption)
                    .foregroundColor(.primary)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: showShareSheet) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 14))
                        .foregroundColor(.orange)
                }
                
                Button(action: expandPlea) {
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    // MARK: - Actions
    
    private func minimizePlea() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isMinimized = true
        }
        trackPleaMinimized()
    }
    
    private func expandPlea() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isMinimized = false
        }
    }
    
    private func dismissPlea() {
        withAnimation(.easeInOut(duration: 0.3)) {
            hasBeenDismissed = true
        }
        trackPleaDismissed()
        
        // Mark as permanently dismissed in the service
        CreatorSupportPleaService.shared.markPleaDismissedPermanently()
    }
    
    private func showShareSheet() {
        isPreparingShare = true
        trackPleaShareAttempted()
        
        // Prepare share content asynchronously, then show sheet
        DispatchQueue.global(qos: .userInitiated).async {
            let shareText = """
            Check out BoxFort. 50+ delightful storybooks for bedtime.
            
            Works on iPad and iPhone: https://apps.apple.com/us/app/boxfort-kids-books/id6443570027
            """
            
            DispatchQueue.main.async {
                self.activityItems = [shareText]
                self.isPreparingShare = false
                self.showingShareSheet = true
            }
        }
    }
    
    
    // MARK: - Analytics
    
    private func trackPleaShown() {
        Analytics.logEvent("creator_support_plea_shown", parameters: [
            "timestamp": Date().timeIntervalSince1970
        ])
        
        // Also notify the service that the plea was shown
        CreatorSupportPleaService.shared.markPleaShown()
    }
    
    private func trackPleaMinimized() {
        Analytics.logEvent("creator_support_plea_minimized", parameters: [
            "timestamp": Date().timeIntervalSince1970
        ])
    }
    
    private func trackPleaDismissed() {
        Analytics.logEvent("creator_support_plea_dismissed", parameters: [
            "timestamp": Date().timeIntervalSince1970
        ])
    }
    
    private func trackPleaShareAttempted() {
        Analytics.logEvent("creator_support_plea_share_attempted", parameters: [
            "timestamp": Date().timeIntervalSince1970
        ])
    }
    
    private func trackPleaShareCompleted() {
        Analytics.logEvent("creator_support_plea_share_completed", parameters: [
            "timestamp": Date().timeIntervalSince1970
        ])
    }
}


// MARK: - Preview

struct CreatorSupportPlea_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            CreatorSupportPlea()
            
            // Minimized version
            CreatorSupportPlea()
                .onAppear {
                    // Simulate minimized state
                }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
