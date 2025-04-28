//
//  OptionsScene.swift
//  NoHitMania
//
//  Created by Cristobal Elizarraraz on 4/22/25.
//

import SpriteKit

class OptionsScene: SKScene {
    private var slider1Handle: SKShapeNode!
    private var slider2Handle: SKShapeNode!
    private var activeSlider: SKShapeNode?
    private var slider1ValueLabel: SKLabelNode!
    private var slider2ValueLabel: SKLabelNode!
    var getDirectionCallback: ((String) -> Void)?

    override func didMove(to view: SKView) {
        backgroundColor = .white

        // Title
        let title = SKLabelNode(text: "Settings")
        title.fontSize = 66
        title.fontColor = .black
        title.fontName = "HelveticaNeue-Bold"
        title.position = CGPoint(x: size.width / 2, y: size.height - 110)
        addChild(title)
        
        addSliderTitle("Music", valueLabel: &slider1ValueLabel, y: size.height * 0.68)
        createSlider(y: size.height * 0.63, name: "slider1")

        addSliderTitle("Sound Effects", valueLabel: &slider2ValueLabel, y: size.height * 0.48)
        createSlider(y: size.height * 0.43, name: "slider2")
    }
    func addSliderTitle(_ text: String, valueLabel: inout SKLabelNode!, y: CGFloat) {
            let titleLabel = SKLabelNode(text: text)
            titleLabel.fontSize = 35
            titleLabel.fontColor = .black
            titleLabel.fontName = "HelveticaNeue"
            titleLabel.horizontalAlignmentMode = .left
            titleLabel.position = CGPoint(x: size.width / 2 - 180, y: y)
            addChild(titleLabel)

            valueLabel = SKLabelNode(text: "50")
            valueLabel.fontSize = 35
            valueLabel.fontColor = .black
            valueLabel.fontName = "HelveticaNeue"
            valueLabel.horizontalAlignmentMode = .right
            valueLabel.position = CGPoint(x: size.width / 2 + 180, y: y)
            addChild(valueLabel)
        }

    func createSlider(y: CGFloat, name: String) {
        let track = SKShapeNode(rectOf: CGSize(width: 370, height: 12), cornerRadius: 6)
        track.fillColor = .blue
        track.position = CGPoint(x: size.width / 2, y: y)
        track.name = "\(name)_track"
        addChild(track)

        let handle = SKShapeNode(circleOfRadius: 10)
        handle.fillColor = .black
        handle.position = CGPoint(x: track.position.x, y: y)
        handle.name = name
        addChild(handle)

        if name == "slider1" {
            slider1Handle = handle
        } else {
            slider2Handle = handle
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            if slider1Handle.contains(location) {
                activeSlider = slider1Handle
            } else if slider2Handle.contains(location) {
                activeSlider = slider2Handle
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let handle = activeSlider else { return }
        let location = touch.location(in: self)

        let minX = size.width / 2 - 125
        let maxX = size.width / 2 + 125
        let clampedX = min(max(location.x, minX), maxX)

        handle.position.x = clampedX

        // Update value label
        let percentage = Int(((clampedX - minX) / (maxX - minX)) * 100)
        if handle == slider1Handle {
            slider1ValueLabel.text = "\(percentage)"
        } else if handle == slider2Handle {
            slider2ValueLabel.text = "\(percentage)"
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeSlider = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeSlider = nil
    }
}
