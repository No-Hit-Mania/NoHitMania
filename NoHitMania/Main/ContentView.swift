//
//  ContentView.swift
//  NoHitMania
//

import SwiftUI
import SpriteKit

class SceneCoordinator: ObservableObject {
    @Published var currentScene: SKScene

    init() {
        let menu = MainMenuScene()
        menu.size = UIScreen.main.bounds.size
        menu.scaleMode = .fill
        self.currentScene = menu
    }

    func transitionToGameScene() {
        let gameScene = GameScene()
        gameScene.size = UIScreen.main.bounds.size
        gameScene.scaleMode = .fill
        self.currentScene = gameScene
    }

    func loadMainMenu() {
        let menuScene = MainMenuScene()
        menuScene.size = UIScreen.main.bounds.size
        menuScene.scaleMode = .fill
        self.currentScene = menuScene
    }
}

struct ContentView: View {
    @StateObject private var coordinator = SceneCoordinator()

    var body: some View {
        SpriteView(scene: coordinator.currentScene)
            .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}

