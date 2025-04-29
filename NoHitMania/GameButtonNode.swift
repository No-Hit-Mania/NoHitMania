import SpriteKit

class GameButtonNode: SKSpriteNode {
    var normalBtn: SKTexture
    var pressedBtn: SKTexture
    var action: (() -> Void)?

    init(normalImageNamed: String, pressedImageNamed: String) {
        self.normalBtn = SKTexture(imageNamed: normalImageNamed)
        self.pressedBtn = SKTexture(imageNamed: pressedImageNamed)
        super.init(texture: normalBtn, color: .clear, size: normalBtn.size())
        isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        texture = pressedBtn
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        texture = normalBtn
        action?()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        texture = normalTexture
    }
}