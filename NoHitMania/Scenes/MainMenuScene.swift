//
//  MainMenuScene.swift
//  NoHitMania
//
//  Created by Jason Kim on 4/20/25.
//


import SpriteKit
import AVFoundation

class MainMenuScene: SKScene {

    override func didMove(to view: SKView) {
        backgroundColor = .clear

        MusicManager.shared.playMusic(named: "MainMenuTheme")

        addTitle()
        addButtons()
        addStickman()
    }

    private func addTitle() {
        let title = SKSpriteNode(imageNamed: "GameTitle")
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.85)

        // Scale the title based on screen width
        let desiredWidth = size.width * 0.7
        let originalWidth = title.texture?.size().width ?? 1
        let scale = desiredWidth / originalWidth
        title.setScale(scale)

        addChild(title)
    }

    private func addButtons() {
        let buttonInfo: [(String, String, String)] = [
            ("PlayButton", "PlayButtonPressed", "Play"),
            ("ShopButton", "ShopButtonPressed", "Shop"),
            ("SettingsButton", "SettingsButtonPressed", "Settings")
        ]

        let desiredWidth = size.width * 0.5
        let spacing = desiredWidth * 0.4 // vertical space between buttons

        for (index, info) in buttonInfo.enumerated() {
            let button = GameButtonNode(normalImageNamed: info.0, pressedImageNamed: info.1)

            // Scale the button based on screen size
            let originalWidth = button.texture?.size().width ?? 1
            let scale = desiredWidth / originalWidth
            button.setScale(scale)

            // Position the button
            button.position = CGPoint(
                x: size.width / 2,
                y: size.height * 0.55 - CGFloat(index) * spacing
            )

            button.action = {
                self.run(SKAction.playSoundFileNamed("Click.wav", waitForCompletion: false))
                print("\(info.2) button pressed")
                // TODO: Add scene transitions here
            }

            addChild(button)
        }
    }

    private func addStickman() {
        let stickman = SKSpriteNode(imageNamed: "StickmanIdle1")
        stickman.name = "Stickman"
        stickman.position = CGPoint(x: size.width / 2, y: size.height * 0.15)

        // Scale the stickman based on screen width
        let desiredWidth = size.width * 0.3
        let originalWidth = stickman.texture?.size().width ?? 1
        let scale = desiredWidth / originalWidth
        stickman.setScale(scale)

        addChild(stickman)

        // Idle animation
        var frames: [SKTexture] = []
        for i in 1...3 {
            frames.append(SKTexture(imageNamed: "StickmanIdle\(i)"))
        }

        let idleAnimation = SKAction.repeatForever(
            SKAction.animate(with: frames, timePerFrame: 0.2)
        )
        stickman.run(idleAnimation)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let node = atPoint(location)

        if node.name == "Stickman" {
            run(SKAction.playSoundFileNamed("StickmanSound.wav", waitForCompletion: false))
            print("Stickman tapped!")
        }
    }
}
