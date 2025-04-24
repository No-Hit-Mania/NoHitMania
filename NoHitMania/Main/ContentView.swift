//
//  ContentView.swift
//  NoHitMania
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    var scene: SKScene {
        let scene = OptionsScene()
        scene.size = CGSize(width: 300, height: 300)
        let scene = GameScene()
        scene.size = UIScreen.main.bounds.size
        scene.scaleMode = .fill
        return scene
    }
    
    var body: some View {
        VStack {
            SpriteView(scene: scene)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    ContentView()
}
