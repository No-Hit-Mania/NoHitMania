//
//  PlayerManager.swift
//  NoHitMania
//
//  Created on 4/24/25.
//

import SpriteKit

class PlayerManager {
    // Player node
    public var playerNode: SKSpriteNode!
    
    // Player grid position
    private var playerGridPosition = GridPosition(x: 2, y: 2)
    
    // Reference to the scene
    private weak var scene: SKScene?
    
    // Grid information
    private let gridSize: Int
    private let cellSize: CGFloat
    private let gridOrigin: CGPoint
    
    // Callback for player death
    var onPlayerDeath: (() -> Void)?
    
    // Initialize with scene reference and grid parameters
    init(scene: SKScene, gridSize: Int, cellSize: CGFloat, gridOrigin: CGPoint) {
        self.scene = scene
        self.gridSize = gridSize
        self.cellSize = cellSize
        self.gridOrigin = gridOrigin
        
        createPlayer()
    }
    
    // Create the player sprite
    private func createPlayer() {
        guard let scene = scene else { return }
        
        // Create player slightly smaller than cell
        let playerSize = cellSize * 0.8
        playerNode = SKSpriteNode(imageNamed: "pixil-frame-0")
        playerNode.size = CGSize(width: playerSize, height: playerSize)
        
        // Position player in the center cell initially
        updatePlayerNodePosition()
        
        scene.addChild(playerNode)
    }
    
    // Update the player's visual position
    private func updatePlayerNodePosition() {
        // Convert grid position to scene position
        let pixelX = gridOrigin.x + (CGFloat(playerGridPosition.x) + 0.5) * cellSize
        let pixelY = gridOrigin.y + (CGFloat(playerGridPosition.y) + 0.5) * cellSize
        
        // Create move action
        let moveAction = SKAction.move(to: CGPoint(x: pixelX, y: pixelY), duration: 0.2)
        moveAction.timingMode = .easeOut
        
        playerNode.run(moveAction)
    }
    
    // Move the player in a direction
    func movePlayer(direction: String) {
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
    
    // Handle player death
    func playerDie() {
        // Play death animation
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let scale = SKAction.scale(to: 1.5, duration: 0.3)
        let group = SKAction.group([fadeOut, scale])
        
        playerNode.run(group) { [weak self] in
            // Reset player position after death animation
            self?.playerGridPosition = GridPosition(x: 2, y: 2) // Reset to center
            self?.playerNode.alpha = 1.0
            self?.playerNode.setScale(1.0)
            self?.updatePlayerNodePosition()
            
            // Notify listeners about player death
            self?.onPlayerDeath?()
        }
    }
    
    // Get the player's current grid position
    func getPlayerPosition() -> GridPosition {
        return playerGridPosition
    }
    
    // Set the player's position (useful for game loading)
    func setPlayerPosition(_ position: GridPosition) {
        playerGridPosition = position
        updatePlayerNodePosition()
    }
}
