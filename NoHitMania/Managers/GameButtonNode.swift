//
//  GameButtonNode.swift
//  NoHitMania
//
//  Created by Jason Kim on 4/22/25.
//


import SpriteKit

class GameButtonNode: SKSpriteNode {
    private let normal: SKTexture
    private let pressed: SKTexture
    var action: (() -> Void)?

    init(normalImageNamed: String, pressedImageNamed: String) {
        self.normal = SKTexture(imageNamed: normalImageNamed)
        self.pressed = SKTexture(imageNamed: pressedImageNamed)

        super.init(texture: normal, color: .clear, size: normal.size())
        isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        texture = pressed
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        texture = normal
        if let touch = touches.first {
            let location = touch.location(in: self)
            if self.contains(location) {
                action?()
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        texture = normal
    }
}
