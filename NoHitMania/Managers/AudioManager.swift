//
//  AudioManager.swift
//  NoHitMania
//
//  Created on 4/24/25.
//

import SpriteKit

class AudioManager {
    
    // Types of music available in the game
    enum MusicType: String {
        case game = "GameMusic.wav"
        case pause = "PauseMusic.mp3"
        case MainMenuScene = "MenuTheme.mp3"
        case none = ""
    }
    
    // Reference to the current background music node
    private weak var backgroundMusicNode: SKAudioNode?
    
    // Reference to the scene where audio nodes will be added
    private weak var scene: SKScene?
    
    // Initialize with the parent scene
    init(scene: SKScene) {
        self.scene = scene
    }
    
    // Set up initial background music
    func setupBackgroundMusic() {
        // Ensure music isn't already playing
        if backgroundMusicNode == nil, let scene = scene {
            let musicNode = SKAudioNode(fileNamed: MusicType.game.rawValue)
            musicNode.autoplayLooped = true
            musicNode.isPositional = false
            
            scene.addChild(musicNode)
            backgroundMusicNode = musicNode
            
            print("setupBackgroundMusic: done.")
        }
    }
    
    // Change the currently playing music
    func changeMusic(to type: MusicType) {
        guard let scene = scene else { return }
        
        // Remove current music
        if let currentMusicNode = backgroundMusicNode {
            currentMusicNode.removeFromParent()
            backgroundMusicNode = nil
        }
        
        // If type is none, just stop the music
        if type == .none {
            print("changeActiveMusic: stopped")
            return
        }
        
        // Create and add new music node
        let newMusicNode = SKAudioNode(fileNamed: type.rawValue)
        newMusicNode.autoplayLooped = true
        newMusicNode.isPositional = false

        scene.addChild(newMusicNode)
        backgroundMusicNode = newMusicNode

        print("changeActiveMusic: playing \(type.rawValue)")
    }
    
    // Play a sound effect once
    func playSoundEffect(named name: String) {
        guard let scene = scene else { return }
        
        let soundAction = SKAction.playSoundFileNamed(name, waitForCompletion: false)
        scene.run(soundAction)
    }
}
