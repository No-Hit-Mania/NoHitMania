//
//  OptionsScene.swift
//  NoHitMania
//
//  Created by Cristobal Elizarraraz on 4/22/25.
//

import SpriteKit

class OptionsScene: SKNode {
    private var slider1Handle: SKShapeNode!
    private var slider2Handle: SKShapeNode!
    private var activeSlider: SKShapeNode?
    private var slider1ValueLabel: SKLabelNode!
    private var slider2ValueLabel: SKLabelNode!
    private var modalPanel: SKShapeNode!
    private var closeButton: SKLabelNode!
    private var quitButton: SKLabelNode!
    
    private var isMainMenu: Bool
    
    var onQuit: (() -> Void)?
    
    init(size: CGSize, isMainMenu: Bool = false) {
        self.isMainMenu = isMainMenu
        super.init()
        self.isUserInteractionEnabled = true
        setupModal(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupModal(size: CGSize) {
        let dim = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        dim.fillColor = SKColor.black.withAlphaComponent(0.5)
        dim.position = CGPoint(x: size.width / 2, y: size.height / 2)
        dim.zPosition = 0
        addChild(dim)
        
        let panelSize = CGSize(width: size.width * 0.8, height: size.height * 0.7)
        modalPanel = SKShapeNode(rectOf: panelSize, cornerRadius: 20)
        modalPanel.fillColor = .white
        modalPanel.strokeColor = .gray
        modalPanel.lineWidth = 4
        modalPanel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        modalPanel.zPosition = 1
        addChild(modalPanel)
        
        let title = SKLabelNode(text: "Settings")
        title.fontSize = 50
        title.fontColor = .black
        title.fontName = "HelveticaNeue-Bold"
        title.position = CGPoint(x: 0, y: panelSize.height / 2 - 80)
        modalPanel.addChild(title)
        
        addSliderTitle("Music", valueLabel: &slider1ValueLabel, y: 80)
        createSlider(y: 40, name: "slider1", value: AudioManager.shared.getMusicVolume())
        
        addSliderTitle("Sound Effects", valueLabel: &slider2ValueLabel, y: -80)
        createSlider(y: -120, name: "slider2", value: AudioManager.shared.getEffectsVolume())
        
        closeButton = SKLabelNode(text: "Close")
        closeButton.fontSize = 30
        closeButton.fontColor = .orange
        closeButton.fontName = "HelveticaNeue-Bold"
        closeButton.position = CGPoint(x: 0, y: -panelSize.height / 2 + 75)
        closeButton.name = "closeButton"
        modalPanel.addChild(closeButton)
        
        quitButton = SKLabelNode(text: "Quit")
        quitButton.fontSize = 30
        quitButton.fontColor = .red
        quitButton.fontName = "HelveticaNeue-Bold"
        quitButton.position = CGPoint(x: 0, y: -panelSize.height / 2 + 40)
        quitButton.name = "quitButton"

        if isMainMenu == false {
            modalPanel.addChild(quitButton)
        }
    }

    func addSliderTitle(_ text: String, valueLabel: inout SKLabelNode!, y: CGFloat) {
        let titleLabel = SKLabelNode(text: text)
        titleLabel.fontSize = 30
        titleLabel.fontColor = .black
        titleLabel.fontName = "HelveticaNeue"
        titleLabel.horizontalAlignmentMode = .left
        titleLabel.position = CGPoint(x: -150, y: y)
        modalPanel.addChild(titleLabel)

        valueLabel = SKLabelNode(text: "50")
        valueLabel.fontSize = 30
        valueLabel.fontColor = .black
        valueLabel.fontName = "HelveticaNeue"
        valueLabel.horizontalAlignmentMode = .right
        valueLabel.position = CGPoint(x: 150, y: y)
        modalPanel.addChild(valueLabel)
    }

    func createSlider(y: CGFloat, name: String, value: Float) {
        let track = SKShapeNode(rectOf: CGSize(width: 300, height: 10), cornerRadius: 5)
        track.fillColor = .blue
        track.position = CGPoint(x: 0, y: y)
        track.name = "\(name)_track"
        modalPanel.addChild(track)

        let handle = SKShapeNode(circleOfRadius: 12)
        handle.fillColor = .black
        let x = CGFloat(value) * 300 - 150
        handle.position = CGPoint(x: x, y: y)
        handle.name = name
        modalPanel.addChild(handle)

        let percentage = Int(value * 100)
        if name == "slider1" {
            slider1Handle = handle
            slider1ValueLabel.text = "\(percentage)"
        } else {
            slider2Handle = handle
            slider2ValueLabel.text = "\(percentage)"
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: modalPanel)

        if let node = modalPanel.atPoint(location) as? SKShapeNode {
            if node == slider1Handle {
                activeSlider = slider1Handle
            } else if node == slider2Handle {
                activeSlider = slider2Handle
            }
        }

        if let label = modalPanel.atPoint(location) as? SKLabelNode {
            if label.name == "closeButton" {
                (self.scene as? GameScene)?.resumeGame()
                self.removeFromParent()
            } else if label.name == "quitButton" {
                self.onQuit?()
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let handle = activeSlider else { return }
        let location = touch.location(in: modalPanel)

        let minX: CGFloat = -150
        let maxX: CGFloat = 150
        let clampedX = min(max(location.x, minX), maxX)
        handle.position.x = clampedX

        let percentage = Int(((clampedX - minX) / (maxX - minX)) * 100)
        let volumeValue = Float(percentage) / 100.0

        if handle == slider1Handle {
            slider1ValueLabel.text = "\(percentage)"
            AudioManager.shared.setMusicVolume(volumeValue)
        } else if handle == slider2Handle {
            slider2ValueLabel.text = "\(percentage)"
            AudioManager.shared.setEffectsVolume(volumeValue)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeSlider = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeSlider = nil
    }
}
