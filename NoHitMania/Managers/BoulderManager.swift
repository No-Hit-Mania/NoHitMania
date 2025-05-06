//
//  BoulderManager.swift
//  NoHitMania
//
//  Created by Dylan Uribe on 5/1/25.
//
import SpriteKit

class BoulderManager {
    // SkNodes
    var boulderNode: SKSpriteNode

    // weak ref to scene
    private weak var scene: SKScene?
    // Reference to the GridManager
    private weak var gridManager: GridManager?
    // Reference to the AudioManager
    private weak var audioManager: AudioManager?
    private var cellSize: CGFloat
    private var gridOrigin: CGPoint
    private var gridSize: Int

    // Configuration for levels
    private var currentLevel: Int
    // 2/3 of the lazer beam existance should be charge, then the rest is active hitbox
    // The minimum time a lazerbeam can be should be 3 seconds
    public var rockFullDuration: Double = 6.0
    
    private var minRollDuration = 2.0
    // current column (0-4)
    private var currentCol: Int
    private var isActive: Bool
    private var lastStarted: TimeInterval

    // MARK: - Initialization
    init(scene: SKScene, currentLevel: Int = 1, gridManager: GridManager, audioManager: AudioManager) {
        self.scene = scene
        self.currentLevel = currentLevel
        self.gridManager = gridManager
        self.audioManager = audioManager
        // get grid dimensions
        let grid = gridManager
        cellSize = grid.getCellSize()
        gridOrigin = grid.getGridOrigin()
        gridSize = grid.getGridSize()
        // configure node
        let rockTexture = SKTexture(imageNamed: "NoHitManiaBoulder")
        boulderNode = SKSpriteNode(texture: rockTexture)
        boulderNode.zPosition = 1.5



        boulderNode.size = CGSize(width: cellSize, height: cellSize)

        // put rock in the middle as default
        currentCol = gridSize / 2
        // Calculate the x position for rock
        let xPosition = gridOrigin.y + (CGFloat(currentCol) * cellSize) + (cellSize / 2)

        // Position all elements on the correct y coordinate
        let yPosition = gridOrigin.x + boulderNode.size.width / 2
        boulderNode.position = CGPoint(x: xPosition, y: yPosition)

        isActive = false
        self.lastStarted = TimeInterval()
        
        // TODO: remove this
        self.scene?.addChild(boulderNode)

    }
    // MARK: - Placement and Updating
    func startRollingBoulder(currentTime: TimeInterval, currentLevel: Int) {
        var randomCol = Int.random(in: 0..<gridSize)
        var attempts = 0
        let maxAttempts = 3
        self.currentLevel = currentLevel
        while randomCol == currentCol && attempts < maxAttempts {
            randomCol = Int.random(in: 0..<gridSize)
            attempts += 1
        }
        moveBoulder(targetCol: randomCol, currentLevel: currentLevel)


        isActive = true
        lastStarted = currentTime
        print("BoulderManager: startRolling: \(randomCol), \(currentTime)")
        // play boulder sfx

    }
    private func moveBoulder(targetCol: Int, currentLevel: Int) {
        // targetRow = 0-4
        // Ensure the targetRow is within the valid grid bounds
        isActive = false
        guard targetCol >= 0 && targetCol < gridSize else {
            print("Target row is out of bounds.")
            return
        }
        // decide if boulder will come from bottom or top 0 1
        let rand = Int.random(in: 0...1)
        
        currentCol = targetCol
        // Calculate the new y position for all elements
        var newYPosition = gridOrigin.y
        let topAboveGridYPos = cellSize * CGFloat(gridSize)
        if rand == 1 {
            newYPosition += topAboveGridYPos + (cellSize * 3 / 4)
        }
        else {
            newYPosition -= (cellSize)
        }
       
        let newXPosition = gridOrigin.x + CGFloat(currentCol) * cellSize
        
        // Despawn rock while moving to new col:
        boulderNode.removeFromParent()
        boulderNode.position = CGPoint(x: newXPosition + boulderNode.size.width / 2, y: newYPosition)
        
        // add it back
        if(boulderNode.parent == nil) {
            self.scene?.addChild(boulderNode)
        }
        // set Boulder to active
        isActive = true
        
        print("BoulderManager: moveBoulder: target \(targetCol), starting to roll ")
        
        // Move boulder to other end
        var targetY = gridOrigin.y
        if rand == 1 {
            targetY -= cellSize
        }
        else {
            targetY += topAboveGridYPos + (cellSize * 3/4)
        }
        
        var waitDuration: TimeInterval
        var rollingDuration: TimeInterval
        if currentLevel == 5 {
            waitDuration = 1.5
            rollingDuration = 2
        }
        else if currentLevel == 4 {
            waitDuration = 1.75
            rollingDuration = 3
        }
        else {
            waitDuration = 2.0
            rollingDuration = 3.5
        }
        
        let waitAction = SKAction.wait(forDuration: waitDuration)
        let moveBoulderAction = SKAction.moveTo(y: targetY, duration: rollingDuration)

        // Create a sequence that first waits, then moves
        let sequence = SKAction.sequence([waitAction, moveBoulderAction])

        // Run the sequence on your node
        boulderNode.run(sequence)

        
        
    }
    
    func update(currentTime: TimeInterval, playerManager: PlayerManager, currentLevel: Int) -> Bool {
        let isPlayerHit = false
        let elapsedTime = currentTime - lastStarted


        if (isActive) {
            if isActive && boulderNode.parent != nil && boulderNode.intersects(playerManager.playerNode) {
                print("boulder kill")
                isActive = false
                return true
            }
            // wiggle the boulder
            if isActive && boulderNode.parent != nil {
                let wiggleAmplitude: CGFloat = 0.5
                let wiggleFrequency: CGFloat = 4.0 // number of wobbles per second
                let offsetX = (sin(elapsedTime * .pi * wiggleFrequency) * wiggleAmplitude)
                boulderNode.position.x = boulderNode.position.x + offsetX
            }
        }
        return isPlayerHit
        
    }

    
    // MARK: - RestartGame
    public func clearAllBoulder() {
        boulderNode.removeFromParent()
    }
}
