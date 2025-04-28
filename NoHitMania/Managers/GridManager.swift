//
//  GridManager.swift
//  NoHitMania
//
//  Created on 4/24/25.
//

import SpriteKit

class GridManager {
    // Grid configuration
    private let gridSize: Int
    private var cellSize: CGFloat
    private var gridOrigin: CGPoint
    
    // Reference to the scene
    private weak var scene: SKScene?
    
    // Initialize with scene and grid parameters
    init(scene: SKScene, gridSize: Int) {
        self.scene = scene
        self.gridSize = gridSize
        
        // Default values that will be recalculated in setupGrid
        self.cellSize = 0
        self.gridOrigin = .zero
    }
    
    // Set up the grid based on the scene size
    func setupGrid() -> (cellSize: CGFloat, gridOrigin: CGPoint) {
        guard let scene = scene else { return (0, .zero) }
        
        // Calculate cell size based on scene size
        cellSize = min(scene.size.width, scene.size.height) / CGFloat(gridSize)
        
        // Calculate grid origin (top-left corner)
        gridOrigin = CGPoint(
            x: (scene.size.width - (CGFloat(gridSize) * cellSize)) / 2,
            y: (scene.size.height - (CGFloat(gridSize) * cellSize)) / 2
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
                scene.addChild(cell)
            }
        }
        
        return (cellSize, gridOrigin)
    }
    
    // Get the cell at a specific grid position
    func getCell(at position: GridPosition) -> SKShapeNode? {
        guard let scene = scene else { return nil }
        return scene.childNode(withName: "cell_\(position.y)_\(position.x)") as? SKShapeNode
    }
    
    // Change a cell's color
    func setCellColor(row: Int, col: Int, color: UIColor) {
        guard let scene = scene else { return }
        if let cell = scene.childNode(withName: "cell_\(row)_\(col)") as? SKShapeNode {
            cell.fillColor = color
        }
    }
    
    // Get the grid size
    func getGridSize() -> Int {
        return gridSize
    }
    
    // Get the cell size
    func getCellSize() -> CGFloat {
        return cellSize
    }
    
    // Get the grid origin point
    func getGridOrigin() -> CGPoint {
        return gridOrigin
    }
}
