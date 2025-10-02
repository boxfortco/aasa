import SpriteKit
import SwiftUI

// MARK: - Game Scene Delegate
protocol CatCallCrisisGameSceneDelegate {
    func gameSceneDidRequestCutscene()
    func gameSceneDidRequestPause()
    func gameSceneDidRequestExit()
}

// MARK: - Main Game Scene
class CatCallCrisisGameScene: SKScene {
    // MARK: - Properties
    private var gameDelegate: CatCallCrisisGameSceneDelegate?
    private var gameManager: CatCallCrisisGameManager
    
    // MARK: - Game Objects
    private var playerSprite: SKSpriteNode?
    private var catSprite: SKSpriteNode?
    private var phoneSprite: SKSpriteNode?
    private var taskSprites: [TaskType: SKSpriteNode] = [:]
    private var distractionSprites: [GridPosition: SKSpriteNode] = [:]
    private var wallSprites: [SKSpriteNode] = []
    
    // MARK: - UI Elements
    private var scoreLabel: SKLabelNode?
    private var timeLabel: SKLabelNode?
    private var taskListLabel: SKLabelNode?
    private var distractionInventoryLabel: SKLabelNode?
    
    // MARK: - Game State
    private var selectedDistraction: DistractionType?
    private var isDeployingDistraction = false
    
    // MARK: - Constants
    private let tileSize: CGFloat = 32.0
    private let gridWidth = 16
    private let gridHeight = 12
    
