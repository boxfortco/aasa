import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseAnalytics

class LoyaltyService: ObservableObject {
    static let shared = LoyaltyService()
    
    init() {}
    
    private let db = Firestore.firestore()
    
    // Points awarded for different actions
    private let pointsForReading: Int = 10
    private let pointsForDailyStreak: Int = 5
    private let pointsForReview: Int = 20
    private let pointsForReferral: Int = 50
    
    // Plant growth points
    private let pointsForRoutineCompletion: Int = 5
    private let pointsForReadingBonus: Int = 3
    
    // MARK: - Plant Management
    
    func getGardenStatus(userId: String) async throws -> GardenStatus {
        let snapshot = try await db.collection("users").document(userId).getDocument()
        guard let user = try? snapshot.data(as: User.self) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
        return user.gardenStatus ?? GardenStatus()
    }
    
    func updatePlantGrowth(userId: String, activityCompleted: String) async throws {
        let userRef = db.collection("users").document(userId)
        
        try await db.runTransaction { (transaction, errorPointer) -> Any? in
            let snapshot: DocumentSnapshot
            do {
                snapshot = try transaction.getDocument(userRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard var user = try? snapshot.data(as: User.self) else {
                return nil
            }
            
            // Initialize garden status if needed
            if user.gardenStatus == nil {
                user.gardenStatus = GardenStatus()
            }
            
            // Update plant growth
            if var currentPlant = user.gardenStatus?.currentPlant {
                // Add growth points for routine completion
                currentPlant.growthPoints += self.pointsForRoutineCompletion
                
                // Check if plant should advance to next stage
                if currentPlant.growthPoints >= currentPlant.pointsForNextStage {
                    currentPlant.growthStage += 1
                    currentPlant.growthPoints = 0
                    
                    // If plant is fully grown, move to garden
                    if currentPlant.growthStage >= 5 {
                        user.gardenStatus?.previousPlants.append(currentPlant)
                        user.gardenStatus?.currentPlant = nil
                    } else {
                        user.gardenStatus?.currentPlant = currentPlant
                    }
                } else {
                    user.gardenStatus?.currentPlant = currentPlant
                }
            }
            
            // Save changes
            do {
                try transaction.setData(from: user, forDocument: userRef)
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
            return nil
        }
    }
    
    func plantNewSeed(userId: String) async throws {
        let userRef = db.collection("users").document(userId)
        
        try await db.runTransaction { [weak self] (transaction, errorPointer) -> Any? in
            guard let self = self else { return nil }
            
            let snapshot: DocumentSnapshot
            do {
                snapshot = try transaction.getDocument(userRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard var user = try? snapshot.data(as: User.self) else {
                return nil
            }
            
            // Initialize garden status if needed
            if user.gardenStatus == nil {
                user.gardenStatus = GardenStatus()
            }
            
            // Only plant if no current plant exists
            if user.gardenStatus?.currentPlant == nil {
                let newPlant = Plant(
                    id: UUID(),
                    type: PlantType.allCases.randomElement()!,
                    variant: self.determinePlantVariant(for: user.loyaltyTier),
                    growthStage: 0,
                    growthPoints: 0,
                    pointsForNextStage: 20, // Base points needed for next stage
                    plantedDate: Date(),
                    lastWateredDate: Date()
                )
                user.gardenStatus?.currentPlant = newPlant
            }
            
            // Save changes
            do {
                try transaction.setData(from: user, forDocument: userRef)
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
            return nil
        }
    }
    
    private func determinePlantVariant(for tier: LoyaltyTier) -> PlantVariant {
        let random = Int.random(in: 1...100)
        switch tier {
        case .platinum:
            // Higher chance for rare variants
            switch random {
            case 1...10: return .crystal
            case 11...30: return .rainbow
            case 31...60: return .golden
            default: return .normal
            }
        case .gold:
            switch random {
            case 1...5: return .crystal
            case 6...20: return .rainbow
            case 21...50: return .golden
            default: return .normal
            }
        default:
            switch random {
            case 1...2: return .crystal
            case 3...10: return .rainbow
            case 11...30: return .golden
            default: return .normal
            }
        }
    }
    
    func awardPointsForReading(userId: String, bookId: String) async throws {
        // Award 10 points for reading a book
        let points = 10
        
        // TODO: Implement actual points storage and tracking
        // For now, we'll just log the points
        print("📚 Awarded \(points) loyalty points to user \(userId) for reading book \(bookId)")
        
        // In the future, this could:
        // 1. Store points in a database
        // 2. Update user's loyalty level
        // 3. Check for loyalty rewards
        // 4. Sync with backend
        
        let userRef = db.collection("users").document(userId)
        
        try await db.runTransaction { (transaction, errorPointer) -> Any? in
            let snapshot: DocumentSnapshot
            do {
                snapshot = try transaction.getDocument(userRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard var user = try? snapshot.data(as: User.self) else {
                return nil
            }
            
            // Award points for reading
            user.loyaltyPoints += self.pointsForReading
            
            // Check and update streak
            if let lastActivity = user.lastActivityDate {
                let calendar = Calendar.current
                if calendar.isDateInToday(lastActivity) {
                    // Already active today, no streak update needed
                } else if calendar.isDateInYesterday(lastActivity) {
                    // Consecutive day
                    user.streakDays += 1
                    user.loyaltyPoints += self.pointsForDailyStreak
                } else {
                    // Streak broken
                    user.streakDays = 1
                }
            } else {
                // First activity
                user.streakDays = 1
            }
            
            // Update last activity date
            user.lastActivityDate = Date()
            
            // Check and update tier
            user.loyaltyTier = self.calculateTier(points: user.loyaltyPoints)
            
            // Save changes
            do {
                try transaction.setData(from: user, forDocument: userRef)
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
            return nil
        }
    }
    
    func awardPointsForReview(userId: String) async throws {
        let userRef = db.collection("users").document(userId)
        
        try await db.runTransaction { (transaction, errorPointer) -> Any? in
            let snapshot: DocumentSnapshot
            do {
                snapshot = try transaction.getDocument(userRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard var user = try? snapshot.data(as: User.self) else {
                return nil
            }
            
            user.loyaltyPoints += self.pointsForReview
            user.loyaltyTier = self.calculateTier(points: user.loyaltyPoints)
            
            do {
                try transaction.setData(from: user, forDocument: userRef)
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
            return nil
        }
        
        // Log analytics for review points awarded
        Analytics.logEvent("review_points_awarded", parameters: [
            "user_id": userId,
            "points_awarded": self.pointsForReview
        ])
        
        print("📝 Awarded \(self.pointsForReview) loyalty points to user \(userId) for review")
    }
    
    func awardPointsForReferral(userId: String) async throws {
        let userRef = db.collection("users").document(userId)
        
        try await db.runTransaction { (transaction, errorPointer) -> Any? in
            let snapshot: DocumentSnapshot
            do {
                snapshot = try transaction.getDocument(userRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard var user = try? snapshot.data(as: User.self) else {
                return nil
            }
            
            user.loyaltyPoints += self.pointsForReferral
            user.loyaltyTier = self.calculateTier(points: user.loyaltyPoints)
            
            do {
                try transaction.setData(from: user, forDocument: userRef)
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
            return nil
        }
    }
    
    private func calculateTier(points: Int) -> LoyaltyTier {
        switch points {
        case 0..<100:
            return .bronze
        case 100..<500:
            return .silver
        case 500..<1000:
            return .gold
        default:
            return .platinum
        }
    }
    
    func getLoyaltyStatus(userId: String) async throws -> (points: Int, tier: LoyaltyTier, streak: Int) {
        let snapshot = try await db.collection("users").document(userId).getDocument()
        guard let user = try? snapshot.data(as: User.self) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
        return (user.loyaltyPoints, user.loyaltyTier, user.streakDays)
    }
}

// MARK: - Garden Models

struct GardenStatus: Codable, Equatable {
    var currentPlant: Plant?
    var previousPlants: [Plant] = []
}

struct Plant: Codable, Identifiable, Equatable {
    let id: UUID
    let type: PlantType
    let variant: PlantVariant
    var growthStage: Int
    var growthPoints: Int
    let pointsForNextStage: Int
    var plantedDate: Date
    var lastWateredDate: Date
    
    var isFullyGrown: Bool {
        growthStage >= 5
    }
    
    static func == (lhs: Plant, rhs: Plant) -> Bool {
        return lhs.id == rhs.id &&
               lhs.type == rhs.type &&
               lhs.variant == rhs.variant &&
               lhs.growthStage == rhs.growthStage &&
               lhs.growthPoints == rhs.growthPoints &&
               lhs.pointsForNextStage == rhs.pointsForNextStage &&
               lhs.plantedDate == rhs.plantedDate &&
               lhs.lastWateredDate == rhs.lastWateredDate
    }
}

enum PlantType: String, Codable, CaseIterable, Equatable {
    case blueberry = "Blueberry"
    case strawberry = "Strawberry"
    case waffleTree = "Waffle Tree"
    case candyBush = "Candy Bush"
    case rainbowFlower = "Rainbow Flower"
    case crystalPlant = "Crystal Plant"
    
    var baseImageName: String {
        "plant_\(self.rawValue.lowercased().replacingOccurrences(of: " ", with: "_"))"
    }
}

enum PlantVariant: String, Codable, CaseIterable, Equatable {
    case normal = "Normal"
    case golden = "Golden"
    case rainbow = "Rainbow"
    case crystal = "Crystal"
    
    var rarity: Int {
        switch self {
        case .normal: return 1
        case .golden: return 2
        case .rainbow: return 3
        case .crystal: return 4
        }
    }
} 