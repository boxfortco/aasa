import SwiftUI
import SpriteKit

// MARK: - Main Game View
struct CatCallCrisisGameView: View {
    @StateObject private var gameManager = CatCallCrisisGameManager()
    @State private var gameScene: CatCallCrisisGameScene?
    @State private var showingCutscene = false
    @State private var showingPauseMenu = false
    @State private var showingGameOver = false
    @State private var gameResult: GameResult?
    @State private var selectedDistraction: DistractionType?
    @State private var isDeployingDistraction = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Game Scene
                if let gameScene = gameScene {
                    SpriteView(scene: gameScene)
                        .ignoresSafeArea()
                        .onAppear {
                            gameScene.startGame()
                        }
                }
                
                // Game UI Overlay
                gameUIOverlay
                
                // Distraction Selection UI
                if isDeployingDistraction {
                    distractionSelectionUI
                }
                
                // Cutscene Overlay
                if showingCutscene, let cutscene = gameManager.currentCutscene {
                    CatCallCrisisCutsceneContainerView(
                        cutscene: cutscene,
                        onContinue: {
                            showingCutscene = false
                            gameManager.resumeFromCutscene()
                        },
                        onSkip: {
                            showingCutscene = false
                            gameManager.resumeFromCutscene()
                        }
                    )
                    .transition(.opacity)
                    .zIndex(1000)
                }
                
                // Pause Menu
                if showingPauseMenu {
                    pauseMenuOverlay
                }
                