    // MARK: - Initialization
    init(size: CGSize, gameManager: CatCallCrisisGameManager, delegate: CatCallCrisisGameSceneDelegate? = nil) {
        self.gameManager = gameManager
        self.gameDelegate = delegate
        super.init(size: size)
        
        setupScene()
        setupGameObjects()
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Scene Setup
    private func setupScene() {
        backgroundColor = SKColor(red: 0.9, green: 0.9, blue: 0.8, alpha: 1.0) // Light beige background
        
        // Set up physics world
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        // Add camera for potential zoom/pan features
        let camera = SKCameraNode()
        addChild(camera)
        scene?.camera = camera
    }
    
    private func setupGameObjects() {
        createHouseLayout()
        createPlayer()
        createCat()
        createPhone()
        createTasks()
        createWalls()
    }
    
    private func setupUI() {
        createScoreLabel()
        createTimeLabel()
        createTaskListLabel()
        createDistractionInventoryLabel()
    }
    
    // MARK: - House Layout
    private func createHouseLayout() {
        // Create room divisions with simple colored rectangles
        let rooms = [
            (CGRect(x: 0, y: 0, width: 8, height: 6), SKColor(red: 0.8, green: 0.7, blue: 0.6, alpha: 1.0)), // Kitchen
            (CGRect(x: 8, y: 0, width: 8, height: 6), SKColor(red: 0.7, green: 0.8, blue: 0.7, alpha: 1.0)), // Living Room
            (CGRect(x: 0, y: 6, width: 8, height: 6), SKColor(red: 0.6, green: 0.7, blue: 0.8, alpha: 1.0)), // Bedroom
            (CGRect(x: 8, y: 6, width: 8, height: 6), SKColor(red: 0.8, green: 0.8, blue: 0.7, alpha: 1.0))  // Office
        ]
        
        for (rect, color) in rooms {
            let roomNode = SKSpriteNode(color: color, size: CGSize(width: rect.width * tileSize, height: rect.height * tileSize))
            roomNode.position = CGPoint(
                x: (rect.midX - CGFloat(gridWidth) / 2) * tileSize,
                y: (rect.midY - CGFloat(gridHeight) / 2) * tileSize
            )
            roomNode.zPosition = -10
            addChild(roomNode)
        }
    }
    
    // MARK: - Game Objects Creation
    private func createPlayer() {
        let playerNode = SKSpriteNode(color: SKColor.blue, size: CGSize(width: tileSize * 0.8, height: tileSize * 0.8))
        playerNode.name = "player"
        playerNode.zPosition = 10
        
        // Add simple animation
        let pulseAction = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        playerNode.run(SKAction.repeatForever(pulseAction))
        
        playerSprite = playerNode
        updatePlayerPosition()
        addChild(playerNode)
    }
    
    private func createCat() {
        let catNode = SKSpriteNode(color: SKColor.orange, size: CGSize(width: tileSize * 0.8, height: tileSize * 0.8))
        catNode.name = "cat"
        catNode.zPosition = 10
        
        // Add cat-like animation
        let wiggleAction = SKAction.sequence([
            SKAction.rotate(byAngle: 0.1, duration: 0.2),
            SKAction.rotate(byAngle: -0.2, duration: 0.4),
            SKAction.rotate(byAngle: 0.1, duration: 0.2)
        ])
        catNode.run(SKAction.repeatForever(wiggleAction))
        
        catSprite = catNode
        updateCatPosition()
        addChild(catNode)
    }
    
    private func createPhone() {
        let phoneNode = SKSpriteNode(color: SKColor.green, size: CGSize(width: tileSize * 0.6, height: tileSize * 0.6))
        phoneNode.name = "phone"
        phoneNode.zPosition = 5
        
        // Add ringing animation
        let ringAction = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3)
        ])
        phoneNode.run(SKAction.repeatForever(ringAction))
        
        phoneSprite = phoneNode
        updatePhonePosition()
        addChild(phoneNode)
    }
    
    private func createTasks() {
        let taskPositions = gameManager.getTaskPositions()
        
        for (taskType, position) in taskPositions {
            let taskNode = SKSpriteNode(color: taskColor(for: taskType), size: CGSize(width: tileSize * 0.7, height: tileSize * 0.7))
            taskNode.name = "task_\(taskType.spriteName)"
            taskNode.zPosition = 5
            
            // Add task label
            let label = SKLabelNode(text: taskType.displayName)
            label.fontSize = 10
            label.fontColor = SKColor.black
            label.position = CGPoint(x: 0, y: -tileSize * 0.6)
            taskNode.addChild(label)
            
            taskSprites[taskType] = taskNode
            updateTaskPosition(taskType: taskType, position: position)
            addChild(taskNode)
        }
    }
    
    private func createWalls() {
        // Create simple wall boundaries
        let wallThickness: CGFloat = 4.0
        
        // Horizontal walls
        for x in 0..<gridWidth {
            let topWall = SKSpriteNode(color: SKColor.darkGray, size: CGSize(width: tileSize, height: wallThickness))
            topWall.position = gridToScreen(x: x, y: gridHeight - 1)
            topWall.zPosition = 1
            addChild(topWall)
            
            let bottomWall = SKSpriteNode(color: SKColor.darkGray, size: CGSize(width: tileSize, height: wallThickness))
            bottomWall.position = gridToScreen(x: x, y: 0)
            bottomWall.zPosition = 1
            addChild(bottomWall)
        }
        
        // Vertical walls
        for y in 0..<gridHeight {
            let leftWall = SKSpriteNode(color: SKColor.darkGray, size: CGSize(width: wallThickness, height: tileSize))
            leftWall.position = gridToScreen(x: 0, y: y)
            leftWall.zPosition = 1
            addChild(leftWall)
            
            let rightWall = SKSpriteNode(color: SKColor.darkGray, size: CGSize(width: wallThickness, height: tileSize))
            rightWall.position = gridToScreen(x: gridWidth - 1, y: y)
            rightWall.zPosition = 1
            addChild(rightWall)
        }
    }
    
    // MARK: - UI Creation
    private func createScoreLabel() {
        let label = SKLabelNode(fontNamed: "Arial-Bold")
        label.text = "Score: 0"
        label.fontSize = 16
        label.fontColor = SKColor.black
        label.position = CGPoint(x: -size.width/2 + 80, y: size.height/2 - 30)
        label.zPosition = 100
        scoreLabel = label
        addChild(label)
    }
    
    private func createTimeLabel() {
        let label = SKLabelNode(fontNamed: "Arial-Bold")
        label.text = "Time: 3:00"
        label.fontSize = 16
        label.fontColor = SKColor.black
        label.position = CGPoint(x: -size.width/2 + 80, y: size.height/2 - 50)
        label.zPosition = 100
        timeLabel = label
        addChild(label)
    }
    
    private func createTaskListLabel() {
        let label = SKLabelNode(fontNamed: "Arial")
        label.text = "Tasks: 5 remaining"
        label.fontSize = 12
        label.fontColor = SKColor.black
        label.position = CGPoint(x: size.width/2 - 100, y: size.height/2 - 30)
        label.zPosition = 100
        taskListLabel = label
        addChild(label)
    }
    
    private func createDistractionInventoryLabel() {
        let label = SKLabelNode(fontNamed: "Arial")
        label.text = "Distractions: 5 available"
        label.fontSize = 12
        label.fontColor = SKColor.black
        label.position = CGPoint(x: size.width/2 - 100, y: size.height/2 - 50)
        label.zPosition = 100
        distractionInventoryLabel = label
        addChild(label)
    }
    
    // MARK: - Position Updates
    private func updatePlayerPosition() {
        let position = gameManager.getPlayerPosition()
        playerSprite?.position = gridToScreen(x: position.x, y: position.y)
    }
    
    private func updateCatPosition() {
        let position = gameManager.getCatPosition()
        catSprite?.position = gridToScreen(x: position.x, y: position.y)
        
        // Update cat appearance based on state
        let catState = gameManager.getCatState()
        switch catState {
        case .phoneAlert, .movingToPhone:
            catSprite?.color = SKColor.red
        case .distracted:
            catSprite?.color = SKColor.purple
        default:
            catSprite?.color = SKColor.orange
        }
    }
    
    private func updatePhonePosition() {
        let position = gameManager.getPhonePosition()
        phoneSprite?.position = gridToScreen(x: position.x, y: position.y)
    }
    
    private func updateTaskPosition(taskType: TaskType, position: GridPosition) {
        taskSprites[taskType]?.position = gridToScreen(x: position.x, y: position.y)
    }
    
    private func updateDistractionPosition(distractionType: DistractionType, position: GridPosition) {
        if let existingSprite = distractionSprites[position] {
            existingSprite.removeFromParent()
        }
        
        let distractionNode = SKSpriteNode(color: distractionColor(for: distractionType), size: CGSize(width: tileSize * 0.6, height: tileSize * 0.6))
        distractionNode.position = gridToScreen(x: position.x, y: position.y)
        distractionNode.zPosition = 8
        distractionNode.name = "distraction_\(distractionType.spriteName)"
        
        distractionSprites[position] = distractionNode
        addChild(distractionNode)
    }
    
    // MARK: - UI Updates
    func updateUI() {
        let gameState = gameManager.gameState
        
        // Update score
        scoreLabel?.text = "Score: \(gameState.score)"
        
        // Update time
        let minutes = Int(gameState.timeRemaining) / 60
        let seconds = Int(gameState.timeRemaining) % 60
        timeLabel?.text = String(format: "Time: %d:%02d", minutes, seconds)
        
        // Update task list
        taskListLabel?.text = "Tasks: \(gameState.remainingTasks.count) remaining"
        
        // Update distraction inventory
        distractionInventoryLabel?.text = "Distractions: \(gameState.availableDistractions.count) available"
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Check if touch is in UI area
        if location.y > size.height/2 - 60 {
            handleUITouch(at: location)
            return
        }
        
        // Convert screen position to grid position
        let gridPosition = screenToGrid(point: location)
        
        if isDeployingDistraction {
            deployDistraction(at: gridPosition)
        } else {
            movePlayer(to: gridPosition)
        }
    }
    
    private func handleUITouch(at location: CGPoint) {
        // Handle UI button touches
        if location.x < -size.width/2 + 100 && location.y > size.height/2 - 60 {
            // Pause button area
            gameDelegate?.gameSceneDidRequestPause()
        }
    }
    
    private func movePlayer(to gridPosition: GridPosition) {
        gameManager.movePlayer(to: gridPosition)
        updatePlayerPosition()
        updateTasks()
        updateDistractions()
    }
    
    private func deployDistraction(at gridPosition: GridPosition) {
        guard let distractionType = selectedDistraction else { return }
        
        gameManager.deployDistraction(distractionType, at: gridPosition)
        updateDistractions()
        
        // Reset deployment mode
        isDeployingDistraction = false
        selectedDistraction = nil
    }
    
    // MARK: - Game State Updates
    func updateGameState() {
        updateCatPosition()
        updateUI()
        updateTasks()
        updateDistractions()
    }
    
    private func updateTasks() {
        let remainingTasks = gameManager.gameState.remainingTasks
        
        for (taskType, sprite) in taskSprites {
            if remainingTasks.contains(taskType) {
                sprite.alpha = 1.0
            } else {
                sprite.alpha = 0.3
            }
        }
    }
    
    private func updateDistractions() {
        // Remove old distraction sprites
        for sprite in distractionSprites.values {
            sprite.removeFromParent()
        }
        distractionSprites.removeAll()
        
        // Add new distraction sprites
        let activeDistractions = gameManager.getActiveDistractions()
        for (position, distractionType) in activeDistractions {
            updateDistractionPosition(distractionType: distractionType, position: position)
        }
    }
    
    // MARK: - Utility Methods
    private func gridToScreen(x: Int, y: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(x - gridWidth/2) * tileSize,
            y: CGFloat(y - gridHeight/2) * tileSize
        )
    }
    
    private func screenToGrid(point: CGPoint) -> GridPosition {
        let x = Int(round(point.x / tileSize)) + gridWidth/2
        let y = Int(round(point.y / tileSize)) + gridHeight/2
        return GridPosition(x: x, y: y)
    }
    
    private func taskColor(for taskType: TaskType) -> SKColor {
        switch taskType {
        case .toaster: return SKColor.red
        case .laundry: return SKColor.blue
        case .plants: return SKColor.green
        case .mail: return SKColor.yellow
        case .fishFood: return SKColor.cyan
        }
    }
    
    private func distractionColor(for distractionType: DistractionType) -> SKColor {
        switch distractionType {
        case .laser: return SKColor.red
        case .treats: return SKColor.orange
        case .catnip: return SKColor.purple
        case .cardboardBox: return SKColor.brown
        case .tape: return SKColor.gray
        }
    }
    
    // MARK: - Public Interface
    func setSelectedDistraction(_ distractionType: DistractionType?) {
        selectedDistraction = distractionType
        isDeployingDistraction = distractionType != nil
    }
    
    func startGame() {
        // Any additional setup needed when game starts
    }
    
    func pauseGame() {
        scene?.view?.isPaused = true
    }
    
    func resumeGame() {
        scene?.view?.isPaused = false
    }
} 