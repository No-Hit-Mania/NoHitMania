//
//  Constants.swift
//  NoHitMania
//
//  Created on 4/24/25.
//

import Foundation
import UIKit

struct GameConstants {
    // Game configuration
    static let defaultGridSize = 5
    static let maxLevel = 5
    static let secondsBetweenLevels = 5
    
    // Player settings
    static let playerDefaultPosition = GridPosition(x: 2, y: 2)
    static let playerCellSizeRatio: CGFloat = 0.8
    
    // Zap cell settings
    static let zapCellInitialActivationRange: ClosedRange<TimeInterval> = 2...4
    static let zapCellActivationRange: ClosedRange<TimeInterval> = 3...6
    static let zapCellWarningDuration: TimeInterval = 1.0
    
    // UI settings
    static let minSwipeDistance: CGFloat = 20.0
    
    // Audio files
    struct Audio {
        static let gameMusic = "gameMusicLoopable.mp3"
        static let pauseMusic = "pauseMusic.mp3"
        static let playerDeathSound = "playerDeath.mp3"  // Example, add if you have this
    }
    
    // Colors
    struct Colors {
        static let gridCellDefault = UIColor.systemPink
        static let zapCellDefault = UIColor.yellow
        static let zapCellWarning = UIColor.systemBlue
        static let zapCellActive = UIColor.white
    }
}
