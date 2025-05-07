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
    public var gridManager: GridManager!
    public var playerManager: PlayerManager!
    public var zapCellManager: ZapCellManager!
    public var timerManager: GameTimerManager!
    public var audioManager: AudioManager!
    public var lazerManager: LazerManager!
    public var boulderManager: BoulderManager!

    // UI elements
    private var scoreTimerLabel: SKLabelNode!
    private var currentLevelLabel: SKLabelNode!
    
    // Touch handling
    private var startTouchPosition: CGPoint?
    private var canPressPause: Bool = false
    
    // Game state
    private var playerAlive: Bool = true
    private var lastUpdateTime: TimeInterval = 0
    private var gameStartTime: TimeInterval = 0
    private var elapsedTime: TimeInterval = 0
    
    // Hazard Time Spawns (level 1 - Zap, 2 - Lazer, 3 - Boulder)
    private var nextZapSpawnTime: TimeInterval = 3.0 // Initial spawn after 3 seconds
    private var zapSpawnInterval: TimeInterval = 5.0 // Base interval between spawns
    
    
    private var nextLazerSpawnTime: TimeInterval = 5.0  // Spawn at level 2
    private var lazerSpawnInterval: TimeInterval = 6.5 // interval between spawns
    
    private var nextBoulderSpawnTime: TimeInterval = 5.0 // spawn at level 3
    private var boulderSpawnInterval: TimeInterval = 6.0
    

    // MARK: - Scene Lifecycle
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
        
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
        //Adds pause button
        addPauseButton()
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

        // Create timer manager
        timerManager = GameTimerManager()
        timerManager.onTimerUpdate = { [weak self] timeString in
            self?.scoreTimerLabel.text = timeString
        }
        timerManager.onLevelUpdate = { [weak self] level in
            self?.currentLevelLabel.text = "Level: \(level)"
            self?.updateSpawnRateForLevel(level)
        }

        // Play music using shared AudioManager
        AudioManager.shared.changeMusic(to: .game, in: self)

        // Create hazard managers
        zapCellManager = ZapCellManager(scene: self)
        lazerManager = LazerManager(scene: self, gridManager: gridManager, audioManager: AudioManager.shared)
        boulderManager = BoulderManager(scene: self, currentLevel: 1, gridManager: gridManager, audioManager: AudioManager.shared)
    }

    
    private func addPauseButton() {
        canPressPause = true
        let texture = SKTexture(imageNamed: "pause_icon")
        let pauseNode = SKSpriteNode(texture: texture)
        pauseNode.name = "pauseButton"
        pauseNode.size = CGSize(width: 50, height: 50)
        pauseNode.position = CGPoint(x: size.width / 10, y: size.height - 60)
        pauseNode.zPosition = 100
        addChild(pauseNode)
    }

    private func setupUI() {
        // Timer label
        scoreTimerLabel = SKLabelNode(text: "00:00.00")
        scoreTimerLabel.fontColor = .black
        scoreTimerLabel.fontSize = 30
        scoreTimerLabel.position = CGPoint(x: size.width / 2, y: size.height - 100)
        scoreTimerLabel.fontName = "Helvetica-Bold"
        addChild(scoreTimerLabel)
        
        // Level label
        currentLevelLabel = SKLabelNode(text: "Level: 1")
        currentLevelLabel.fontColor = .black
        currentLevelLabel.fontName = "Helvetica-Bold"
        currentLevelLabel.fontSize = 25
        currentLevelLabel.position = CGPoint(x: size.width / 2, y: size.height - 135)
        addChild(currentLevelLabel)
    }
    
    // MARK: - Game Logic
    
    private func handlePlayerDeath() {
        playerAlive = false
        timerManager.pauseTimer()
        AudioManager.shared.changeMusic(to: .pause, in: self)
        AudioManager.shared.changeMusic(to: .game, in: self)

        
        restartGame()

        // Add any additional death handling here
        // For example, showing game over screen
    }
    
    // Update all spawn rate based on the current level
    private func updateSpawnRateForLevel(_ level: Int) {
        // Decrease spawn interval as level increases (faster spawning)
        // But ensure it doesn't go below a minimum threshold
        let minSpawnInterval: TimeInterval = 2.0 // Fastest spawn rate (1 per second)
        let decreaseFactor: TimeInterval = 0.5 // How much to decrease per level
        
      
        let minLazerSpawn: TimeInterval = 3.5
        
        zapSpawnInterval = max(zapSpawnInterval - decreaseFactor, minSpawnInterval)
        lazerSpawnInterval = max(lazerSpawnInterval - decreaseFactor, minLazerSpawn)
        
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
        
        // check if the game is active
        if timerManager.isTimerRunning {
            // Check if it's time to spawn a new zap cell
            if playerAlive && elapsedTime >= nextZapSpawnTime {
                spawnRandomZapCell()
                nextZapSpawnTime = elapsedTime + zapSpawnInterval
            }
            // Check if its time for a new lazer beam
            if playerAlive && elapsedTime >= nextLazerSpawnTime {
                lazerManager.placeNewLazerBeam(currentTime: elapsedTime, currentLevel: timerManager.currentLevel )
                nextLazerSpawnTime = elapsedTime + lazerSpawnInterval
            }
            // Check if its time to spawn a new boulder {
            if playerAlive && elapsedTime >= nextBoulderSpawnTime {
                boulderManager.startRollingBoulder(currentTime: elapsedTime, currentLevel: timerManager.currentLevel)
                nextBoulderSpawnTime = elapsedTime + boulderSpawnInterval
            }
            // Update zap cells and check if player was hit
            if playerAlive {
                let playerPosition = playerManager.getPlayerPosition()
                var playerHit = zapCellManager.update(
                    currentTime: elapsedTime,
                    playerPosition: playerPosition
                )
        
                if !playerHit {
                    playerHit = lazerManager.update(
                        currentTime: elapsedTime,
                        playerManager: playerManager,
                        currentLevel: timerManager.currentLevel
                    )
                    
                }
                if !playerHit {
                    playerHit = boulderManager.update(currentTime: elapsedTime, playerManager: playerManager, currentLevel: timerManager.currentLevel)
                }

                if playerHit {
                    playerAlive = false
                    playerManager.playerDie()
                }
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
        let location = touch.location(in: self)
        let node = self.atPoint(location)

        if node.name == "pauseButton" && canPressPause {
            pauseGame()
            let modal = OptionsScene(size: self.size)
            modal.zPosition = 10
            modal.onQuit = { [weak self] in
                if let view = self?.view {
                    let gameScene = MainMenuScene(size: view.bounds.size)
                    let transition = SKTransition.fade(withDuration: 0.5) // You can change the transition type and duration here
                    view.presentScene(gameScene, transition: transition)
                }
            }
            modal.name = "optionsModal"
            addChild(modal)

        }
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
        AudioManager.shared.changeMusic(to: .pause, in: self)
        canPressPause = false
    }
    
    // Method to resume the game
    func resumeGame() {
        print("game resumed")
        if playerAlive {
            // reset the boulder since its movement is not based on the update loop
            boulderManager.clearAllBoulder()
            timerManager.resumeTimer()
            AudioManager.shared.changeMusic(to: .pause, in: self)
            AudioManager.shared.changeMusic(to: .game, in: self)
            canPressPause = true

        }
    }

    // MARK: - RestartGame
    // Method to restart the game
    func restartGame() {
        // Reset game state
        playerAlive = true
        
        // Reset spawn timing
        zapSpawnInterval = 5.0 // Reset to base spawn interval
        nextZapSpawnTime = 3.0 // Wait 3 seconds before first spawn after restart
        nextLazerSpawnTime = 5.0 // lvl 2
        nextBoulderSpawnTime = 10.0 // lvl 3
        // Reset managers
        timerManager.startTimer()
        currentLevelLabel.text = "Level: 1"
        AudioManager.shared.changeMusic(to: .pause, in: self)
        AudioManager.shared.changeMusic(to: .game, in: self)

        
        // Reset player position
        playerManager.setPlayerPosition(GameConstants.playerDefaultPosition)
        
        // Clear existing zap cells
        zapCellManager.clearAllZapCells()
        lazerManager.clearAllLazers()
        boulderManager.clearAllBoulder()
        
        // Record start time and start timer
        gameStartTime = CACurrentMediaTime()
    }
}
