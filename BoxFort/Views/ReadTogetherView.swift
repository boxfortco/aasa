//
//  ReadTogetherView.swift
//  BoxFort
//
//  Created by Matthew Ryan on 4/11/25.
//

import SwiftUI
import FirebaseAnalytics
import FirebaseDatabase

struct ReadTogetherView: View {
    let book: Book
    @Binding var isPresented: Bool
    @Binding var sessionId: String?
    @Binding var isActive: Bool
    @StateObject private var sessionManager = ReadTogetherSessionManager.shared
    @EnvironmentObject var userViewModel: UserViewModel
    
    @State private var localSessionId: String?
    @State private var currentPage = 0
    @State private var isHost = true
    @State private var showShareSheet = false
    @State private var shareURL = ""
    @State private var showEndSessionAlert = false
    @State private var showSuccessMessage = false
    @State private var showSignInAlert = false
    @State private var sessionObserver: DatabaseHandle?
    @State private var hasSharedLink = false
    @State private var showingProfile = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Text("📚 Read Together")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(book.title)
                            .font(.title2)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    
                    // Book Preview
                    if let bookImage = UIImage(named: book.posterImage) {
                        Image(uiImage: bookImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                            .cornerRadius(12)
                            .shadow(radius: 8)
                    }
                    
                    // Status
                    if sessionId != nil {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Session Active")
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(20)
                    }
                    
                    // Instructions
                    VStack(spacing: 12) {
                        Text("How it works:")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("1.")
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                Text("Share the link with family")
                                    .font(.body)
                            }
                            
                            HStack {
                                Text("2.")
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                Text("Call them on FaceTime")
                                    .font(.body)
                            }
                            
                            HStack {
                                Text("3.")
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                Text("Turn pages - they see it too!")
                                    .font(.body)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Sign in reminder for subscribed but not authenticated users
                        if userViewModel.isSubscriptionActive && userViewModel.user == nil {
                            VStack(spacing: 12) {
                                Divider()
                                
                                HStack {
                                    Image(systemName: "person.circle")
                                        .foregroundColor(.orange)
                                    Text("Sign in required for Read Together")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                                
                                Text("You're subscribed! Just sign in to start reading together with family.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                // Action buttons
                                HStack(spacing: 12) {
                                    Button(action: { showingProfile = true }) {
                                        HStack {
                                            Image(systemName: "person.fill")
                                            Text("Sign In")
                                        }
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.blue)
                                        .cornerRadius(8)
                                    }
                                    
                                    Button(action: { showingProfile = true }) {
                                        HStack {
                                            Image(systemName: "person.badge.plus")
                                            Text("Register")
                                        }
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.green)
                                        .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        if sessionId == nil {
                            Button(action: startSession) {
                                HStack {
                                    Image(systemName: "play.circle.fill")
                                    Text("Start Reading Together")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                            }
                            .disabled(!canStartSession)
                        } else {
                            VStack(spacing: 12) {
                                if !hasSharedLink {
                                    Text("📤 Share the link first, then start reading!")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                
                                Button(action: { showShareSheet = true }) {
                                    HStack {
                                        Image(systemName: "square.and.arrow.up")
                                        Text("Share Reading Link")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .cornerRadius(12)
                                }
                                
                                if hasSharedLink {
                                    Button(action: {
                                        isPresented = false
                                    }) {
                                        HStack {
                                            Image(systemName: "book.fill")
                                            Text("Start Reading")
                                        }
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .cornerRadius(12)
                                    }
                                }
                            }
                            
                            if sessionId != nil {
                                Button(action: { 
                                    endSession()
                                }) {
                                    HStack {
                                        Image(systemName: "stop.circle")
                                        Text("End Reading Session")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red)
                                    .cornerRadius(12)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Read Together")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                }
            )
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [shareMessage])
                .onDisappear {
                    // Assume they shared if they opened the share sheet
                    hasSharedLink = true
                }
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView()
        }
        .alert("End Reading Session?", isPresented: $showEndSessionAlert) {
            Button("Cancel", role: .cancel) { }
            Button("End Session", role: .destructive) {
                endSession()
            }
        } message: {
            Text("This will stop sharing the book with your reading partner.")
        }
        .alert("Ready to Read Together!", isPresented: $showSuccessMessage) {
            Button("Share Link") { 
                showShareSheet = true
            }
        } message: {
            Text("Share the link with someone special. They'll see every page as you turn them!")
        }
        .alert("Sign In Required", isPresented: $showSignInAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign In") {
                showingProfile = true
            }
        } message: {
            Text("To use Read Together, you need to sign in with your account. This helps us keep your reading sessions secure and private.")
        }
        .onAppear {
            // Check if user has subscription
            if !userViewModel.isSubscriptionActive {
                // Show subscription required message
                return
            }
        }
        .onDisappear {
            // Clean up observer if needed
            if let sessionId = sessionId, let observer = sessionObserver {
                sessionManager.removeObserver(sessionId: sessionId, handle: observer)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var canStartSession: Bool {
        return userViewModel.isSubscriptionActive && sessionId == nil
    }
    
    private var shareMessage: String {
        let message = """
        Let's read together! Open this link to follow along:
        
        \(shareURL)
        
        Then call me on FaceTime so we can read together! 📚
        """
        return message
    }
    
    // MARK: - Actions
    
    private func startSession() {
        sessionManager.createSession(bookId: book.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let url):
                    self.shareURL = url
                    self.localSessionId = String(url.components(separatedBy: "/").last ?? "")
                    self.sessionId = self.localSessionId
                    self.isActive = true
                    self.showSuccessMessage = true
                    
                    // Start observing session updates
                    self.observeSession()
                    
                case .failure(let error):
                    print("Failed to create session: \(error.localizedDescription)")
                    
                    // Check if it's an authentication error
                    if let readTogetherError = error as? ReadTogetherError,
                       case .notAuthenticated = readTogetherError {
                        self.showSignInAlert = true
                    } else {
                        // Show generic error message
                        // You could add another alert state for generic errors if needed
                        print("Other error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func observeSession() {
        guard let sessionId = localSessionId else { return }
        
        sessionObserver = sessionManager.observeSession(sessionId: sessionId) { update in
            DispatchQueue.main.async {
                self.currentPage = update.currentPage
                
                if update.status == "ended" {
                    self.sessionId = nil
                    self.sessionObserver = nil
                }
            }
        }
    }
    
    private func endSession() {
        guard let sessionId = sessionId else { return }
        
        // End the session in Firebase
        sessionManager.endSession(sessionId: sessionId)
        
        // Clean up local state
        self.localSessionId = nil
        self.sessionId = nil
        self.isActive = false
        
        if let observer = sessionObserver {
            sessionManager.removeObserver(sessionId: sessionId, handle: observer)
            sessionObserver = nil
        }
        
        // Close the modal and return to book view
        isPresented = false
    }
}


// MARK: - Preview

#if DEBUG
struct ReadTogetherView_Previews: PreviewProvider {
    static var previews: some View {
        ReadTogetherView(
            book: Book.sampleBooks[0],
            isPresented: .constant(true),
            sessionId: .constant(nil),
            isActive: .constant(false)
        )
        .environmentObject(UserViewModel())
    }
}
#endif
