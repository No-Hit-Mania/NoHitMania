//
//  MainMenuScene.swift
//  NoHitMania
//
//  Created by Cristobal Elizarraraz on 4/29/25.
//


//
//  MainMenuScene.swift
//  NoHitMania
//
//  Created by Jason Kim on 4/20/25.
//


import SpriteKit

class MainMenuScene: SKScene {

    override func didMove(to view: SKView) {
        backgroundColor = .lightGray
        print("MainMenuScene: didMoveToView")

        setupTitle()
        setupButtons()
        setupStickman()

        // Play background music
        AudioManager.shared.changeMusic(to: .mainMenu, in: self)

        // Start flicker and jitter effects
        startFlickerAndJitterEffect()
    }

    private func setupTitle() {
        let titleNode = SKSpriteNode(imageNamed: "GameTitle")
        titleNode.position = CGPoint(x: size.width / 2, y: size.height * 0.8)
        titleNode.resizeToFit(width: size.width * 0.7)
        titleNode.zPosition = 1
        addChild(titleNode)
    }

    private func setupButtons() {
        let buttonNames = [
            ("PlayButton", "PlayButtonPressed"),
            ("ShopButton", "ShopButtonPressed"),
            ("SettingsButton", "SettingsButtonPressed")
        ]

        let spacing: CGFloat = 20
        let buttonHeight = size.height * 0.08
        let totalHeight = CGFloat(buttonNames.count) * buttonHeight + spacing * CGFloat(buttonNames.count - 1)
        let startY = size.height / 2 + totalHeight / 2 - (buttonHeight / 2)

        for (index, (normal, pressed)) in buttonNames.enumerated() {
            let button = GameButtonNode(normalImageNamed: normal, pressedImageNamed: pressed)
            button.resizeToFit(height: buttonHeight)

            button.position = CGPoint(
                x: size.width / 2,
                y: startY - CGFloat(index) * (buttonHeight + spacing)
            )

            button.action = {
                switch index {
                case 0:
                    print("Play button tapped")
                    // Transition to GameScene
                    self.transitionToGameScene()
                case 1:
                    print("Shop button tapped")
                case 2:
                    print("Settings button tapped")
                    let modal = OptionsScene(size: self.size, isMainMenu: true)
                    modal.zPosition = 10
                    modal.onQuit = { [weak self] in
                        if let view = self?.view {
                            let gameScene = MainMenuScene(size: view.bounds.size)
                            let transition = SKTransition.fade(withDuration: 0.5) // You can change the transition type and duration here
                            view.presentScene(gameScene, transition: transition)
                        }
                    }
                    modal.name = "optionsModal"
                    self.addChild(modal)

                default:
                    break
                }
            }

            addChild(button)
        }
    }

    private func setupStickman() {
        let stickman = SKSpriteNode(imageNamed: "Stickman")
        stickman.name = "Stickman"
        stickman.position = CGPoint(x: size.width / 2, y: size.height * 0.1)
        stickman.resizeToFit(width: size.width * 0.2)
        stickman.zPosition = 2
        addChild(stickman)
    }

    private func startFlickerAndJitterEffect() {
        // Iterate through all buttons to apply flicker and jitter effect
        for button in children.compactMap({ $0 as? GameButtonNode }) {
            
            // Flicker effect (opacity change)
            let flickerAction = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.7, duration: 0.05),
                SKAction.fadeAlpha(to: 1.0, duration: 0.05)
            ])
            let repeatFlicker = SKAction.repeatForever(flickerAction)
            button.run(repeatFlicker)

            // Jitter effect (random small movement)
            let jitterAction = SKAction.sequence([
                SKAction.moveBy(x: CGFloat.random(in: -5...5), y: CGFloat.random(in: -5...5), duration: 0.05),
                SKAction.move(to: button.position, duration: 0.05) // Reset to original position
            ])
            let repeatJitter = SKAction.repeatForever(jitterAction)
            button.run(repeatJitter)
        }
    }

    // Method to handle scene transition to GameScene
    private func transitionToGameScene() {
        if let view = self.view {
            let gameScene = GameScene(size: view.bounds.size)
            let transition = SKTransition.fade(withDuration: 0.5) // You can change the transition type and duration here
            view.presentScene(gameScene, transition: transition)
        }
    }
    
    private func transitionToPC() {
        if let view = self.view {
            let gameScene = PlayerCustomization(size: view.bounds.size)
            let transition = SKTransition.fade(withDuration: 0.5) // You can change the transition type and duration here
            view.presentScene(gameScene, transition: transition)
        }
        
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)

        for node in nodesAtPoint {
            if node.name == "Stickman" {
                print("Stickman tapped")
                self.transitionToPC()
                // Add animation or reaction
            }
        }
    }
    

    
}

