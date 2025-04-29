//
//  MusicManager.swift
//  NoHitMania
//
//  Created by Cristobal Elizarraraz on 4/29/25.
//


//
//  MusicManager.swift
//  NoHitMania
//
//  Created by Jason Kim on 4/21/25.
//


import Foundation
import AVFoundation

class MusicManager {
    static let shared = MusicManager()

    private var audioPlayer: AVAudioPlayer?

    private init() {}

    /// Plays music with a fade-in effect.
    /// - Parameters:
    ///   - fileName: Name of the audio file (without extension).
    ///   - fadeDuration: How long the fade-in takes.
    ///   - loop: Whether to loop the music infinitely.
    func playMusic(named fileName: String, fadeDuration: TimeInterval = 1.0, loop: Bool = true) {
        let supportedExtensions = ["mp3", "wav"]
        var url: URL? = nil

        for ext in supportedExtensions {
            if let foundURL = Bundle.main.url(forResource: fileName, withExtension: ext) {
                url = foundURL
                break
            }
        }

        guard let audioURL = url else {
            print("❌ Music file not found: \(fileName)")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: audioURL)
            player.numberOfLoops = loop ? -1 : 0
            player.volume = 0
            player.prepareToPlay()
            player.play()

            audioPlayer?.stop()
            audioPlayer = player
            fade(toVolume: 1.0, duration: fadeDuration)
        } catch {
            print("❌ Error loading music: \(error.localizedDescription)")
        }
    }


    /// Fades out and stops the current music.
    /// - Parameter fadeDuration: How long the fade-out takes.
    func stopMusic(fadeDuration: TimeInterval = 1.0) {
        fade(toVolume: 0.0, duration: fadeDuration) {
            self.audioPlayer?.stop()
            self.audioPlayer = nil
        }
    }

    /// Smoothly fades the volume to the target over time.
    /// - Parameters:
    ///   - toVolume: Target volume (0.0–1.0).
    ///   - duration: Fade duration in seconds.
    ///   - completion: Optional callback after fade is done.
    private func fade(toVolume: Float, duration: TimeInterval, completion: (() -> Void)? = nil) {
        guard let player = audioPlayer else {
            completion?()
            return
        }

        let steps = 25
        let delay = duration / Double(steps)
        let startVolume = player.volume
        let volumeDelta = toVolume - startVolume

        for i in 0...steps {
            let delayTime = delay * Double(i)
            DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) {
                let progress = Float(i) / Float(steps)
                player.volume = startVolume + volumeDelta * progress
                if i == steps {
                    completion?()
                }
            }
        }
    }
}