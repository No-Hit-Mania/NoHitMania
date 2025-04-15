//
//  ContentView.swift
//  NoHitMania
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    @State var direction: String = "Swipe to move the box"
    
    var scene: SKScene {
        let scene = GameScene()
        scene.size = CGSize(width: 300, height: 300)
        scene.scaleMode = .fill
        scene.getDirectionCallback = { newDirection in
            direction = newDirection
        }
        return scene
    }
    
    var body: some View {
        VStack {
            Text(direction)
                .font(.headline)
                .padding()
            
            SpriteView(scene: scene)
                .frame(width: 300, height: 300)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    ContentView()
}
