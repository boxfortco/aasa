//
//  CoReadingService.swift
//  BoxFort
//
//  Created by Matthew Ryan on 4/11/25.
//

/*
import Foundation
import GroupActivities
import SwiftUI
import UIKit

@MainActor
class CoReadingService: ObservableObject {
    @Published private(set) var activeSession: SharedReadingSession?
    private var groupSession: GroupSession<SharedReadingActivity>?
    private var messenger: GroupSessionMessenger?
    private let websocketManager: WebSocketManager
    @Published var error: CoReadingError?
    
    init(websocketManager: WebSocketManager) {
        self.websocketManager = websocketManager
        setupGroupSessionHandling()
    }
    
    func startSharedReading(book: Book) async {
        // Create and prepare activity
        let activity = SharedReadingActivity(book: book)
        
        // Start SharePlay session
        do {
            _ = try await activity.activate()
        } catch {
            self.error = .sessionInitFailed
        }
    }
    
    private func setupGroupSessionHandling() {
        Task {
            for await session in SharedReadingActivity.sessions() {
                // Configure new session
                groupSession = session
                messenger = GroupSessionMessenger(session: session)
                
                // Create shared reading session
                let readingSession = SharedReadingSession(
                    hostDeviceId: session.id.uuidString,
                    participants: [],  // We'll update this with actual participants
                    currentPage: 0
                )
                
                self.activeSession = readingSession
                
                // Handle session messages
                guard let messenger = messenger else { return }
                for await (payload, _) in messenger.messages(of: Data.self) {
                    if let pageUpdate = try? JSONDecoder().decode(PageUpdateMessage.self, from: payload) {
                        await self.handlePageUpdate(pageUpdate)
                    }
                }
            }
        }
    }
    
    private func handlePageUpdate(_ update: PageUpdateMessage) {
        self.activeSession?.currentPage = update.page
    }
    
    func syncPage(_ newPage: Int) {
        guard let messenger = messenger else { return }
        
        Task {
            // Send through GroupSession messenger
            let message = PageUpdateMessage(page: newPage)
            if let data = try? JSONEncoder().encode(message) {
                try? await messenger.send(data)
            }
            
            // Also sync through WebSocket for non-SharePlay participants
            websocketManager.sendPageUpdate(newPage)
        }
    }
    
    func sendReaction(_ reaction: ReactionType) {
        websocketManager.sendReaction(reaction)
    }
    
    func resetSession() {
        activeSession = nil
        groupSession = nil
        messenger = nil
    }
    
    // Core functionality
    func hostSession(book: Book, participants: [String]) async throws -> CoReadingSession {
        // Convert string participants to CoReadingSession.Participant objects
        let sessionParticipants = participants.map { participantId in
            CoReadingSession.Participant(
                id: participantId,
                name: "Participant \(participantId)",
                role: .reader,
                isConnected: false
            )
        }
        
        // Initialize session
        let session = CoReadingSession(
            bookId: book.id,
            hostId: UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString,
            participants: sessionParticipants,
            currentPage: 0
        )
        
        // TODO: Send invites to participants
        // TODO: Setup WebRTC connections
        
        return session
    }
    
    func joinSession(sessionId: UUID) async throws {
        // Connect to existing session
        // Sync current page and status
    }
    
    // Interactive features
    func togglePointer(isVisible: Bool, position: CGPoint) {
        // Show/hide pointer for highlighting text
    }
    
    func toggleMicrophone(isOn: Bool) {
        // Manage audio communication
    }
    
    enum CallPlatform {
        case facetime
        case zoom
        case meetingLink(URL)
    }
    
    func initiateSharedReading(using platform: CallPlatform) {
        switch platform {
        case .facetime:
            if let facetimeURL = URL(string: "facetime://user@example.com") {
                UIApplication.shared.open(facetimeURL)
            }
        case .zoom:
            // Handle zoom
            break
        case .meetingLink(let url):
            UIApplication.shared.open(url)
        }
    }
}

// Message types
struct PageUpdateMessage: Codable {
    let page: Int
}

// Error types
enum CoReadingError: Error {
    case sharePlayUnavailable
    case sessionInitFailed
    case connectionLost
    case invalidParticipant
    
    var localizedDescription: String {
        switch self {
        case .sharePlayUnavailable:
            return "SharePlay is not available"
        case .sessionInitFailed:
            return "Failed to start shared reading session"
        case .connectionLost:
            return "Lost connection to reading session"
        case .invalidParticipant:
            return "Invalid participant in session"
        }
    }
}

// Helper for opening URLs
extension CoReadingService {
    func openFaceTime(with email: String) {
        if let url = URL(string: "facetime:\(email)") {
            UIApplication.shared.open(url)
        }
    }
    
    func openMeetingLink(_ url: URL) {
        UIApplication.shared.open(url)
    }
} 
*/
