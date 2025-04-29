//
//  ZapCellManager.swift
//  NoHitMania
//
//  Created on 4/24/25.
//

import SpriteKit

class ZapCellManager {
    // Collection of zap cells
    private var zapCells: [ZapCell] = []
    
    // Reference to the scene
    private weak var scene: SKScene?
    
    // Configuration for zap cells
    private var chargeTimeReductionFactor: Double = 0.0 // 0.0 = no reduction, 1.0 = instant activation
    
    // Initialize with a scene reference
    init(scene: SKScene) {
        self.scene = scene
    }
    
    // Add a new zap cell
    func addZapCell(row: Int, col: Int, gameTime: TimeInterval) {
        guard let scene = scene else { return }
        
        if let cell = scene.childNode(withName: "cell_\(row)_\(col)") as? SKShapeNode {
            // Create a new zap cell with appropriate activation time
            let baseActivationDelay = 2.0 // Base time before activation
            let adjustedDelay = baseActivationDelay * (1.0 - chargeTimeReductionFactor)
            
            let zapCell = ZapCell(
                row: row,
                col: col,
                nextActivationTime: gameTime + adjustedDelay
            )
            
            // Set initial appearance
            cell.fillColor = UIColor.yellow.withAlphaComponent(0.3)
            cell.name = "zap_\(row)_\(col)"
            
            // Add to collection
            zapCells.append(zapCell)
            
            // Debug log
            print("Added zap cell at (\(row),\(col)) with activation in \(adjustedDelay) seconds")
        }
    }
    
