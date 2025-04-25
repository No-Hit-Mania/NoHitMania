//
//  GameScene.swift
//  NoHitMania
//
//  Created by Christian Barajas on 4/15/25.
//

import SpriteKit
import Combine

class GameScene: SKScene {
    // timer related things
    private var scoreTime: TimeInterval = 0.0
    private var accumulatedTime: TimeInterval = 0.0
    private var startTime: Date? = nil
    private var isTimerRunning: Bool = false
    // change double to change framerate
    private var timer = Timer.publish(every: 1.0/60.0, on: .main, in: .common).autoconnect()
    private var scoreTimerLabel: SKLabelNode!
    private var gameTimerSubscription: AnyCancellable?

    private var secondsBetweenLevels: Int = 5

    // Touch Screen configs
    private var startTouchPosition: CGPoint?

    // Grid configuration
    private let gridSize = 5
    private var cellSize: CGFloat = 0
    private var gridOrigin = CGPoint.zero

    // Player node
    private var playerNode: SKSpriteNode!

    // Player grid position (0-4, 0-4)
    private var playerGridPosition = GridPosition(x: 2, y: 2)
    
    // Electric cells
    private var zapCells: [(row: Int, col: Int, nextActivationTime: TimeInterval)] = []
    private var lastUpdateTime: TimeInterval = 0
    private var gameStartTime: TimeInterval = 0

    // Player logic
    private var playerAlive:Bool = true
    private var currentLevel: Int = 1
    private var currentLevelLabel: SKLabelNode!

    // BGM of the game scene
    private var backgroundMusicNode: SKAudioNode?

    // when scene appears
    override func didMove(to view: SKView) {
        backgroundColor = .black
        setupGrid()
        createPlayer()
        
        // Add electric cells
        addZapCell(row: 1, col: 3)
        addZapCell(row: 3, col: 2)
        
        // Record start time
        gameStartTime = CACurrentMediaTime()
        setupTimer()
        setupBackgroundMusic()
        startTimer() // Start the timer when the scene loads

    }
    
    private func startTimer() {
        accumulatedTime = 0.0
        scoreTime = 0.0
        startTime = Date()
        isTimerRunning = true
        gameTimerSubscription = timer
            .sink { [weak self] _ in
                self?.timerUpdate()
            }
    }

    private func pauseTimer() {
        if isTimerRunning, let start = startTime {
            // Add up the time since last start/pause
            accumulatedTime += Date().timeIntervalSince(start)
            startTime = nil
            isTimerRunning = false
            gameTimerSubscription?.cancel()
            gameTimerSubscription = nil
            print("pauseTimer: at: \(formattedTime(elapsed: accumulatedTime))")
        }
    }

    private func resumeTimer() {
        if !isTimerRunning {
            startTime = Date() // Set a new start time for the current run
            isTimerRunning = true
            gameTimerSubscription = timer
                .sink { [weak self] _ in
                    self?.timerUpdate()
                }
            print("pauseTimer: at: \(formattedTime(elapsed: accumulatedTime))")
        }
    }

