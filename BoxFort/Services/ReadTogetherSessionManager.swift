//
//  ReadTogetherSessionManager.swift
//  BoxFort
//
//  Created by Matthew Ryan on 4/11/25.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import FirebaseAnalytics

// MARK: - Data Models

struct ReadTogetherSession {
    let sessionId: String
    let bookId: String
    let currentPage: Int
    let totalPages: Int
    let hostUserId: String
    let hostName: String
    let createdAt: TimeInterval
    let expiresAt: TimeInterval
    let status: String
}

struct SessionUpdate {
    let currentPage: Int
    let totalPages: Int
    let status: String
}

// MARK: - Session Manager

class ReadTogetherSessionManager: ObservableObject {
    static let shared = ReadTogetherSessionManager()
    
    // Configuration - Update this URL to your actual domain
    private let baseURL = "https://boxfort-6a746.web.app"
    
    private let ref = Database.database().reference()
    private var observers: [String: DatabaseHandle] = [:]
    
    private init() {
        // Persistence is enabled in AppDelegate
    }
    
    // MARK: - Session Creation
    
    func createSession(bookId: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(ReadTogetherError.notAuthenticated))
            return
        }
        
        // Generate a short, user-friendly session ID
        let sessionId = generateSessionId()
        let now = Date().timeIntervalSince1970
        let expiresAt = now + 86400 // 24 hours
        
        // Create session data
        let sessionData: [String: Any] = [
            "bookId": bookId,
            "currentPage": 0,
            "totalPages": getBookPageCount(bookId: bookId),
            "hostUserId": userId,
            "hostName": UIDevice.current.name,
            "createdAt": now,
            "expiresAt": expiresAt,
            "status": "active"
        ]
        
        // Write to Firebase Realtime Database
        ref.child("readTogetherSessions").child(sessionId).setValue(sessionData) { [weak self] error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                // Track analytics
                Analytics.logEvent("read_together_session_created", parameters: [
                    "book_id": bookId,
                    "session_id": sessionId
                ])
                
                let shareURL = "\(self?.baseURL ?? "https://boxfort-6a746.web.app")/read/\(sessionId)"
                completion(.success(shareURL))
            }
        }
    }
    
    // MARK: - Session Management
    
    func observeSession(sessionId: String, onUpdate: @escaping (SessionUpdate) -> Void) -> DatabaseHandle {
        let sessionRef = ref.child("readTogetherSessions/\(sessionId)")
        
        let handle = sessionRef.observe(.value) { snapshot in
            guard let data = snapshot.value as? [String: Any] else { 
                onUpdate(SessionUpdate(currentPage: 0, totalPages: 0, status: "ended"))
                return 
            }
            
            let update = SessionUpdate(
                currentPage: data["currentPage"] as? Int ?? 0,
                totalPages: data["totalPages"] as? Int ?? 0,
                status: data["status"] as? String ?? "active"
            )
            onUpdate(update)
        }
        
        observers[sessionId] = handle
        return handle
    }
    
    func removeObserver(sessionId: String, handle: DatabaseHandle) {
        ref.child("readTogetherSessions/\(sessionId)").removeObserver(withHandle: handle)
        observers.removeValue(forKey: sessionId)
    }
    
    func updatePage(sessionId: String, page: Int) {
        ref.child("readTogetherSessions/\(sessionId)/currentPage").setValue(page)
        
        // Track page turn analytics
        Analytics.logEvent("read_together_page_turn", parameters: [
            "session_id": sessionId,
            "page": page
        ])
    }
    
    func endSession(sessionId: String) {
        print("🔥 Ending session: \(sessionId)")
        
        ref.child("readTogetherSessions/\(sessionId)/status").setValue("ended") { error, _ in
            if let error = error {
                print("❌ Failed to end session: \(error)")
            } else {
                print("✅ Session ended successfully: \(sessionId)")
            }
        }
        
        // Track session end analytics
        Analytics.logEvent("read_together_session_ended", parameters: [
            "session_id": sessionId
        ])
    }
    
    // MARK: - Helper Methods
    
    private func generateSessionId() -> String {
        // Generate a short, user-friendly session ID
        let characters = "abcdefghijklmnopqrstuvwxyz0123456789"
        let sessionId = String((0..<8).map { _ in characters.randomElement()! })
        return sessionId
    }
    
    private func getBookPageCount(bookId: String) -> Int {
        // Get page count from your existing book data
        if let book = Book.sampleBooks.first(where: { $0.id == bookId }) {
            return book.pages.count
        }
        return 0
    }
    
    func cleanupExpiredSessions() {
        let now = Date().timeIntervalSince1970
        ref.child("readTogetherSessions")
            .queryOrdered(byChild: "expiresAt")
            .queryEnding(atValue: now)
            .observeSingleEvent(of: .value) { snapshot in
                if let sessions = snapshot.value as? [String: Any] {
                    for (sessionId, _) in sessions {
                        self.ref.child("readTogetherSessions/\(sessionId)").removeValue()
                    }
                }
            }
    }
}

// MARK: - Errors

enum ReadTogetherError: LocalizedError {
    case notAuthenticated
    case sessionNotFound
    case sessionExpired
    case bookNotFound
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be signed in to create a reading session"
        case .sessionNotFound:
            return "Reading session not found. It may have expired."
        case .sessionExpired:
            return "This reading session has expired."
        case .bookNotFound:
            return "Book not found."
        }
    }
}
