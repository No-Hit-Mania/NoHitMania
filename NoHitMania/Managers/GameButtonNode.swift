//
//  GameButtonNode.swift
//  NoHitMania
//
//  Created by Jason Kim on 4/22/25.
//


import SpriteKit

class GameButtonNode: SKSpriteNode {
    private let normalTexture: SKTexture
    private let pressedTexture: SKTexture
    var action: (() -> Void)?

    init(normalImageNamed: String, pressedImageNamed: String) {
        self.normalTexture = SKTexture(imageNamed: normalImageNamed)
        self.pressedTexture = SKTexture(imageNamed: pressedImageNamed)

        super.init(texture: normalTexture, color: .clear, size: normalTexture.size())
        isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        texture = pressedTexture
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        texture = normalTexture
        if let touch = touches.first {
            let location = touch.location(in: self)
            if self.contains(location) {
                action?()
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        texture = normalTexture
    }
}
