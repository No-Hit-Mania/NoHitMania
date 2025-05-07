//
//  AudioManager.swift
//  NoHitMania
//
//  Created by Jason Kim on 4/10/24

import SpriteKit
import AVFoundation

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
    private var musicVolume: Float = 0.5
    private var effectsVolume: Float = 0.5

    private init() {
        // Load saved volume settings
        musicVolume = UserDefaults.standard.float(forKey: "musicVolume")
        effectsVolume = UserDefaults.standard.float(forKey: "effectsVolume")

        // Set default if not set
        if musicVolume == 0 { musicVolume = 0.5 }
        if effectsVolume == 0 { effectsVolume = 0.5 }
    }

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

        // Apply volume via AVAudioMixer (post-add)
        musicNode.run(SKAction.changeVolume(to: musicVolume, duration: 0.0))

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

        let action = SKAction.changeVolume(to: effectsVolume, duration: 0.0)
        let playAction = SKAction.sequence([
            action,
            SKAction.playSoundFileNamed(name, waitForCompletion: false)
        ])
        target.run(playAction)

        print("🔊 Sound effect: \(name)")
    }

    // MARK: - Volume Controls
    func setMusicVolume(_ volume: Float) {
        musicVolume = volume
        UserDefaults.standard.set(volume, forKey: "musicVolume")

        backgroundMusicNode?.run(SKAction.changeVolume(to: volume, duration: 0.2))

        print("🎚 Music volume set to \(volume)")
    }

    func setEffectsVolume(_ volume: Float) {
        effectsVolume = volume
        UserDefaults.standard.set(volume, forKey: "effectsVolume")

        print("🎚 Effects volume set to \(volume)")
    }

    func getMusicVolume() -> Float {
        return musicVolume
    }

    func getEffectsVolume() -> Float {
        return effectsVolume
    }
}
