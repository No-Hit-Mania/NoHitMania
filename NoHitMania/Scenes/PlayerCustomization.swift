//
//  PlayerCustomization.swift
//  NoHitMania
//
//  Created by Cristobal Elizarraraz on 4/29/25.
//

import SpriteKit

class PlayerCustomization: SKScene {
    
    // Example image names for each button (3x3 grid = 9 images per group)
    let headImages = (1...9).map { "head_\($0)" }
    let bodyImages = (1...9).map { "body_\($0)" }
    let deathImages = (1...9).map { "death_\($0)" }

    override func didMove(to view: SKView) {
        backgroundColor = .white

        let midX = size.width / 2
        let leftWidth = midX
        let rightWidth = midX

        let buttonSize = CGSize(width: 50, height: 50)
        let spacing: CGFloat = 10
        let gridWidth = 3 * buttonSize.width + 2 * spacing
        let gridHeight = 3 * buttonSize.height + 2 * spacing
        let titleHeight: CGFloat = 40
        let gridSectionHeight = titleHeight + gridHeight
        let totalGridsHeight = 3 * gridSectionHeight + 2 * spacing

        let startY = (size.height + totalGridsHeight) / 2 - buttonSize.height / 2

        let titles = ["Head", "Body", "Death Effects"]
        let imageGroups = [headImages, bodyImages, deathImages]
        addBackButton()
        //Adding background music
        AudioManager.shared.changeMusic(to: .pause, in: self)
        
        //creating 3x3 grids for player custimization assets
        for index in 0..<3 {
            let originX = (leftWidth - gridWidth) / 2
            let originY = startY - CGFloat(index) * (gridSectionHeight + spacing)

            addTitle(titles[index], at: CGPoint(x: originX + gridWidth / 2, y: originY - 10))
            create3x3Grid(
                at: CGPoint(x: originX, y: originY - titleHeight),
                buttonSize: buttonSize,
                spacing: spacing,
                imageNames: imageGroups[index],
                groupTag: index
            )
        }

        // player sprite
        let rightSprite = SKSpriteNode(imageNamed: "preview_image") // Replace with your image
        rightSprite.size = CGSize(width: 200, height: 200)
        rightSprite.position = CGPoint(x: midX + rightWidth / 2, y: size.height / 2)
        rightSprite.name = "preview"
        addChild(rightSprite)
    }
    
    private func addBackButton() {
        let texture = SKTexture(imageNamed: "back_icon")
        let pauseNode = SKSpriteNode(texture: texture)
        pauseNode.name = "backButton"
        pauseNode.size = CGSize(width: 50, height: 50)
        pauseNode.position = CGPoint(x: size.width / 10, y: size.height - 60)
        pauseNode.zPosition = 100
        addChild(pauseNode)
    }
    
    private func addTitle(_ text: String, at position: CGPoint) {
        let titleLabel = SKLabelNode(text: text)
        titleLabel.fontName = "Helvetica-Bold"
        titleLabel.fontSize = 28
        titleLabel.fontColor = .black
        titleLabel.position = position
        addChild(titleLabel)
    }

    private func create3x3Grid(at origin: CGPoint, buttonSize: CGSize, spacing: CGFloat, imageNames: [String], groupTag: Int) {
        for row in 0..<3 {
            for col in 0..<3 {
                let index = row * 3 + col
                guard index < imageNames.count else { continue }

                let x = origin.x + CGFloat(col) * (buttonSize.width + spacing)
                let y = origin.y - CGFloat(row) * (buttonSize.height + spacing)

                let imageName = imageNames[index]
                let button = SKSpriteNode(imageNamed: imageName)
                button.size = buttonSize
                button.position = CGPoint(x: x + buttonSize.width / 2, y: y - buttonSize.height / 2)
                button.name = "button_\(groupTag)_\(index)"
                addChild(button)
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let node = atPoint(location)
        if let name = node.name, name.starts(with: "button_") {
            print("Tapped \(name)")
            // You could update the right sprite image here based on the button tapped
        }else if node.name == "backButton" {
            let newScene = MainMenuScene(size: self.size)
            newScene.scaleMode = .aspectFill
            self.view?.presentScene(newScene, transition: .fade(withDuration: 0.5))
        }
    }
}
