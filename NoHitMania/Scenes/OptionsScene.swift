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
    var getDirectionCallback: ((String) -> Void)?

    override func didMove(to view: SKView) {
        backgroundColor = .darkGray

        // Title
        let title = SKLabelNode(text: "Settings")
        title.fontSize = 36
        title.fontName = "AvenirNext-Bold"
        title.position = CGPoint(x: size.width / 2, y: size.height - 80)
        addChild(title)

        createSlider(y: size.height / 2 + 40, name: "slider1")
        createSlider(y: size.height / 2 - 40, name: "slider2")
    }

    func createSlider(y: CGFloat, name: String) {
        let track = SKShapeNode(rectOf: CGSize(width: 200, height: 10), cornerRadius: 5)
        track.fillColor = .white
        track.position = CGPoint(x: size.width / 2, y: y)
        track.name = "\(name)_track"
        addChild(track)

        let handle = SKShapeNode(circleOfRadius: 15)
        handle.fillColor = .blue
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

        // Clamp handle movement within slider track
        let minX = size.width / 2 - 100
        let maxX = size.width / 2 + 100
        let clampedX = min(max(location.x, minX), maxX)

        handle.position.x = clampedX
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeSlider = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeSlider = nil
    }
}