    // In ZapCellManager.update()
    func update(currentTime: TimeInterval, playerPosition: GridPosition) -> Bool {
        var playerHit = false
        var cellsToRemove: [Int] = []

<<<<<<< HEAD
        print("Current Time: \(currentTime)")

        for i in 0..<zapCells.count {
            let zapCell = zapCells[i]
            print("Zap Cell (\(zapCell.row), \(zapCell.col)) - Activation Time: \(zapCell.nextActivationTime)")
=======
//      TODO: imo its a lot cleaner with these prints commented out but u do u
//        print("ZapCellManager: Current Time: \(currentTime)")
        for i in 0..<zapCells.count {
            let zapCell = zapCells[i]
//            print("Zap Cell (\(zapCell.row), \(zapCell.col)) - Activation Time: \(zapCell.nextActivationTime)")
>>>>>>> 6441fde9760a300e71725e361703b15f2ae35eb0

            if currentTime >= zapCell.nextActivationTime {
                print("Activating zap cell at (\(zapCell.row),\(zapCell.col))")
                let didHitPlayer = activateZapCell(row: zapCell.row, col: zapCell.col, playerPosition: playerPosition)
                if didHitPlayer {
                    playerHit = true
                }
                cellsToRemove.append(i)
                print("Activated and marked for removal.")
            } else {
                let intensity = zapCell.warningIntensity(currentTime: currentTime)
                if intensity > 0 {
                    flashWarning(row: zapCell.row, col: zapCell.col, intensity: intensity)
<<<<<<< HEAD
                     print("Warning flashed for (\(zapCell.row),\(zapCell.col)) - Intensity: \(intensity)")
=======
//                     print("Warning flashed for (\(zapCell.row),\(zapCell.col)) - Intensity: \(intensity)")
>>>>>>> 6441fde9760a300e71725e361703b15f2ae35eb0
                }
            }
        }

        // ... rest of the function ...
        
        // Remove activated cells (in reverse order to avoid index issues)
        for index in cellsToRemove.sorted(by: >) {
            let zapCell = zapCells[index]
            resetCellAppearance(row: zapCell.row, col: zapCell.col)
            zapCells.remove(at: index)
            
            // Debug log
            print("Removed zap cell at (\(zapCell.row),\(zapCell.col))")
        }
        
        return playerHit
    }
    
    // Adjust charge time based on level
    func adjustChargeTime(reductionFactor: Double) {
        chargeTimeReductionFactor = min(max(reductionFactor, 0.0), 0.9) // Clamp between 0 and 0.9
        print("Charge time reduction factor set to: \(chargeTimeReductionFactor)")
    }
    
    // Clear all zap cells (for game restart)
    func clearAllZapCells() {
        // Reset appearance for all cells
        for zapCell in zapCells {
            resetCellAppearance(row: zapCell.row, col: zapCell.col)
        }
        
        // Clear the array
        zapCells.removeAll()
        print("All zap cells cleared")
    }
    
    // Reset cell appearance after it's been used
    private func resetCellAppearance(row: Int, col: Int) {
        guard let scene = scene else { return }
        
        if let cell = scene.childNode(withName: "zap_\(row)_\(col)") as? SKShapeNode {
            // Reset to original appearance
            cell.fillColor = GameConstants.Colors.gridCellDefault // Use clear or your game's default cell color
            cell.strokeColor = .white // Reset stroke color
            cell.name = "cell_\(row)_\(col)" // Reset to original name
            
            // Clear any running actions
            cell.removeAllActions()
            
            // Simple reset animation
            let resetAction = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.3, duration: 0.2),
                SKAction.fadeAlpha(to: 1.0, duration: 0.2)
            ])
            cell.run(resetAction)
        }
    }
    
    // Flash warning animation for a zap cell
    private func flashWarning(row: Int, col: Int, intensity: Float) {
        guard let scene = scene else { return }
        
        let nodeName = "zap_\(row)_\(col)"
        if let cell = scene.childNode(withName: nodeName) as? SKShapeNode {
            // Stop any existing animations
            cell.removeAllActions()
            
            // Pulsate between yellow and brighter yellow based on intensity
            let brightFactor = 0.3 + (CGFloat(intensity) * 0.7) // More pronounced difference
            
            // Create a pulsating animation for the warning
            if intensity > 0.7 {
                // Fast pulsing for high intensity (near activation)
                let pulseAction = SKAction.sequence([
                    SKAction.fadeAlpha(to: 1.0, duration: 0.1),
                    SKAction.fadeAlpha(to: 0.5, duration: 0.1)
                ])
                
                cell.run(SKAction.repeatForever(pulseAction))
                cell.fillColor = UIColor.orange.withAlphaComponent(brightFactor)
            } else {
                // Steady glow for lower intensity
                cell.fillColor = UIColor.yellow.withAlphaComponent(brightFactor)
            }
        }
    }
    
    // Activate a zap cell
    private func activateZapCell(row: Int, col: Int, playerPosition: GridPosition) -> Bool {
        guard let scene = scene else { return false }
        
        let nodeName = "zap_\(row)_\(col)"
        if let cell = scene.childNode(withName: nodeName) as? SKShapeNode {
            // Stop any existing animations
            cell.removeAllActions()
            
            // Create zap animation
            let flashSequence = SKAction.sequence([
                SKAction.colorize(with: .white, colorBlendFactor: 1.0, duration: 0.05),
                SKAction.colorize(with: .systemBlue, colorBlendFactor: 1.0, duration: 0.1),
                SKAction.wait(forDuration: 0.1),
                SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.2)
            ])
            
            cell.run(flashSequence)
            
            // Add particle effect for more impact
            let particleEffect = SKEmitterNode()
            particleEffect.position = cell.position
            particleEffect.zPosition = cell.zPosition + 1
            
            // Basic particle setup if no file exists
            particleEffect.particleColor = .cyan
            particleEffect.particleColorBlendFactor = 1.0
            particleEffect.particleColorSequence = SKKeyframeSequence(
                keyframeValues: [UIColor.white, UIColor.cyan, UIColor.blue],
                times: [0.0, 0.5, 1.0]
            )
            particleEffect.particleLifetime = 0.7
            particleEffect.emissionAngle = 0
            particleEffect.emissionAngleRange = CGFloat.pi * 2
            particleEffect.particleSpeed = 50
            particleEffect.particleSpeedRange = 20
            particleEffect.particleAlpha = 0.8
            particleEffect.particleAlphaRange = 0.2
            particleEffect.particleAlphaSpeed = -1.0
            particleEffect.particleScale = 0.5
            particleEffect.particleScaleRange = 0.2
            particleEffect.particleScaleSpeed = -0.5
            particleEffect.numParticlesToEmit = 30
            
            scene.addChild(particleEffect)
            
            // Remove particle effect after a delay
            let removeAction = SKAction.sequence([
                SKAction.wait(forDuration: 1.0),
                SKAction.removeFromParent()
            ])
            particleEffect.run(removeAction)
            
            // Check if player is on this cell
            return playerPosition.y == row && playerPosition.x == col
        }
        
        return false
    }
    
    // Get current zap cells (useful for saving game state)
    func getZapCells() -> [ZapCell] {
        return zapCells
    }
    
    // Set zap cells (useful for loading game state)
    func setZapCells(_ cells: [ZapCell]) {
        zapCells = cells
    }
}
