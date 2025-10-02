import Foundation
import SpriteKit
import AVFoundation
import Combine

// MARK: - Game Manager Delegate
protocol CatCallCrisisGameManagerDelegate {
    func gameDidComplete(result: GameResult)
    func gameDidRequestExit()
    func gameDidRequestCutscene(cutscene: CutsceneData)
    func gameDidResumeFromCutscene()
}

// MARK: - Main Game Manager
class CatCallCrisisGameManager: ObservableObject {
    // MARK: - Published Properties
    @Published var gameState: GameState
    @Published var currentCutscene: CutsceneData?
    @Published var isCutsceneActive: Bool = false
    
    // MARK: - Private Properties
    private let config: GameConfig
    var delegate: CatCallCrisisGameManagerDelegate?
    private var gameTimer: Timer?
    private var phoneTimer: Timer?
    private var cutscenesViewed: Set<Int> = []
    private var audioEngine: AVAudioEngine?
    private var audioPlayer: AVAudioPlayerNode?
    
    // MARK: - Game Entities
    private var playerPosition: GridPosition = GridPosition(x: 2, y: 2)
    private var catPosition: GridPosition = GridPosition(x: 8, y: 6)
    private var phonePosition: GridPosition = GridPosition(x: 14, y: 10)
    private var taskPositions: [TaskType: GridPosition] = [:]
    private var activeDistractions: [GridPosition: DistractionType] = [:]
    
    // MARK: - Cat AI
    private var catState: CatState = .idle
    private var catPath: [GridPosition] = []
    private var distractionEndTime: TimeInterval = 0
    
    // MARK: - Initialization
    init(config: GameConfig = .default, delegate: CatCallCrisisGameManagerDelegate? = nil) {
        self.config = config
        self.delegate = delegate
        self.gameState = GameState()
        setupTaskPositions()
        setupAudio()
    }
    
    // MARK: - Game Lifecycle
    func startGame() {
        gameState.reset()
        gameState.isGameActive = true
        gameState.isGameOver = false
        
        // Reset positions
        playerPosition = GridPosition(x: 2, y: 2)
        catPosition = GridPosition(x: 8, y: 6)
        catState = .idle
        catPath = []
        activeDistractions.removeAll()
        cutscenesViewed.removeAll()
        
        // Start timers
        startGameTimer()
        scheduleNextPhoneCall()
        
        print("Cat Call Crisis: Game started")
    }
    
    func pauseGame() {
        gameState.isPaused = true
        gameTimer?.invalidate()
        phoneTimer?.invalidate()
    }
    
    func resumeGame() {
        gameState.isPaused = false
        startGameTimer()
        scheduleNextPhoneCall()
    }
    
    func endGame() {
        gameState.isGameActive = false
        gameState.isGameOver = true
        gameTimer?.invalidate()
        phoneTimer?.invalidate()
        
        let result = GameResult(
            score: gameState.score,
            tasksCompleted: gameState.tasksCompleted,
            phoneCallsAnswered: gameState.phoneCallsAnswered,
            timeRemaining: gameState.timeRemaining,
            success: gameState.score >= config.maxScore / 2,
            cutscenesViewed: Array(cutscenesViewed)
        )
        
        delegate?.gameDidComplete(result: result)
        print("Cat Call Crisis: Game ended with score \(gameState.score)")
    }
    
    func exitGame() {
        endGame()
        delegate?.gameDidRequestExit()
    }
    
    // MARK: - Player Actions
    func movePlayer(to position: GridPosition) {
        guard gameState.isGameActive && !gameState.isPaused else { return }
        
        // Check if move is valid (adjacent position)
        if playerPosition.neighbors().contains(position) {
            playerPosition = position
            
            // Check for task completion
            if let taskType = taskAtPosition(position) {
                completeTask(taskType)
            }
            
            // Check for distraction pickup
            if let distractionType = activeDistractions[position] {
                pickupDistraction(distractionType, at: position)
            }
        }
    }
    
