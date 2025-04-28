//
//  GameScene.swift
//  NoHitMania
//
//  Created by Christian Barajas on 4/15/25.
//

import SpriteKit
import Combine

class GameScene: SKScene {
    // Managers
    private var gridManager: GridManager!
    private var playerManager: PlayerManager!
    private var zapCellManager: ZapCellManager!
    private var timerManager: GameTimerManager!
    private var audioManager: AudioManager!
    
    // UI elements
    private var scoreTimerLabel: SKLabelNode!
    private var currentLevelLabel: SKLabelNode!
    
    // Touch handling
    private var startTouchPosition: CGPoint?
    
    // Game state
    private var playerAlive: Bool = true
    private var lastUpdateTime: TimeInterval = 0
    private var gameStartTime: TimeInterval = 0
    private var elapsedTime: TimeInterval = 0
    
    // Zap cell spawning
    private var nextZapSpawnTime: TimeInterval = 3.0 // Initial spawn after 3 seconds
    private var zapSpawnInterval: TimeInterval = 5.0 // Base interval between spawns
    
    // MARK: - Scene Lifecycle
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        // Initialize managers
        setupManagers()
        
        // Setup UI
        setupUI()
        
        // Record start time and start timer
        gameStartTime = CACurrentMediaTime()
        timerManager.startTimer()
    }
    
    // MARK: - Setup Methods
    
    private func setupManagers() {
        // Create grid manager and set up grid
        gridManager = GridManager(scene: self, gridSize: GameConstants.defaultGridSize)
        let (cellSize, gridOrigin) = gridManager.setupGrid()
        
        // Create player manager
        playerManager = PlayerManager(
            scene: self,
            gridSize: GameConstants.defaultGridSize,
            cellSize: cellSize,
            gridOrigin: gridOrigin
        )
        playerManager.onPlayerDeath = { [weak self] in
            self?.handlePlayerDeath()
        }
        
        // Create zap cell manager
        zapCellManager = ZapCellManager(scene: self)
        
        // Create timer manager
        timerManager = GameTimerManager()
        timerManager.onTimerUpdate = { [weak self] timeString in
            self?.scoreTimerLabel.text = timeString
        }
        timerManager.onLevelUpdate = { [weak self] level in
            self?.currentLevelLabel.text = "Level: \(level)"
            self?.updateSpawnRateForLevel(level)
        }
        
        // Create audio manager and setup music
        audioManager = AudioManager(scene: self)
        audioManager.setupBackgroundMusic()
    }
    
    private func setupUI() {
        // Timer label
        scoreTimerLabel = SKLabelNode(text: "00:00.00")
        scoreTimerLabel.fontColor = .white
        scoreTimerLabel.fontSize = 30
        scoreTimerLabel.position = CGPoint(x: size.width / 2, y: size.height - 100)
        scoreTimerLabel.fontName = "Helvetica-Bold"
        addChild(scoreTimerLabel)
        
        // Level label
        currentLevelLabel = SKLabelNode(text: "Level: 1")
        currentLevelLabel.fontColor = .white
        currentLevelLabel.fontName = "Helvetica-Bold"
        currentLevelLabel.fontSize = 25
        currentLevelLabel.position = CGPoint(x: size.width / 2, y: size.height - 135)
        addChild(currentLevelLabel)
    }
    
    // MARK: - Game Logic
    
    private func handlePlayerDeath() {
//        playerAlive = false
        timerManager.pauseTimer()
        audioManager.changeMusic(to: .pause)
        
        restartGame()

        // Add any additional death handling here
        // For example, showing game over screen
    }
    
    // Update zap cell spawn rate based on the current level
    private func updateSpawnRateForLevel(_ level: Int) {
        // Decrease spawn interval as level increases (faster spawning)
        // But ensure it doesn't go below a minimum threshold
        let minSpawnInterval: TimeInterval = 1.0 // Fastest spawn rate (1 per second)
        let decreaseFactor: TimeInterval = 0.5 // How much to decrease per level
        
        zapSpawnInterval = max(zapSpawnInterval - decreaseFactor, minSpawnInterval)
        
        // Also decrease warning time as levels increase
        let chargeTimeReduction = min(0.1 * Double(level - 1), 0.8) // Reduce charge time by up to 80%
        zapCellManager.adjustChargeTime(reductionFactor: chargeTimeReduction)
    }
    
    // Spawn a new zap cell at a random position
    private func spawnRandomZapCell() {
        // Get the grid size
        let gridSize = GameConstants.defaultGridSize
        
        // Get current player position to avoid spawning there
        let playerPos = playerManager.getPlayerPosition()
        
        // Try to find a valid position that's not where the player is
        var row = Int.random(in: 0..<gridSize)
        var col = Int.random(in: 0..<gridSize)
        
        // Simple retry to avoid placing on player
        let maxAttempts = 5
        var attempts = 0
        
        while (row == playerPos.y && col == playerPos.x) && attempts < maxAttempts {
            row = Int.random(in: 0..<gridSize)
            col = Int.random(in: 0..<gridSize)
            attempts += 1
        }
        
        // Only add if we found a non-player position or we're out of attempts
        if row != playerPos.y || col != playerPos.x || attempts >= maxAttempts {
            zapCellManager.addZapCell(row: row, col: col, gameTime: elapsedTime)
        }
    }
    
    // MARK: - Update Loop
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            gameStartTime = currentTime
            return
        }
        
