//
//  LazerManager.swift
//  NoHitMania
//
//  Created by Dylan Uribe on 4/29/25.
//

import SpriteKit

class LazerManager {
    // SKNodes
    var leftNode: SKSpriteNode
    var rightNode: SKSpriteNode
    var beam: SKSpriteNode

    // Texture reuse
    private let nubTexture1 = SKTexture(imageNamed: "NoHitManiaNub1")
    private let nubTexture4 = SKTexture(imageNamed: "NoHitManiaNub4")
    private let lazerTexture = SKTexture(imageNamed: "LazerBeam")

    // Scene references
    private weak var scene: SKScene?
    private weak var gridManager: GridManager?
    private weak var audioManager: AudioManager?

    private var cellSize: CGFloat
    private var gridOrigin: CGPoint
    private var gridSize: Int

    // Configuration
    private var currentLevel: Int
    public var lazerBeamFullDuration: Double = 6.0

    // State
    private var currentBeamRow: Int
    private var isActive: Bool
    private var lazerFiring: Bool
    private var lastStarted: TimeInterval

    // MARK: - Initialization
    init(scene: SKScene, currentLevel: Int = 1, gridManager: GridManager, audioManager: AudioManager) {
        self.scene = scene
        self.currentLevel = currentLevel
        self.gridManager = gridManager
        self.audioManager = audioManager

        // Grid setup
        let grid = gridManager
        self.cellSize = grid.getCellSize()
        self.gridOrigin = grid.getGridOrigin()
        self.gridSize = grid.getGridSize()

        // Configure nubs
        leftNode = SKSpriteNode(texture: nubTexture1)
        leftNode.size = CGSize(width: cellSize * (7/12), height: cellSize * (2/3))
        leftNode.zPosition = 2.0

        rightNode = SKSpriteNode(texture: nubTexture1)
        rightNode.xScale = -1.0
        rightNode.size = CGSize(width: cellSize * (7/12), height: cellSize * (2/3))
        rightNode.zPosition = 2.0

        // Configure beam
        beam = SKSpriteNode(texture: lazerTexture)
        beam.size = CGSize(width: cellSize * 10, height: cellSize * (2/3))

        // Initial positioning
        currentBeamRow = gridSize / 2
        let yPosition = gridOrigin.y + (CGFloat(currentBeamRow) * cellSize) + (cellSize / 2)
        let leftXPosition = gridOrigin.x + leftNode.size.width / 2
        let rightXPosition = gridOrigin.x + CGFloat(gridSize) * cellSize - rightNode.size.width / 2

        leftNode.position = CGPoint(x: leftXPosition, y: yPosition)
        rightNode.position = CGPoint(x: rightXPosition, y: yPosition)
        beam.position = CGPoint(x: leftXPosition, y: yPosition)

        isActive = false
        lazerFiring = false
        lastStarted = TimeInterval()
    }

    // MARK: - Placement
    func placeNewLazerBeam(currentTime: TimeInterval, currentLevel: Int) {
        var randomRow = Int.random(in: 0..<gridSize)
        var attempts = 0
        let maxAttempts = 3
        self.currentLevel = currentLevel

        while randomRow == currentBeamRow && attempts < maxAttempts {
            randomRow = Int.random(in: 0..<gridSize)
            attempts += 1
        }

        moveLazerBeamSet(targetRow: randomRow)

        if leftNode.parent == nil && rightNode.parent == nil {
            scene?.addChild(leftNode)
            scene?.addChild(rightNode)
        }

        isActive = true
        lazerFiring = false
        lastStarted = currentTime
        print("LazerManager: placeNewLazerBeam: \(randomRow), \(currentTime)")
        audioManager?.playSoundEffect(named: "lazerCharge")
    }

    private func moveLazerBeamSet(targetRow: Int) {
        guard targetRow >= 0 && targetRow < gridSize else {
            print("Target row is out of bounds.")
            return
        }

        currentBeamRow = targetRow
        let newYPosition = gridOrigin.y + (CGFloat(currentBeamRow) * cellSize) + (cellSize / 2)

        // Move actions
        let moveLeft = SKAction.moveTo(y: newYPosition, duration: 0.2)
        let moveRight = SKAction.moveTo(y: newYPosition, duration: 0.2)

        beam.removeFromParent()
        beam.position = CGPoint(x: gridOrigin.x + leftNode.size.width / 2, y: newYPosition)

        isActive = false
        lazerFiring = false

        leftNode.run(moveLeft)
        rightNode.run(moveRight)
    }

    // MARK: - Update
    func update(currentTime: TimeInterval, playerManager: PlayerManager, currentLevel: Int) -> Bool {
        var isPlayerHit = false
        let elapsed = currentTime - lastStarted

        if isActive {
            if elapsed >= lazerBeamFullDuration {
                print("LazerManager: update: timer is up")
                isActive = false
                lazerFiring = false
                beam.removeFromParent()
            } else if elapsed > (31.0 / 60.0) * lazerBeamFullDuration {
                // Active beam
                if beam.intersects(playerManager.playerNode) {
                    print("lazer kill")
                    return true
                }

                // Wiggle effect
                if beam.parent != nil {
                    let wiggleAmplitude: CGFloat = 0.5
                    let wiggleFrequency: CGFloat = 4.0
                    let offsetY = sin(elapsed * .pi * wiggleFrequency) * wiggleAmplitude
                    beam.position.y += offsetY
                }

            } else if elapsed > (30.0 / 60.0) * lazerBeamFullDuration {
                // Activate beam and play blast sound
                if beam.parent == nil {
                    scene?.addChild(beam)
                    lazerFiring = false // Reset so sound plays
                }

                if !lazerFiring {
                    lazerFiring = true
                    audioManager?.playSoundEffect(named: "lazerBlast")
                    leftNode.texture = nubTexture4
                    rightNode.texture = nubTexture4
                } else {
                    beam.position.y -= 0.1
                }

            } else {
                // Charging textures alternate
                if elapsed.truncatingRemainder(dividingBy: 1.0) < 0.5 {
                    leftNode.texture = nubTexture1
                    rightNode.texture = nubTexture1
                } else {
                    leftNode.texture = nubTexture4
                    rightNode.texture = nubTexture4
                }
            }
        }

        return isPlayerHit
    }

    // MARK: - Reset
    public func clearAllLazers() {
        leftNode.removeFromParent()
        rightNode.removeFromParent()
        beam.removeFromParent()
        lazerFiring = false
        isActive = false
    }
}
