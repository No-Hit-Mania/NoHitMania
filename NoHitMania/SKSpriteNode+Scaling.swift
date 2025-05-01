//
//  SKSpriteNode+Scaling.swift
//  NoHitMania
//
//  Created by Jason Kim on 5/1/25.
//


import SpriteKit

extension SKSpriteNode {
    /// Scales the sprite to match a specific width while keeping aspect ratio.
    func resizeToFit(width targetWidth: CGFloat) {
        let scale = targetWidth / self.size.width
        self.setScale(scale)
    }

    /// Scales the sprite to match a specific height while keeping aspect ratio.
    func resizeToFit(height targetHeight: CGFloat) {
        let scale = targetHeight / self.size.height
        self.setScale(scale)
    }
}
