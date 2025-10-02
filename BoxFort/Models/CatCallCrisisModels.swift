import Foundation
import SpriteKit

// MARK: - Game Entities
enum GameEntity {
    case player, cat, phone, task(TaskType), distraction(DistractionType)
}

// MARK: - Task Types
enum TaskType: CaseIterable {
    case toaster, laundry, plants, mail, fishFood
    
    var displayName: String {
        switch self {
        case .toaster: return "Fix Toaster"
        case .laundry: return "Do Laundry"
        case .plants: return "Water Plants"
        case .mail: return "Get Mail"
        case .fishFood: return "Feed Fish"
        }
    }
    
    var spriteName: String {
        switch self {
        case .toaster: return "toaster"
        case .laundry: return "laundry"
        case .plants: return "plants"
        case .mail: return "mail"
        case .fishFood: return "fishFood"
        }
    }
}

// MARK: - Distraction Types
enum DistractionType: CaseIterable {
    case laser, treats, catnip, cardboardBox, tape
    
    var displayName: String {
        switch self {
        case .laser: return "Laser Pointer"
        case .treats: return "Cat Treats"
        case .catnip: return "Catnip"
        case .cardboardBox: return "Cardboard Box"
        case .tape: return "Sticky Tape"
        }
    }
    
    var spriteName: String {
        switch self {
        case .laser: return "laser"
        case .treats: return "treats"
        case .catnip: return "catnip"
        case .cardboardBox: return "box"
        case .tape: return "tape"
        }
    }
    
    var effectiveness: Float {
        switch self {
        case .laser: return 0.8
        case .treats: return 0.9
        case .catnip: return 0.95
        case .cardboardBox: return 0.7
        case .tape: return 0.6
        }
    }
    
    var duration: TimeInterval {
        switch self {
        case .laser: return 8.0
        case .treats: return 12.0
        case .catnip: return 15.0
        case .cardboardBox: return 10.0
        case .tape: return 6.0
        }
    }
}

// MARK: - Cat AI States
enum CatState {
    case idle
    case phoneAlert
    case distracted(DistractionType)
    case taskComplete
    case movingToPhone
    case answeringPhone
}

// MARK: - Game Configuration
struct GameConfig {
    let houseDimensions: CGSize
    let phoneRingInterval: ClosedRange<TimeInterval>
    let taskDefinitions: [TaskType: TaskConfig]
    let distractionEffects: [DistractionType: DistractionConfig]
    let gameDuration: TimeInterval
    let maxScore: Int
    
    static let `default` = GameConfig(
        houseDimensions: CGSize(width: 16, height: 12),
        phoneRingInterval: 15.0...45.0,
        taskDefinitions: [
            .toaster: TaskConfig(points: 100, timeRequired: 3.0),
            .laundry: TaskConfig(points: 150, timeRequired: 4.0),
            .plants: TaskConfig(points: 75, timeRequired: 2.0),
            .mail: TaskConfig(points: 125, timeRequired: 3.5),
            .fishFood: TaskConfig(points: 80, timeRequired: 2.5)
        ],
        distractionEffects: [
            .laser: DistractionConfig(effectiveness: 0.8, duration: 8.0),
            .treats: DistractionConfig(effectiveness: 0.9, duration: 12.0),
            .catnip: DistractionConfig(effectiveness: 0.95, duration: 15.0),
            .cardboardBox: DistractionConfig(effectiveness: 0.7, duration: 10.0),
            .tape: DistractionConfig(effectiveness: 0.6, duration: 6.0)
        ],
        gameDuration: 180.0, // 3 minutes
        maxScore: 1000
    )
}

struct TaskConfig {
    let points: Int
    let timeRequired: TimeInterval
}

struct DistractionConfig {
    let effectiveness: Float
    let duration: TimeInterval
}