//        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        elapsedTime = currentTime - gameStartTime
        
        // Check if it's time to spawn a new zap cell
        if playerAlive && elapsedTime >= nextZapSpawnTime {
            spawnRandomZapCell()
            nextZapSpawnTime = elapsedTime + zapSpawnInterval
        }
        
        // Update zap cells and check if player was hit
        if playerAlive {
            let playerPosition = playerManager.getPlayerPosition()
            let playerHit = zapCellManager.update(
                currentTime: elapsedTime,
                playerPosition: playerPosition
            )
            
            if playerHit {
                playerManager.playerDie()
            }
        }
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        startTouchPosition = touch.location(in: self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let start = startTouchPosition, playerAlive else { return }
        let end = touch.location(in: self)
        
        // Calculate horizontal and vertical differences
        let dx = end.x - start.x
        let dy = end.y - start.y
        
        // Determine if the swipe is more horizontal or vertical
        if abs(dx) > abs(dy) && abs(dx) > GameConstants.minSwipeDistance {
            // Horizontal swipe
            if dx > 0 {
                playerManager.movePlayer(direction: "Right")
            } else {
                playerManager.movePlayer(direction: "Left")
            }
        } else if abs(dy) > abs(dx) && abs(dy) > GameConstants.minSwipeDistance {
            // Vertical swipe
            if dy > 0 {
                playerManager.movePlayer(direction: "Up")
            } else {
                playerManager.movePlayer(direction: "Down")
            }
        }
        
        // Reset start position
        startTouchPosition = nil
    }
    
    // MARK: - Public Methods
    
    // Method to pause the game
    func pauseGame() {
        timerManager.pauseTimer()
        audioManager.changeMusic(to: .pause)
    }
    
    // Method to resume the game
    func resumeGame() {
        if playerAlive {
            timerManager.resumeTimer()
            audioManager.changeMusic(to: .game)
        }
    }
    
    // Method to restart the game
    func restartGame() {
        // Reset game state
        playerAlive = true
        
        // Reset spawn timing
        zapSpawnInterval = 5.0 // Reset to base spawn interval
        nextZapSpawnTime = lastUpdateTime + 3.0 // Wait 3 seconds before first spawn after restart
        
        // Reset managers
        timerManager.startTimer()
        audioManager.changeMusic(to: .game)
        
        // Reset player position
        playerManager.setPlayerPosition(GameConstants.playerDefaultPosition)
        
        // Clear existing zap cells
        zapCellManager.clearAllZapCells()
        
        // Record start time and start timer
        gameStartTime = CACurrentMediaTime()
    }
}
