//
//  ZapCell.swift
//  NoHitMania
//
//  Created on 4/24/25.
//

import Foundation
import SpriteKit

class ZapCell {
    // Cell position
    let row: Int
    let col: Int
    
    // Timing information
    var nextActivationTime: TimeInterval
    private let warningDuration: TimeInterval = 1.5  // Duration of warning phase
    
    // Initialize with a position and random activation time
    init(row: Int, col: Int) {
        self.row = row
        self.col = col
        
        // Set activation time between 2 and 4 seconds from now
        let randomDelay = Double.random(in: 2.0...4.0)
        self.nextActivationTime = CACurrentMediaTime() + randomDelay
    }
    
    // Initialize with specific activation time
    init(row: Int, col: Int, nextActivationTime: TimeInterval) {
        self.row = row
        self.col = col
        self.nextActivationTime = nextActivationTime
    }
    
    // Calculate warning intensity (0.0 to 1.0) based on time until activation
    func warningIntensity(currentTime: TimeInterval) -> Float {
        let timeUntilActivation = nextActivationTime - currentTime
        
        // If it's not yet warning time or past activation time, intensity is 0
        if timeUntilActivation <= 0 || timeUntilActivation > warningDuration {
            return 0.0
        }
        
        // Return intensity from 0.0 to 1.0 (higher when closer to activation)
        return Float(1.0 - (timeUntilActivation / warningDuration))
    }
    
    // Schedule the next activation (if we're not doing one-time use)
    func scheduleNextActivation(currentTime: TimeInterval) {
        // For one-time use cells, this would not be called
        // But if we change to reusable cells, set next activation 3-6 seconds from now
        let randomDelay = Double.random(in: 3.0...6.0)
        self.nextActivationTime = currentTime + randomDelay
    }
}
