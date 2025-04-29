//
//  MainMenuScene.swift
//  NoHitMania
//
//  Created by Jason Kim on 4/20/25.
//


import SpriteKit

class MainMenuScene: SKScene {

    override func didMove(to view: SKView) {
        backgroundColor = .black
        setupTitle()
        setupButtons()
        setupStickman()
        MusicManager.shared.playMusic(named: "MenuTheme")
    }

    private func setupTitle() {
        let titleNode = SKSpriteNode(imageNamed: "GameTitle")
        titleNode.position = CGPoint(x: size.width / 2, y: size.height * 0.8)
        titleNode.setScale(0.6)
        addChild(titleNode)
    }

    private func setupButtons() {
        let buttonNames = [
            ("PlayButton", "PlayButtonPressed"),
            ("ShopButton", "ShopButtonPressed"),
            ("SettingsButton", "SettingsButtonPressed")
        ]

        let spacing: CGFloat = 20
        let totalHeight = CGFloat(buttonNames.count) * 80 + spacing * CGFloat(buttonNames.count - 1)
        let startY = size.height / 2 + totalHeight / 2 - 40

        for (index, (normal, pressed)) in buttonNames.enumerated() {
            let button = GameButtonNode(normalImageNamed: normal, pressedImageNamed: pressed)
            button.setScale(0.5)

            button.position = CGPoint(
                x: size.width / 2,
                y: startY - CGFloat(index) * (80 + spacing)
            )

            button.action = {
                switch index {
                case 0:
                    print("Play button tapped")
                case 1:
                    print("Shop button tapped")
                case 2:
                    print("Settings button tapped")
                default:
                    break
                }
            }

            addChild(button)
        }
    }

    private func setupStickman() {
        let stickman = SKSpriteNode(imageNamed: "StickmanIdle")
        stickman.name = "stickman"
        stickman.position = CGPoint(x: size.width / 2, y: size.height * 0.1)
        stickman.setScale(0.5)
        addChild(stickman)
    }

    // No audio logic for stickman or button taps
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)

        for node in nodesAtPoint {
            if node.name == "stickman" {
                print("Stickman tapped")
                // Add visuals or animation if needed
            }
        }
    }
    
    

    
}
