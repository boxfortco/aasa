//
//  CoReadingSession.swift
//  BoxFort
//
//  Created by Matthew Ryan on 4/11/25.
//


import Foundation

struct CoReadingSession: Identifiable, Equatable {
    let id: UUID
    let bookId: String
    let hostId: String
    let participants: [Participant]
    var currentPage: Int
    var isActive: Bool
    var startTime: Date
    
    struct Participant: Identifiable, Equatable {
        let id: String
        let name: String
        let role: ParticipantRole
        var isConnected: Bool
    }
    
    enum ParticipantRole: String, Equatable {
        case host
        case reader
        case listener
    }
    
    init(id: UUID = UUID(), bookId: String, hostId: String, participants: [Participant], currentPage: Int = 0, isActive: Bool = true, startTime: Date = Date()) {
        self.id = id
        self.bookId = bookId
        self.hostId = hostId
        self.participants = participants
        self.currentPage = currentPage
        self.isActive = isActive
        self.startTime = startTime
    }
} 
