//
//  AudioManager.swift
//  NoHitMania
//
//  Created by Jason Kim on 4/10/24

import SpriteKit

class AudioManager {

    static let shared = AudioManager()

    enum MusicType: String {
        case mainMenu = "MenuTheme.mp3"
        case game = "GameMusic.wav"
        case gameFromPause = "GameMusicFromPause.mp3"
        case pause = "PauseMusic.mp3"
        case none = ""
    }

    private var backgroundMusicNode: SKAudioNode?
    private init() {}

    // MARK: - Background Music
    func changeMusic(to type: MusicType, in scene: SKScene) {
        // Remove current music
        backgroundMusicNode?.removeFromParent()
        backgroundMusicNode = nil

        guard type != .none else {
            print("🎵 Music stopped")
            return
        }

        let musicNode = SKAudioNode(fileNamed: type.rawValue)
        musicNode.autoplayLooped = true
        musicNode.isPositional = false
        scene.addChild(musicNode)
        backgroundMusicNode = musicNode

        print("🎵 Now playing: \(type.rawValue)")
    }

    // MARK: - Sound Effects
    func playSoundEffect(named name: String, on scene: SKScene? = nil) {
        let targetScene = scene ?? backgroundMusicNode?.scene
        guard let target = targetScene else {
            print("⚠️ AudioManager: No scene to play sound effect: \(name)")
            return
        }

        let playAction = SKAction.playSoundFileNamed(name, waitForCompletion: false)
        target.run(playAction)

        print("🔊 Sound effect: \(name)")
    }
}