    func deployDistraction(_ type: DistractionType, at position: GridPosition) {
        guard gameState.isGameActive && !gameState.isPaused else { return }
        guard gameState.availableDistractions.contains(type) else { return }
        
        // Remove from available distractions
        gameState.availableDistractions.removeAll { $0 == type }
        
        // Add to active distractions
        activeDistractions[position] = type
        
        // Check if cat is nearby and distract it
        if catPosition.distance(to: position) <= 2 {
            distractCat(with: type)
        }
        
        print("Cat Call Crisis: Deployed \(type.displayName) at \(position)")
    }
    
    // MARK: - Task System
    private func completeTask(_ taskType: TaskType) {
        guard gameState.remainingTasks.contains(taskType) else { return }
        
        let taskConfig = config.taskDefinitions[taskType]!
        gameState.score += taskConfig.points
        gameState.tasksCompleted += 1
        gameState.remainingTasks.removeAll { $0 == taskType }
        
        // Add distraction back to available pool
        let newDistraction = DistractionType.allCases.randomElement()!
        if !gameState.availableDistractions.contains(newDistraction) {
            gameState.availableDistractions.append(newDistraction)
        }
        
        print("Cat Call Crisis: Completed task \(taskType.displayName) for \(taskConfig.points) points")
        
        // Check win condition
        if gameState.remainingTasks.isEmpty {
            endGame()
        }
    }
    
    private func taskAtPosition(_ position: GridPosition) -> TaskType? {
        return taskPositions.first { $0.value == position }?.key
    }
    
    // MARK: - Cat AI
    private func updateCatAI() {
        guard gameState.isGameActive && !gameState.isPaused else { return }
        
        switch catState {
        case .idle:
            performIdleBehavior()
        case .phoneAlert:
            moveCatToPhone()
        case .distracted(let distractionType):
            handleDistractedState(distractionType)
        case .movingToPhone:
            moveCatToPhone()
        case .answeringPhone:
            // Cat is answering phone, trigger cutscene
            triggerPhoneCutscene()
        case .taskComplete:
            // Brief celebration, then return to idle
            catState = .idle
        }
    }
    
    private func performIdleBehavior() {
        // Random movement or staying still
        if Int.random(in: 0...10) < 3 {
            let neighbors = catPosition.neighbors()
            if let newPosition = neighbors.randomElement() {
                catPosition = newPosition
            }
        }
    }
    
    private func moveCatToPhone() {
        if catPosition == phonePosition {
            catState = .answeringPhone
            return
        }
        
        // Simple pathfinding to phone
        let path = findPath(from: catPosition, to: phonePosition)
        if let nextPosition = path.first {
            catPosition = nextPosition
        }
    }
    
    private func distractCat(with distractionType: DistractionType) {
        let effectiveness = distractionType.effectiveness
        let randomValue = Float.random(in: 0...1)
        
        if randomValue < effectiveness {
            catState = .distracted(distractionType)
            distractionEndTime = Date().timeIntervalSinceReferenceDate + distractionType.duration
            print("Cat Call Crisis: Cat distracted by \(distractionType.displayName)")
        }
    }
    
    private func handleDistractedState(_ distractionType: DistractionType) {
        let currentTime = Date().timeIntervalSinceReferenceDate
        if currentTime >= distractionEndTime {
            catState = .idle
            print("Cat Call Crisis: Cat no longer distracted")
        }
    }
    
