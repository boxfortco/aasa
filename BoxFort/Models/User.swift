import Foundation
import FirebaseAuth
import SwiftUI

struct ChildProfile: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var age: Int
    var avatarId: String
    var favorites: [String] // Book IDs
    var lastReadDate: Date?
    
    init(name: String, age: Int, avatarId: String = "patrick") {
        self.id = UUID().uuidString
        self.name = name
        self.age = age
        self.avatarId = avatarId
        self.favorites = []
        self.lastReadDate = nil
    }
    
    init(id: String, name: String, age: Int, avatarId: String, favorites: [String] = [], lastReadDate: Date? = nil) {
        self.id = id
        self.name = name
        self.age = age
        self.avatarId = avatarId
        self.favorites = favorites
        self.lastReadDate = lastReadDate
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, age, avatarId, favorites, lastReadDate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        age = try container.decode(Int.self, forKey: .age)
        avatarId = try container.decode(String.self, forKey: .avatarId)
        favorites = try container.decode([String].self, forKey: .favorites)
        
        // Handle lastReadDate that could be string or timestamp
        if let dateString = try? container.decode(String.self, forKey: .lastReadDate) {
            let formatter = ISO8601DateFormatter()
            lastReadDate = formatter.date(from: dateString)
        } else {
            lastReadDate = nil
        }
    }
    
    var avatar: Avatar? {
        Avatar.allAvatars.first { $0.id == avatarId }
    }
    
    mutating func toggleFavorite(bookId: String) {
        if favorites.contains(bookId) {
            favorites.removeAll { $0 == bookId }
        } else {
            favorites.append(bookId)
        }
    }
    
    static func == (lhs: ChildProfile, rhs: ChildProfile) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.age == rhs.age &&
               lhs.avatarId == rhs.avatarId &&
               lhs.favorites == rhs.favorites &&
               lhs.lastReadDate == rhs.lastReadDate
    }
}

enum LoyaltyTier: String, Codable {
    case bronze = "Bronze"
    case silver = "Silver"
    case gold = "Gold"
    case platinum = "Platinum"
    
    var iconName: String {
        switch self {
        case .bronze: return "star.fill"
        case .silver: return "star.fill"
        case .gold: return "star.fill"
        case .platinum: return "star.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .bronze: return .brown
        case .silver: return .gray
        case .gold: return .yellow
        case .platinum: return .blue
        }
    }
    
    var nextTier: LoyaltyTier? {
        switch self {
        case .bronze: return .silver
        case .silver: return .gold
        case .gold: return .platinum
        case .platinum: return nil
        }
    }
    
    var requiredPoints: Int {
        switch self {
        case .bronze: return 0
        case .silver: return 100
        case .gold: return 500
        case .platinum: return 1000
        }
    }
    
    var benefits: [String] {
        switch self {
        case .bronze:
            return [
                "Access to all stories",
                "Basic reading features",
                "Save favorite stories",
                "Daily reading streak tracking",
                "Basic book recommendations"
            ]
        case .silver:
            return [
                "All Bronze benefits",
                "Exclusive character wallpapers",
                "Behind-the-scenes sketches",
                "Early access to new stories (1 week)",
                "Monthly creator updates",
                "Priority book recommendations",
                "Monthly reading challenges"
            ]
        case .gold:
            return [
                "All Silver benefits",
                "Early access to new stories (2 weeks)",
                "Exclusive story previews",
                "Name in credits of new stories",
                "Monthly Q&A with creator",
                "Personalized reading plans",
                "Priority customer support",
                "Monthly book credits"
            ]
        case .platinum:
            return [
                "All Gold benefits",
                "Early access to new stories (1 month)",
                "Exclusive story concepts",
                "Vote on future story ideas",
                "Priority support",
                "Special thank you in credits",
                "VIP book recommendations",
                "Exclusive author interactions",
                "Custom reading challenges",
                "Premium customer support",
                "Unlimited book credits"
            ]
        }
    }
}

struct User: Identifiable, Codable, Equatable {
    let id: String
    let email: String
    let parentName: String
    var children: [ChildProfile]
    var isSubscribedToNewsletter: Bool
    var lastReadDate: Date?
    var loyaltyPoints: Int
    var loyaltyTier: LoyaltyTier
    var streakDays: Int
    var lastActivityDate: Date?
    var gardenStatus: GardenStatus?
    
    enum CodingKeys: String, CodingKey {
        case id, email, parentName, children, isSubscribedToNewsletter
        case lastReadDate, loyaltyPoints, loyaltyTier, streakDays
        case lastActivityDate, gardenStatus
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        parentName = try container.decode(String.self, forKey: .parentName)
        children = try container.decode([ChildProfile].self, forKey: .children)
        isSubscribedToNewsletter = try container.decode(Bool.self, forKey: .isSubscribedToNewsletter)
        loyaltyPoints = try container.decode(Int.self, forKey: .loyaltyPoints)
        loyaltyTier = try container.decode(LoyaltyTier.self, forKey: .loyaltyTier)
        streakDays = try container.decode(Int.self, forKey: .streakDays)
        gardenStatus = try container.decodeIfPresent(GardenStatus.self, forKey: .gardenStatus)
        
        // Handle lastReadDate
        if let dateString = try? container.decode(String.self, forKey: .lastReadDate) {
            let formatter = ISO8601DateFormatter()
            lastReadDate = formatter.date(from: dateString)
        } else {
            lastReadDate = nil
        }
        
        // Handle lastActivityDate
        if let dateString = try? container.decode(String.self, forKey: .lastActivityDate) {
            let formatter = ISO8601DateFormatter()
            lastActivityDate = formatter.date(from: dateString)
        } else if let timestamp = try? container.decode(Double.self, forKey: .lastActivityDate) {
            lastActivityDate = Date(timeIntervalSince1970: timestamp)
        } else {
            lastActivityDate = nil
        }
    }
    
    init(from firebaseUser: FirebaseAuth.User, parentName: String) {
        self.id = firebaseUser.uid
        self.email = firebaseUser.email ?? ""
        self.parentName = parentName
        self.children = []
        self.isSubscribedToNewsletter = false
        self.loyaltyPoints = 0
        self.loyaltyTier = .bronze
        self.streakDays = 0
        self.lastActivityDate = nil
        self.gardenStatus = nil
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id &&
               lhs.email == rhs.email &&
               lhs.parentName == rhs.parentName &&
               lhs.children == rhs.children &&
               lhs.isSubscribedToNewsletter == rhs.isSubscribedToNewsletter &&
               lhs.lastReadDate == rhs.lastReadDate &&
               lhs.loyaltyPoints == rhs.loyaltyPoints &&
               lhs.loyaltyTier == rhs.loyaltyTier &&
               lhs.streakDays == rhs.streakDays &&
               lhs.lastActivityDate == rhs.lastActivityDate &&
               lhs.gardenStatus == rhs.gardenStatus
    }
} 