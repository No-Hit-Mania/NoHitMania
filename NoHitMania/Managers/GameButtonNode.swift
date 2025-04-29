<<<<<<< HEAD:NoHitMania/Managers/GameButtonNode.swift
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
=======
import SpriteKit

class GameButtonNode: SKSpriteNode {
    var normalBtn: SKTexture
    var pressedBtn: SKTexture
    var action: (() -> Void)?

    init(normalImageNamed: String, pressedImageNamed: String) {
        self.normalBtn = SKTexture(imageNamed: normalImageNamed)
        self.pressedBtn = SKTexture(imageNamed: pressedImageNamed)
        super.init(texture: normalBtn, color: .clear, size: normalBtn.size())
>>>>>>> main:NoHitMania/GameButtonNode.swift
        isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
<<<<<<< HEAD:NoHitMania/Managers/GameButtonNode.swift
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
=======
        texture = pressedBtn
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        texture = normalBtn
        action?()
>>>>>>> main:NoHitMania/GameButtonNode.swift
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        texture = normal
    }
}
