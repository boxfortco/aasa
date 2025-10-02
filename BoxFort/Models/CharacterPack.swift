import Foundation
import SwiftUI

// MARK: - Character Part Types
enum CharacterPartType: String, CaseIterable, Codable {
    case head = "head"
    case torso = "torso"
    case legs = "legs"
    
    var displayName: String {
        switch self {
        case .head: return "Head"
        case .torso: return "Body"
        case .legs: return "Legs"
        }
    }
}

// MARK: - Character Part
struct CharacterPart: Identifiable, Codable {
    let id: String
    let name: String
    let imageName: String
    let partType: CharacterPartType
    let packId: String
    let isUnlocked: Bool
    
    init(id: String, name: String, imageName: String, partType: CharacterPartType, packId: String, isUnlocked: Bool = false) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.partType = partType
        self.packId = packId
        self.isUnlocked = isUnlocked
    }
}

// MARK: - Character Pack
struct CharacterPack: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let unlockBookId: String
    let unlockBookTitle: String
    let parts: [CharacterPart]
    let isUnlocked: Bool
    
    init(id: String, name: String, description: String, unlockBookId: String, unlockBookTitle: String, parts: [CharacterPart], isUnlocked: Bool = false) {
        self.id = id
        self.name = name
        self.description = description
        self.unlockBookId = unlockBookId
        self.unlockBookTitle = unlockBookTitle
        self.parts = parts
        self.isUnlocked = isUnlocked
    }
}

// MARK: - Character Creation
struct CharacterCreation: Identifiable {
    let id = UUID()
    var headPart: CharacterPart?
    var torsoPart: CharacterPart?
    var legsPart: CharacterPart?
    
    var isComplete: Bool {
        return headPart != nil && torsoPart != nil && legsPart != nil
    }
    
    var displayName: String {
        let headName = headPart?.name ?? "Unknown"
        let torsoName = torsoPart?.name ?? "Unknown"
        let legsName = legsPart?.name ?? "Unknown"
        return "\(headName) \(torsoName) \(legsName)"
    }
}

// MARK: - Character Pack Manager
class CharacterPackManager: ObservableObject {
    static let shared = CharacterPackManager()
    
    @Published var unlockedPacks: Set<String> = []
    @Published var availablePacks: [CharacterPack] = []
    
    private let unlockedPacksKey = "unlockedCharacterPacks"
    
    private init() {
        loadUnlockedPacks()
        setupDefaultPacks()
    }
    
    private func loadUnlockedPacks() {
        if let savedPacks = UserDefaults.standard.stringArray(forKey: unlockedPacksKey) {
            unlockedPacks = Set(savedPacks)
        }
    }
    
    private func saveUnlockedPacks() {
        UserDefaults.standard.set(Array(unlockedPacks), forKey: unlockedPacksKey)
    }
    
