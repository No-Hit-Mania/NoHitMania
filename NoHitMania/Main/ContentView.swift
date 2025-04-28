//
//  ContentView.swift
//  NoHitMania
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    @State var scene: SKScene = SceneSetup()

    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    ContentView()
}

func SceneSetup() -> SKScene {
    let scene = GameScene()
//        scene.size = CGSize(width: 300, height: 300)
//        let scene = GameScene()
    scene.size = UIScreen.main.bounds.size
    scene.scaleMode = .fill
    return scene
}
