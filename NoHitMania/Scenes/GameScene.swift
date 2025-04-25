//
//  GameScene.swift
//  NoHitMania
//
//  Created by Christian Barajas on 4/15/25.
//

import SpriteKit

class GameScene: SKScene {
    private var startTouchPosition: CGPoint?
    var getDirectionCallback: ((String) -> Void)?
    
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
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        setupGrid()
        createPlayer()
        
        // Add electric cells
        addZapCell(row: 1, col: 3)
        addZapCell(row: 3, col: 2)
        
        // Record start time
        gameStartTime = CACurrentMediaTime()
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
            getDirectionCallback?("Moved \(direction)")
        } else {
            getDirectionCallback?("Can't move \(direction)")
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
}
