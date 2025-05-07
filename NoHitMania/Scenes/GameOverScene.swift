//
//  GameOverScene.swift
//  NoHitMania
//
//  Created by Dylan Uribe on 5/6/25.
//
import SpriteKit

class GameOverScene: SKScene {
    private var playerManager: PlayerManager!
    // TODO: figure out if this is needed or not based on how customization works
    private var playerNode: SKSpriteNode!
    
    private var gameOverText: SKSpriteNode!
    private var scoreTimerLabel: SKLabelNode!

    
    // Touch interactions
    private var startTouchPosition: CGPoint?
    
    var scoreTime: TimeInterval = 0.0
    
    init(size: CGSize, scoreTime: TimeInterval, playerManager: PlayerManager) {
        self.playerManager = playerManager
        self.scoreTime = scoreTime
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        // call any set up functions
        backgroundColor = SKColor.lightGray
        setUpScore()
        setUpButtons()
        setUpGameOver()
        setUpPlayer()
    }
    
    private func setUpScore() {
        let scoreLabel = SKLabelNode(text: "Time: \(GameTimerManager().formattedTime(elapsed: scoreTime))")
        scoreLabel.position = CGPoint(x: size.width / 2, y: 300)
        scoreLabel.fontSize = 40
        scoreLabel.fontName = "Helvetica-Bold"
        addChild(scoreLabel)
    }

    private func setUpButtons() {
        let buttonInfo = [
            // TODO: change this to main menu with proper assests
            ("ShopButton", "ShopButtonPressed", {
                print("GameOver: Main menu pressed")
                if let view = self.view {
                    let mainMenuScene = MainMenuScene(size: view.bounds.size)
                    let transition = SKTransition.fade(withDuration: 0.5)
                    view.presentScene(mainMenuScene, transition: transition)
                }
            }),
            // play again button
            ("PlayButton", "PlayButtonPressed", {
                print("GameOver: Play button tapped")
                if let view = self.view {
                    let gameScene = GameScene(size: view.bounds.size)
                    let transition = SKTransition.fade(withDuration: 0.5)
                    view.presentScene(gameScene, transition: transition)
                }
            }),
        ]

        let spacing: CGFloat = 20
        let buttonWidth = size.width * 0.4
        
        // how wide is all the buttons with the proper spacing between
        let totalWidth = CGFloat(buttonInfo.count) * buttonWidth + spacing * CGFloat(buttonInfo.count - 1)
        
        let startX = size.width / 2 - totalWidth / 2 + buttonWidth / 2
        let yPosition = size.height * 0.15

        // dawny type code
        for (index, (normal, pressed, actionBlock)) in buttonInfo.enumerated() {
            let button = GameButtonNode(normalImageNamed: normal, pressedImageNamed: pressed)
            button.resizeToFit(width: buttonWidth)
            button.position = CGPoint(x: startX + CGFloat(index) * (buttonWidth + spacing), y: yPosition)
            button.action = actionBlock
            addChild(button)
        }
    }
    private func setUpGameOver() {
        // TODO: Change to proper spirtes
        let titleNode = SKSpriteNode(imageNamed: "GameTitle")
        titleNode.position = CGPoint(x: size.width / 2, y: size.height * 0.8)
        titleNode.resizeToFit(width: size.width * 0.7)
        titleNode.zPosition = 1
        addChild(titleNode)
    }
    
    private func setUpPlayer() {
        playerManager.playerNode.removeFromParent()
        self.scene?.addChild(playerManager.playerNode)
        playerManager.playerDie()
    }

}