// MARK: - Game State
class GameState: ObservableObject {
    @Published var score: Int = 0
    @Published var timeRemaining: TimeInterval = 180.0
    @Published var isGameActive: Bool = false
    @Published var isGameOver: Bool = false
    @Published var isPaused: Bool = false
    @Published var currentLevel: Int = 1
    @Published var tasksCompleted: Int = 0
    @Published var phoneCallsAnswered: Int = 0
    
    var availableDistractions: [DistractionType] = DistractionType.allCases
    var remainingTasks: [TaskType] = TaskType.allCases
    
    func reset() {
        score = 0
        timeRemaining = 180.0
        isGameActive = false
        isGameOver = false
        isPaused = false
        currentLevel = 1
        tasksCompleted = 0
        phoneCallsAnswered = 0
        remainingTasks = TaskType.allCases
    }
}

// MARK: - Cutscene Data
struct CutsceneData {
    let id: Int
    let title: String
    let dialogue: String
    let catExpression: String
    let backgroundImage: String
    let audioFile: String?
    
    static let cutscenes: [CutsceneData] = [
        CutsceneData(
            id: 1,
            title: "Professional Call",
            dialogue: "Hello? Yes, I understand the quarterly reports are due. I'll have them on your desk by Monday.",
            catExpression: "professional",
            backgroundImage: "cutscene_office",
            audioFile: "cat_professional"
        ),
        CutsceneData(
            id: 2,
            title: "Family Drama",
            dialogue: "Mom, I told you, I'm fine! No, I'm not eating enough vegetables. Yes, I'm getting enough sleep!",
            catExpression: "frustrated",
            backgroundImage: "cutscene_kitchen",
            audioFile: "cat_family"
        ),
        CutsceneData(
            id: 3,
            title: "Mysterious Caller",
            dialogue: "The package has been delivered. The eagle has landed. The mission is complete. Over and out.",
            catExpression: "serious",
            backgroundImage: "cutscene_dark",
            audioFile: "cat_spy"
        ),
        CutsceneData(
            id: 4,
            title: "Wrong Number",
            dialogue: "I'm sorry, you have the wrong number. No, I'm not the pizza place. I'm a cat. Meow?",
            catExpression: "confused",
            backgroundImage: "cutscene_living_room",
            audioFile: "cat_wrong_number"
        ),
        CutsceneData(
            id: 5,
            title: "Cat Support Hotline",
            dialogue: "Thank you for calling Cat Support. My name is Whiskers. How may I help you with your feline emergency today?",
            catExpression: "helpful",
            backgroundImage: "cutscene_office",
            audioFile: "cat_support"
        ),
        CutsceneData(
            id: 6,
            title: "Time Travel Agency",
            dialogue: "Welcome to the Time Travel Agency. We're experiencing high call volumes due to the recent temporal anomaly. Please hold.",
            catExpression: "bored",
            backgroundImage: "cutscene_futuristic",
            audioFile: "cat_time_travel"
        )
    ]
}

// MARK: - Game Results
struct GameResult {
    let score: Int
    let tasksCompleted: Int
    let phoneCallsAnswered: Int
    let timeRemaining: TimeInterval
    let success: Bool
    let cutscenesViewed: [Int]
    
    var isHighScore: Bool {
        // This would be compared against stored high scores
        return score > 500
    }
}

// MARK: - Grid Position
struct GridPosition: Equatable, Hashable {
    let x: Int
    let y: Int
    
    init(x: Int, y: Int) {
        self.x = max(0, min(15, x)) // Clamp to grid bounds
        self.y = max(0, min(11, y))
    }
    
    func distance(to other: GridPosition) -> Int {
        return abs(x - other.x) + abs(y - other.y)
    }
    
    func neighbors() -> [GridPosition] {
        return [
            GridPosition(x: x + 1, y: y),
            GridPosition(x: x - 1, y: y),
            GridPosition(x: x, y: y + 1),
            GridPosition(x: x, y: y - 1)
        ].filter { $0.x >= 0 && $0.x < 16 && $0.y >= 0 && $0.y < 12 }
    }
} 