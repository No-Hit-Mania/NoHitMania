//
//  LazerManager.swift
//  NoHitMania
//
//  Created by Dylan Uribe on 4/29/25.
//
import SpriteKit

class LazerManager {
    // SkNodes
    var leftNode: SKSpriteNode
    var rightNode: SKSpriteNode
    var beam: SKSpriteNode
    // weak ref to scene
    private weak var scene: SKScene?
    // Reference to the GridManager
    private weak var gridManager: GridManager?
    private var cellSize: CGFloat
    private var gridOrigin: CGPoint
    private var gridSize: Int

    // Configuration for levels
    private var currentLevel: Int
    // 2/3 of the lazer beam existance should be charge, then the rest is active hitbox
    // The minimum time a lazerbeam can be should be 3 seconds
    public var lazerBeamFullDuration: Double = 6.0
    
    // current beam row
    private var currentBeamRow: Int
    private var isActive: Bool
    private var lastStarted: TimeInterval

    // MARK: - Initialization
    init(scene: SKScene, currentLevel: Int = 1, gridManager: GridManager) {
        self.scene = scene
        self.currentLevel = currentLevel
        self.gridManager = gridManager

        // get grid dimensions
        let grid = gridManager
        cellSize = grid.getCellSize()
        gridOrigin = grid.getGridOrigin()
        gridSize = grid.getGridSize()
        // configure nodes
        let nubTexture = SKTexture(imageNamed: "NoHitManiaNub1")
        let lazerTexture = SKTexture(imageNamed: "LazerBeam")

        // Configure left nub
        leftNode = SKSpriteNode(texture: nubTexture)
        leftNode.size = CGSize(width: cellSize * (7/12), height: cellSize * (2/3))
        leftNode.zPosition = 2.0
        // Configure right nub
        rightNode = SKSpriteNode(texture: nubTexture)
        rightNode.xScale = -1.0
        rightNode.size = CGSize(width: cellSize * (7/12), height: cellSize * (2/3))
        rightNode.zPosition = 2.0

        beam = SKSpriteNode(texture: lazerTexture)
        beam.size = CGSize(width: cellSize * (10/1), height: cellSize * (2/3))

        // put lazer in the middle as default
        currentBeamRow = gridSize / 2
        // Calculate the y position for all elements
        let yPosition = gridOrigin.y + (CGFloat(currentBeamRow) * cellSize) + (cellSize / 2)

        // Position all elements on the correct x coordinate
        let leftXPosition = gridOrigin.x + leftNode.size.width / 2
        leftNode.position = CGPoint(x: leftXPosition, y: yPosition)

        let rightXPosition = gridOrigin.x + CGFloat(gridSize) * cellSize - rightNode.size.width / 2
        rightNode.position = CGPoint(x: rightXPosition, y: yPosition)
      
        beam.position = CGPoint(x: leftXPosition, y: yPosition)
        isActive = false
        self.lastStarted = TimeInterval()
        // load beam first, then lazer for sprites to not be busted, this is debug
//        self.scene?.addChild(beam)
//        self.scene?.addChild(rightNode)
//        self.scene?.addChild(leftNode)
//        placeNewLazerBeam()

    }
    // MARK: - Placement and Updating
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
        if((rightNode.parent == nil) && (leftNode.parent == nil)) {
            self.scene?.addChild(rightNode)
            self.scene?.addChild(leftNode)
        }

        isActive = true
        lastStarted = currentTime
        print("LazerManager: placeNewLazerBeam: \(randomRow), \(currentTime)")

    }
    private func moveLazerBeamSet(targetRow: Int) {
        // targetRow = 0-4
        // Ensure the targetRow is within the valid grid bounds
        guard targetRow >= 0 && targetRow < gridSize else {
            print("Target row is out of bounds.")
            return
        }

        currentBeamRow = targetRow
        
        // Calculate the new y position for all elements
        let newYPosition = gridOrigin.y + (CGFloat(currentBeamRow) * cellSize) + (cellSize / 2)

        // Create move actions
        let moveLeftNubAction = SKAction.moveTo(y: newYPosition, duration: 0.2) // Adjust duration as needed
        let moveRightNubAction = SKAction.moveTo(y: newYPosition, duration: 0.2)
        let moveBeamAction = SKAction.moveTo(y: newYPosition, duration: 0.2)
        
        
        // Despawn lazer while its moving:
        beam.removeFromParent()
        beam.position = CGPoint(x: gridOrigin.x + leftNode.size.width / 2, y: newYPosition)
        
        // move nubs
        leftNode.run(moveLeftNubAction)
        rightNode.run(moveRightNubAction)
    }
    
    func update(currentTime: TimeInterval, playerManager: PlayerManager, currentLevel: Int) -> Bool {
        let isPlayerHit = false
        let elapsedTime = currentTime - lastStarted


        if (isActive) {
            if elapsedTime >= lazerBeamFullDuration {
                isActive.toggle()
                beam.removeFromParent()
            } else if (elapsedTime > (8/12) * lazerBeamFullDuration ) {
                // killing
                // needs to be fixed bcuz it will always bring the lazer back even if we move..
                if beam.intersects(playerManager.playerNode) {
                    return true
                }
                
            } else if (elapsedTime >= (6/12) * lazerBeamFullDuration) && (elapsedTime <= (8/12) * lazerBeamFullDuration) {
                if (beam.parent == nil) {
                    scene?.addChild(beam)
                }
            }
            else {
                if elapsedTime.truncatingRemainder(dividingBy: 1.0) < 0.5 {
                    leftNode.texture = SKTexture(imageNamed: "NoHitManiaNub1")
                    rightNode.texture = SKTexture(imageNamed: "NoHitManiaNub1")
                }
                else {
                    leftNode.texture = SKTexture(imageNamed: "NoHitManiaNub4")
                    rightNode.texture = SKTexture(imageNamed: "NoHitManiaNub4")

                }
            }
        }
        return isPlayerHit
        
    }

    
    // MARK: - RestartGame
    public func clearAllLazers() {
        leftNode.removeFromParent()
        rightNode.removeFromParent()
        beam.removeFromParent()
    }
}