                // Game Over Screen
                if showingGameOver, let result = gameResult {
                    gameOverOverlay(result: result)
                }
            }
        }
        .onAppear {
            setupGame()
        }
        .onDisappear {
            cleanupGame()
        }
    }
    
    // MARK: - Game UI Overlay
    private var gameUIOverlay: some View {
        VStack {
            // Top HUD
            HStack {
                // Score and Time
                VStack(alignment: .leading, spacing: 5) {
                    Text("Score: \(gameManager.gameState.score)")
                        .font(.custom("LondrinaSolid-Regular", size: 18))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 2, x: 1, y: 1)
                    
                    Text(timeString)
                        .font(.custom("LondrinaSolid-Regular", size: 16))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 2, x: 1, y: 1)
                }
                
                Spacer()
                
                // Pause Button
                Button(action: {
                    showingPauseMenu = true
                    gameManager.pauseGame()
                }) {
                    Image(systemName: "pause.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 2, x: 1, y: 1)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 50)
            
            Spacer()
            
            // Bottom Controls
            HStack {
                // Task List
                VStack(alignment: .leading, spacing: 5) {
                    Text("Tasks Remaining:")
                        .font(.custom("LondrinaSolid-Regular", size: 14))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 1, x: 0.5, y: 0.5)
                    
                    ForEach(gameManager.gameState.remainingTasks, id: \.self) { task in
                        Text("• \(task.displayName)")
                            .font(.custom("LondrinaSolid-Light", size: 12))
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 1, x: 0.5, y: 0.5)
                    }
                }
                
                Spacer()
                
                // Distraction Button
                Button(action: {
                    withAnimation(.spring()) {
                        isDeployingDistraction.toggle()
                    }
                }) {
                    VStack(spacing: 5) {
                        Image(systemName: "hand.raised.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                        
                        Text("Distract")
                            .font(.custom("LondrinaSolid-Regular", size: 12))
                            .foregroundColor(.white)
                    }
                    .padding(10)
                    .background(Color.orange.opacity(0.8))
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.3), radius: 3, x: 1, y: 1)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }
    
    // MARK: - Distraction Selection UI
    private var distractionSelectionUI: some View {
        VStack {
            Spacer()
            
            // Distraction Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 15) {
                ForEach(gameManager.gameState.availableDistractions, id: \.self) { distraction in
                    Button(action: {
                        selectedDistraction = distraction
                        gameScene?.setSelectedDistraction(distraction)
                        withAnimation(.spring()) {
                            isDeployingDistraction = false
                        }
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: distractionIcon(for: distraction))
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                            
                            Text(distraction.displayName)
                                .font(.custom("LondrinaSolid-Regular", size: 12))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: 80, height: 80)
                        .background(distractionColor(for: distraction))
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.3), radius: 3, x: 1, y: 1)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
            
            // Cancel Button
            Button(action: {
                withAnimation(.spring()) {
                    isDeployingDistraction = false
                    selectedDistraction = nil
                    gameScene?.setSelectedDistraction(nil)
                }
            }) {
                Text("Cancel")
                    .font(.custom("LondrinaSolid-Regular", size: 16))
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
                    .background(Color.red.opacity(0.8))
                    .cornerRadius(20)
            }
            .padding(.bottom, 30)
        }
        .background(Color.black.opacity(0.7))
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    // MARK: - Pause Menu Overlay
    private var pauseMenuOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("Game Paused")
                    .font(.custom("LondrinaSolid-Regular", size: 32))
                    .foregroundColor(.white)
                
                VStack(spacing: 20) {
                    Button(action: {
                        showingPauseMenu = false
                        gameManager.resumeGame()
                    }) {
                        Text("Resume")
                            .font(.custom("LondrinaSolid-Regular", size: 20))
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.green)
                            .cornerRadius(25)
                    }
                    
                    Button(action: {
                        showingPauseMenu = false
                        gameManager.startGame()
                    }) {
                        Text("Restart")
                            .font(.custom("LondrinaSolid-Regular", size: 20))
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.orange)
                            .cornerRadius(25)
                    }
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Exit Game")
                            .font(.custom("LondrinaSolid-Regular", size: 20))
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.red)
                            .cornerRadius(25)
                    }
                }
            }
        }
        .transition(.opacity)
        .zIndex(1000)
    }
    
    // MARK: - Game Over Overlay
    private func gameOverOverlay(result: GameResult) -> some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text(result.success ? "Mission Complete!" : "Time's Up!")
                    .font(.custom("LondrinaSolid-Regular", size: 32))
                    .foregroundColor(.white)
                
                VStack(spacing: 15) {
                    Text("Final Score: \(result.score)")
                        .font(.custom("LondrinaSolid-Regular", size: 24))
                        .foregroundColor(.white)
                    
                    Text("Tasks Completed: \(result.tasksCompleted)")
                        .font(.custom("LondrinaSolid-Regular", size: 18))
                        .foregroundColor(.white)
                    
                    Text("Phone Calls: \(result.phoneCallsAnswered)")
                        .font(.custom("LondrinaSolid-Regular", size: 18))
                        .foregroundColor(.white)
                    
                    if result.isHighScore {
                        Text("New High Score!")
                            .font(.custom("LondrinaSolid-Regular", size: 20))
                            .foregroundColor(.yellow)
                    }
                }
                
                VStack(spacing: 20) {
                    Button(action: {
                        showingGameOver = false
                        gameResult = nil
                        gameManager.startGame()
                    }) {
                        Text("Play Again")
                            .font(.custom("LondrinaSolid-Regular", size: 20))
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.green)
                            .cornerRadius(25)
                    }
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Back to Menu")
                            .font(.custom("LondrinaSolid-Regular", size: 20))
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.blue)
                            .cornerRadius(25)
                    }
                }
            }
        }
        .transition(.opacity)
        .zIndex(1000)
    }
    
    // MARK: - Helper Methods
    private var timeString: String {
        let minutes = Int(gameManager.gameState.timeRemaining) / 60
        let seconds = Int(gameManager.gameState.timeRemaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func setupGame() {
        // Create game scene
        let sceneSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        let scene = CatCallCrisisGameScene(
            size: sceneSize,
            gameManager: gameManager,
            delegate: self
        )
        gameScene = scene
        
        // Set up game manager delegate
        gameManager.delegate = self
        
        // Start the game
        gameManager.startGame()
    }
    
    private func cleanupGame() {
        gameManager.exitGame()
    }
    
    private func distractionIcon(for distraction: DistractionType) -> String {
        switch distraction {
        case .laser: return "dot.radiowaves.left.and.right"
        case .treats: return "star.fill"
        case .catnip: return "leaf.fill"
        case .cardboardBox: return "cube.fill"
        case .tape: return "scissors"
        }
    }
    
    private func distractionColor(for distraction: DistractionType) -> Color {
        switch distraction {
        case .laser: return .red
        case .treats: return .orange
        case .catnip: return .purple
        case .cardboardBox: return .brown
        case .tape: return .gray
        }
    }
}

// MARK: - Game Manager Delegate
extension CatCallCrisisGameView: CatCallCrisisGameManagerDelegate {
    func gameDidComplete(result: GameResult) {
        gameResult = result
        withAnimation {
            showingGameOver = true
        }
    }
    
    func gameDidRequestExit() {
        dismiss()
    }
    
    func gameDidRequestCutscene(cutscene: CutsceneData) {
        withAnimation {
            showingCutscene = true
        }
    }
    
    func gameDidResumeFromCutscene() {
        // Game resumed from cutscene
    }
}

// MARK: - Game Scene Delegate
extension CatCallCrisisGameView: CatCallCrisisGameSceneDelegate {
    func gameSceneDidRequestCutscene() {
        // Handled by game manager
    }
    
    func gameSceneDidRequestPause() {
        showingPauseMenu = true
        gameManager.pauseGame()
    }
    
    func gameSceneDidRequestExit() {
        dismiss()
    }
}

// MARK: - Preview
struct CatCallCrisisGameView_Previews: PreviewProvider {
    static var previews: some View {
        CatCallCrisisGameView()
    }
} 