    // MARK: - Phone System
    private func scheduleNextPhoneCall() {
        let interval = Double.random(in: config.phoneRingInterval)
        phoneTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            self?.phoneRings()
        }
    }
    
    private func phoneRings() {
        guard gameState.isGameActive && !gameState.isPaused else { return }
        
        // Only alert cat if not already distracted
        if case .distracted = catState { return }
        
        catState = .phoneAlert
        print("Cat Call Crisis: Phone is ringing!")
        
        // Schedule next call
        scheduleNextPhoneCall()
    }
    
    private func triggerPhoneCutscene() {
        guard !isCutsceneActive else { return }
        
        // Select a cutscene (random or sequential)
        let availableCutscenes = CutsceneData.cutscenes.filter { !cutscenesViewed.contains($0.id) }
        let cutscene = availableCutscenes.randomElement() ?? CutsceneData.cutscenes.randomElement()!
        
        cutscenesViewed.insert(cutscene.id)
        gameState.phoneCallsAnswered += 1
        
        isCutsceneActive = true
        currentCutscene = cutscene
        delegate?.gameDidRequestCutscene(cutscene: cutscene)
        
        print("Cat Call Crisis: Triggering cutscene \(cutscene.title)")
    }
    
    func resumeFromCutscene() {
        isCutsceneActive = false
        currentCutscene = nil
        catState = .idle
        delegate?.gameDidResumeFromCutscene()
    }
    
    // MARK: - Timer Management
    private func startGameTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateGame()
        }
    }
    
    private func updateGame() {
        guard gameState.isGameActive && !gameState.isPaused else { return }
        
        // Update time
        gameState.timeRemaining -= 1.0
        
        // Update cat AI
        updateCatAI()
        
        // Check game over condition
        if gameState.timeRemaining <= 0 {
            endGame()
        }
    }
    
    // MARK: - Utility Methods
    private func findPath(from start: GridPosition, to end: GridPosition) -> [GridPosition] {
        // Simple A* pathfinding implementation
        var openSet: Set<GridPosition> = [start]
        var cameFrom: [GridPosition: GridPosition] = [:]
        var gScore: [GridPosition: Int] = [start: 0]
        var fScore: [GridPosition: Int] = [start: start.distance(to: end)]
        
        while !openSet.isEmpty {
            let current = openSet.min { fScore[$0, default: Int.max] < fScore[$1, default: Int.max] }!
            
            if current == end {
                return reconstructPath(cameFrom: cameFrom, current: current)
            }
            
            openSet.remove(current)
            
            for neighbor in current.neighbors() {
                let tentativeGScore = gScore[current, default: Int.max] + 1
                
                if tentativeGScore < gScore[neighbor, default: Int.max] {
                    cameFrom[neighbor] = current
                    gScore[neighbor] = tentativeGScore
                    fScore[neighbor] = tentativeGScore + neighbor.distance(to: end)
                    
                    if !openSet.contains(neighbor) {
                        openSet.insert(neighbor)
                    }
                }
            }
        }
        
        return []
    }
    
    private func reconstructPath(cameFrom: [GridPosition: GridPosition], current: GridPosition) -> [GridPosition] {
        var path: [GridPosition] = [current]
        var currentPos = current
        
        while let previous = cameFrom[currentPos] {
            path.insert(previous, at: 0)
            currentPos = previous
        }
        
        return Array(path.dropFirst()) // Remove start position
    }
    
    private func pickupDistraction(_ type: DistractionType, at position: GridPosition) {
        activeDistractions.removeValue(forKey: position)
        gameState.availableDistractions.append(type)
    }
    
    // MARK: - Setup Methods
    private func setupTaskPositions() {
        taskPositions = [
            .toaster: GridPosition(x: 3, y: 3),
            .laundry: GridPosition(x: 12, y: 3),
            .plants: GridPosition(x: 3, y: 8),
            .mail: GridPosition(x: 12, y: 8),
            .fishFood: GridPosition(x: 7, y: 10)
        ]
    }
    
    private func setupAudio() {
        audioEngine = AVAudioEngine()
        audioPlayer = AVAudioPlayerNode()
        
        if let audioEngine = audioEngine, let audioPlayer = audioPlayer {
            audioEngine.attach(audioPlayer)
            audioEngine.connect(audioPlayer, to: audioEngine.mainMixerNode, format: nil)
            
            do {
                try audioEngine.start()
            } catch {
                print("Cat Call Crisis: Failed to start audio engine: \(error)")
            }
        }
    }
    
    // MARK: - Public Accessors
    func getPlayerPosition() -> GridPosition {
        return playerPosition
    }
    
    func getCatPosition() -> GridPosition {
        return catPosition
    }
    
    func getPhonePosition() -> GridPosition {
        return phonePosition
    }
    
    func getTaskPositions() -> [TaskType: GridPosition] {
        return taskPositions
    }
    
    func getActiveDistractions() -> [GridPosition: DistractionType] {
        return activeDistractions
    }
    
    func getCatState() -> CatState {
        return catState
    }
} 