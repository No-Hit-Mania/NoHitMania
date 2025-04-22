//
//  NoHitManiaApp.swift
//  NoHitMania
//
//  Created by Christian Barajas on 4/15/25.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    @State var direction: String = "Swipe to move the box"
    @State var alive: Bool = true
    @State var elapsedTime: TimeInterval = 0.0
    @State var startTime: Date? = nil
    @State var currentLevel: Int = 1
    private let timer = Timer.publish(every: 1.0/60.0, on: .main, in: .common).autoconnect()
    
    func formattedTime(elapsed: TimeInterval) -> String {
        let totalSeconds = Int(elapsed)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        // Calculate the hundredths part from the fractional seconds
        let hundredths = Int((elapsed - Double(totalSeconds)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, hundredths)
    }
    
    var scene: SKScene {
        let scene = GameScene()
        scene.size = CGSize(width: 300, height: 300)
        scene.scaleMode = .fill
        scene.getDirectionCallback = { newDirection in
            direction = newDirection
        }
        return scene
    }
    
    var body: some View {
        VStack {
            Text(direction)
                .font(.headline)
                .padding()
            
            SpriteView(scene: scene)
                .frame(width: 300, height: 300)
                .ignoresSafeArea()
        }
        .onAppear {
            // Capture the starting time when the view appears.
            startTime = Date()
        }
        .onReceive(timer) { _ in
            // If "alive" becomes false, stop the timer.
            if !alive {
                timer.upstream.connect().cancel()
            }
            // Update the elapsed time based on the start time.
            if let start = startTime {
                elapsedTime = Date().timeIntervalSince(start)
            }
            // Update the displayed text with the formatted elapsed time.
            direction = formattedTime(elapsed: elapsedTime)
        }
    }
}

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
    
    struct GridPosition {
        var x: Int
        var y: Int
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        setupGrid()
        createPlayer()
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
                addChild(cell)
            }
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

#Preview {
    ContentView()
}