    private func timerUpdate() {
        if isTimerRunning {
            if playerAlive {
                guard let startTime = self.startTime, let scoreTimerLabel = self.scoreTimerLabel else {
                    return
                }
                // Calculate the elapsed time since the current start and add the accumulated time
                let elapsedTime = Date().timeIntervalSince(startTime)
                self.scoreTime = elapsedTime + self.accumulatedTime
                scoreTimerLabel.text = self.formattedTime(elapsed: self.scoreTime)

                if self.currentLevel < 5 {
                    let new = (Int(self.scoreTime)/self.secondsBetweenLevels) + 1
                    if new > self.currentLevel {
                        self.currentLevel += 1
                        self.currentLevelLabel.text = "Level: \(currentLevel)"
                        print("timerUpdate: level up \(currentLevel)")
                    }
                }
            } else {
                // TODO: Add game over screen
            }
        }
    }
    private func setupGrid() {
        // Calculate cell size based on scene size
        cellSize = min(size.width, size.height) / CGFloat(gridSize)
        
        // Calculate grid origin (top-left corner)
        gridOrigin = CGPoint(
            x: (size.width - (CGFloat(gridSize) * cellSize)) / 2,
            y: (size.height - (CGFloat(gridSize) * cellSize)) / 2
        )
        
        // Draw grid
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let cellRect = CGRect(
                    x: gridOrigin.x + (CGFloat(col) * cellSize),
                    y: gridOrigin.y + (CGFloat(row) * cellSize),
                    width: cellSize,
                    height: cellSize
                )
                
                let cell = SKShapeNode(rect: cellRect)
                cell.strokeColor = .white
                cell.lineWidth = 1
                cell.fillColor = UIColor.systemPink
                cell.name = "cell_\(row)_\(col)"
                addChild(cell)
            }
        }
    }
    
    private func addZapCell(row: Int, col: Int) {
        if let cell = childNode(withName: "cell_\(row)_\(col)") as? SKShapeNode {
            cell.fillColor = UIColor.yellow
            cell.name = "zap_\(row)_\(col)"
            
            // Schedule first activation in 2-4 seconds
            let firstActivation = TimeInterval.random(in: 2...4)
            zapCells.append((row: row, col: col, nextActivationTime: firstActivation))
        }
    }

    private func createPlayer() {
        // Create player slightly smaller than cell
        let playerSize = cellSize * 0.8
        playerNode = SKSpriteNode(imageNamed: "pixil-frame-0")
        playerNode.size = CGSize(width: playerSize, height: playerSize)

        // Position player in the center cell initially
        updatePlayerNodePosition()

        addChild(playerNode)
    }

    private func setupTimer() {
        // timerLabel settings
        scoreTimerLabel = SKLabelNode(text: "00:00.00")
        scoreTimerLabel.fontColor = .white
        scoreTimerLabel.fontSize = 30
        scoreTimerLabel.position = CGPoint(x: size.width / 2, y: size.height - 100)
        scoreTimerLabel.fontName = "Helvetica-Bold"
        addChild(scoreTimerLabel)

        // levelLabel settings
        currentLevelLabel = SKLabelNode(text: "Level: \(currentLevel)")
        currentLevelLabel.fontColor = .white
        currentLevelLabel.fontName = "Helvetica-Bold"
        currentLevelLabel.fontSize = 25
        currentLevelLabel.position = CGPoint(x: size.width / 2, y: size.height - 135)

        addChild(currentLevelLabel)

        isTimerRunning = false
    }

    private func updatePlayerNodePosition() {
        // Convert grid position to scene position
        let pixelX = gridOrigin.x + (CGFloat(playerGridPosition.x) + 0.5) * cellSize
        let pixelY = gridOrigin.y + (CGFloat(playerGridPosition.y) + 0.5) * cellSize

        // Create move action
        let moveAction = SKAction.move(to: CGPoint(x: pixelX, y: pixelY), duration: 0.2)
        moveAction.timingMode = .easeOut

        playerNode.run(moveAction)
    }

    private func movePlayer(direction: String) {
        var moved = false

        switch direction {
        case "Up":
            if playerGridPosition.y < gridSize - 1 {
                playerGridPosition.y += 1
                moved = true
            }
        case "Down":
            if playerGridPosition.y > 0 {
                playerGridPosition.y -= 1
                moved = true
            }
        case "Left":
            if playerGridPosition.x > 0 {
                playerGridPosition.x -= 1
                moved = true
            }
        case "Right":
            if playerGridPosition.x < gridSize - 1 {
                playerGridPosition.x += 1
                moved = true
            }
        default:
            break
        }

        if moved {
            updatePlayerNodePosition()
            print("movePlayer: Moved \(direction)")
        } else {
            print("movePlayer: Can't move \(direction)")
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            gameStartTime = currentTime
            return
        }
        
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        let elapsedTime = currentTime - gameStartTime
        
        // Check zap cells
        checkZapCells(currentTime: elapsedTime)
    }
    
    private func checkZapCells(currentTime: TimeInterval) {
        for i in 0..<zapCells.count {
            if currentTime >= zapCells[i].nextActivationTime {
                // Time to activate this zap cell!
                activateZapCell(row: zapCells[i].row, col: zapCells[i].col)
                
                // Schedule next activation in 3-6 seconds
                zapCells[i].nextActivationTime = currentTime + TimeInterval.random(in: 3...6)
            }
            
            // Flash warning animation as activation approaches
            let timeUntilActivation = zapCells[i].nextActivationTime - currentTime
            if timeUntilActivation < 1.0 {
                // Flash warning for the last second
                flashWarning(row: zapCells[i].row, col: zapCells[i].col, intensity: Float(1.0 - timeUntilActivation))
            }
        }
    }
    
    private func flashWarning(row: Int, col: Int, intensity: Float) {
        if let cell = childNode(withName: "zap_\(row)_\(col)") as? SKShapeNode {
            // Pulsate between yellow and brighter yellow based on intensity
            let brightFactor = 0.5 + (CGFloat(intensity) * 0.5)
            cell.fillColor = UIColor.yellow.withAlphaComponent(brightFactor)
        }
    }
    
    private func activateZapCell(row: Int, col: Int) {
        if let cell = childNode(withName: "zap_\(row)_\(col)") as? SKShapeNode {
            // Create zap animation
            let flashSequence = SKAction.sequence([
                SKAction.colorize(with: UIColor.white, colorBlendFactor: 1, duration: 0.05),
                SKAction.colorize(with: UIColor.systemBlue, colorBlendFactor: 1, duration: 0.1),
                SKAction.colorize(with: UIColor.yellow, colorBlendFactor: 1, duration: 0.2)
            ])
            
            cell.run(flashSequence)
            
            // Check if player is on this cell
            if playerGridPosition.y == row && playerGridPosition.x == col {
                playerDie()
            }
        }
    }
    
    private func playerDie() {
        // Play death animation
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let scale = SKAction.scale(to: 1.5, duration: 0.3)
        let group = SKAction.group([fadeOut, scale])
        
        playerNode.run(group) {
            // Reset player position after death animation
            self.playerGridPosition = GridPosition(x: 2, y: 2) // Reset to center
            self.playerNode.alpha = 1.0
            self.playerNode.setScale(1.0)
            self.updatePlayerNodePosition()
            self.getDirectionCallback?("You died! Back to start.")
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        startTouchPosition = touch.location(in: self)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let start = startTouchPosition else { return }
        let end = touch.location(in: self)
        
        // Calculate horizontal and vertical differences
        let dx = end.x - start.x
        let dy = end.y - start.y
        
        // Set minimum swipe distance to recognize a swipe
        let minSwipeDistance: CGFloat = 20
        
        // Determine if the swipe is more horizontal or vertical
        if abs(dx) > abs(dy) && abs(dx) > minSwipeDistance {
            // Horizontal swipe
            if dx > 0 {
                movePlayer(direction: "Right")
            } else {
                movePlayer(direction: "Left")
            }
        } else if abs(dy) > abs(dx) && abs(dy) > minSwipeDistance {
            // Vertical swipe
            if dy > 0 {
                movePlayer(direction: "Up")
            } else {
                movePlayer(direction: "Down")
            }
        }
        
        // Reset start position
        startTouchPosition = nil
    }

    func formattedTime(elapsed: TimeInterval) -> String {
        let totalSeconds = Int(elapsed)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        // Calculate the hundredths part from the fractional seconds
        let hundredths = Int((elapsed - Double(totalSeconds)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, hundredths)
    }
    private func setupBackgroundMusic() {
        // Ensure music isn't already playing
        if backgroundMusicNode == nil {
            let musicNode = SKAudioNode(fileNamed: "gameMusicLoopable.mp3")
            musicNode.autoplayLooped = true
            musicNode.isPositional = false
            
            addChild(musicNode)
            backgroundMusicNode = musicNode
            
            print("setupBackgroundMusic: done.")
        }
    }
    
    func changeActiveMusic(music: String) {
        // remove current music
        if let currentMusicNode = backgroundMusicNode {
            currentMusicNode.removeFromParent()
            backgroundMusicNode = nil
        }
        
        var fileName: String
        switch music {
        case "game":
            fileName = "gameMusicLoopable.mp3"
        case "pause":
            fileName = "pauseMusic.mp3"
        case "none":
            print("changeActiveMusic: stopped")
            return
            
        default:
            print("WARNING changeActiveMusic: \(music) not a selectable song")
            fileName = "gameMusicLoopable.mp3"
        }
        
        let newMusicNode = SKAudioNode(fileNamed: fileName)
        newMusicNode.autoplayLooped = true
        newMusicNode.isPositional = false

        addChild(newMusicNode)
        backgroundMusicNode = newMusicNode

        print("changeActiveMusic: playing \(fileName)")
        
    }
}