    private func setupDefaultPacks() {
        // Default pack that's always available
        let defaultPack = CharacterPack(
            id: "default",
            name: "Basic Characters",
            description: "Start with these basic character parts",
            unlockBookId: "",
            unlockBookTitle: "Always Available",
            parts: [
                CharacterPart(id: "default_head_1", name: "Basic Head", imageName: "character_head_basic_1", partType: .head, packId: "default", isUnlocked: true),
                CharacterPart(id: "default_head_2", name: "Round Head", imageName: "character_head_basic_2", partType: .head, packId: "default", isUnlocked: true),
                CharacterPart(id: "default_head_3", name: "Round Head", imageName: "character_head_basic_3", partType: .head, packId: "default", isUnlocked: true),
                CharacterPart(id: "default_head_4", name: "Round Head", imageName: "character_head_basic_4", partType: .head, packId: "default", isUnlocked: true),
                CharacterPart(id: "default_torso_1", name: "Basic Body", imageName: "character_torso_basic_1", partType: .torso, packId: "default", isUnlocked: true),
                CharacterPart(id: "default_torso_2", name: "Square Body", imageName: "character_torso_basic_2", partType: .torso, packId: "default", isUnlocked: true),
                CharacterPart(id: "default_torso_3", name: "Square Body", imageName: "character_torso_basic_3", partType: .torso, packId: "default", isUnlocked: true),
                CharacterPart(id: "default_torso_4", name: "Square Body", imageName: "character_torso_basic_4", partType: .torso, packId: "default", isUnlocked: true),
                CharacterPart(id: "default_legs_1", name: "Basic Legs", imageName: "character_legs_basic_1", partType: .legs, packId: "default", isUnlocked: true),
                CharacterPart(id: "default_legs_2", name: "Short Legs", imageName: "character_legs_basic_2", partType: .legs, packId: "default", isUnlocked: true),
                CharacterPart(id: "default_legs_3", name: "Short Legs", imageName: "character_legs_basic_3", partType: .legs, packId: "default", isUnlocked: true),
                CharacterPart(id: "default_legs_4", name: "Short Legs", imageName: "character_legs_basic_4", partType: .legs, packId: "default", isUnlocked: true)
            ],
            isUnlocked: true
        )
        
        // Patrick pack - unlocked by reading Patrick books
        let patrickPack = CharacterPack(
            id: "patrick",
            name: "Patrick Pack",
            description: "Unlock Patrick's character parts by reading his stories",
            unlockBookId: "thebox",
            unlockBookTitle: "The Box",
            parts: [
                CharacterPart(id: "patrick_head_1", name: "Patrick Head", imageName: "character_head_patrick_1", partType: .head, packId: "patrick"),
                CharacterPart(id: "patrick_head_2", name: "Patrick Smile", imageName: "character_head_patrick_2", partType: .head, packId: "patrick"),
                CharacterPart(id: "patrick_torso_1", name: "Patrick Body", imageName: "character_torso_patrick_1", partType: .torso, packId: "patrick"),
                CharacterPart(id: "patrick_torso_2", name: "Patrick Shirt", imageName: "character_torso_patrick_2", partType: .torso, packId: "patrick"),
                CharacterPart(id: "patrick_legs_1", name: "Patrick Legs", imageName: "character_legs_patrick_1", partType: .legs, packId: "patrick"),
                CharacterPart(id: "patrick_legs_2", name: "Patrick Shoes", imageName: "character_legs_patrick_2", partType: .legs, packId: "patrick")
            ],
            isUnlocked: unlockedPacks.contains("patrick")
        )
        
        // Kevin pack - unlocked by reading Kevin books
        let kevinPack = CharacterPack(
            id: "kevin",
            name: "Kevin Pack",
            description: "Unlock Kevin's character parts by reading his stories",
            unlockBookId: "thebigblueberry",
            unlockBookTitle: "The Big Blueberry",
            parts: [
                CharacterPart(id: "kevin_head_1", name: "Kevin Head", imageName: "character_head_kevin_1", partType: .head, packId: "kevin"),
                CharacterPart(id: "kevin_head_2", name: "Kevin Hair", imageName: "character_head_kevin_2", partType: .head, packId: "kevin"),
                CharacterPart(id: "kevin_torso_1", name: "Kevin Body", imageName: "character_torso_kevin_1", partType: .torso, packId: "kevin"),
                CharacterPart(id: "kevin_torso_2", name: "Kevin Shirt", imageName: "character_torso_kevin_2", partType: .torso, packId: "kevin"),
                CharacterPart(id: "kevin_legs_1", name: "Kevin Legs", imageName: "character_legs_kevin_1", partType: .legs, packId: "kevin"),
                CharacterPart(id: "kevin_legs_2", name: "Kevin Pants", imageName: "character_legs_kevin_2", partType: .legs, packId: "kevin")
            ],
            isUnlocked: unlockedPacks.contains("kevin")
        )
        
        // Arty pack - unlocked by reading Arty books
        let artyPack = CharacterPack(
            id: "arty",
            name: "Arty Pack",
            description: "Unlock Arty's character parts by reading his stories",
            unlockBookId: "anartyforallseasons",
            unlockBookTitle: "An Arty For All Seasons",
            parts: [
                CharacterPart(id: "arty_head_1", name: "Arty Head", imageName: "character_head_arty_1", partType: .head, packId: "arty"),
                CharacterPart(id: "arty_head_2", name: "Arty Hat", imageName: "character_head_arty_2", partType: .head, packId: "arty"),
                CharacterPart(id: "arty_torso_1", name: "Arty Body", imageName: "character_torso_arty_1", partType: .torso, packId: "arty"),
                CharacterPart(id: "arty_torso_2", name: "Arty Coat", imageName: "character_torso_arty_2", partType: .torso, packId: "arty"),
                CharacterPart(id: "arty_legs_1", name: "Arty Legs", imageName: "character_legs_arty_1", partType: .legs, packId: "arty"),
                CharacterPart(id: "arty_legs_2", name: "Arty Boots", imageName: "character_legs_arty_2", partType: .legs, packId: "arty")
            ],
            isUnlocked: unlockedPacks.contains("arty")
        )
        
        availablePacks = [defaultPack, patrickPack, kevinPack, artyPack]
    }
    
    func unlockPack(for bookId: String) {
        let packToUnlock = availablePacks.first { $0.unlockBookId == bookId }
        
        if let pack = packToUnlock, !unlockedPacks.contains(pack.id) {
            unlockedPacks.insert(pack.id)
            saveUnlockedPacks()
            
            // Update the pack's unlocked status
            if let index = availablePacks.firstIndex(where: { $0.id == pack.id }) {
                availablePacks[index] = CharacterPack(
                    id: pack.id,
                    name: pack.name,
                    description: pack.description,
                    unlockBookId: pack.unlockBookId,
                    unlockBookTitle: pack.unlockBookTitle,
                    parts: pack.parts.map { part in
                        CharacterPart(
                            id: part.id,
                            name: part.name,
                            imageName: part.imageName,
                            partType: part.partType,
                            packId: part.packId,
                            isUnlocked: true
                        )
                    },
                    isUnlocked: true
                )
            }
        }
    }
    
    func getAvailableParts(for type: CharacterPartType) -> [CharacterPart] {
        return availablePacks.flatMap { pack in
            pack.parts.filter { part in
                part.partType == type && (pack.isUnlocked || part.isUnlocked)
            }
        }
    }
    
    func checkForUnlocks(completedBooks: Set<String>) {
        for bookId in completedBooks {
            unlockPack(for: bookId)
        }
    }
} 