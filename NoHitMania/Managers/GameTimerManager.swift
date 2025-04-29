//
//  GameTimerManager.swift
//  NoHitMania
//
//  Created on 4/24/25.
//

import Foundation
import Combine

class GameTimerManager {
    // Timer state
    private var scoreTime: TimeInterval = 0.0
    private var accumulatedTime: TimeInterval = 0.0
    private var startTime: Date? = nil
    private var isTimerRunning: Bool = false
    
    // Timer publisher
    private var timer = Timer.publish(every: 1.0/60.0, on: .main, in: .common).autoconnect()
    private var gameTimerSubscription: AnyCancellable?
    
    // Level progression
    private var currentLevel: Int = 1
    private var secondsBetweenLevels: Int = 5
    
    // Callback for UI updates
    var onTimerUpdate: ((String) -> Void)?
    var onLevelUpdate: ((Int) -> Void)?
    
    // Start the timer
    func startTimer() {
        accumulatedTime = 0.0
        scoreTime = 0.0
        currentLevel = 1
        startTime = Date()
        isTimerRunning = true
        subscribeToTimer()
    }
    
    // Pause the timer
    func pauseTimer() {
        if isTimerRunning, let start = startTime {
            // Add up the time since last start/pause
            accumulatedTime += Date().timeIntervalSince(start)
            startTime = nil
            isTimerRunning = false
            gameTimerSubscription?.cancel()
            gameTimerSubscription = nil
            print("pauseTimer: at: \(formattedTime(elapsed: accumulatedTime))")
        }
    }
    
    // Resume the timer
    func resumeTimer() {
        if !isTimerRunning {
            startTime = Date() // Set a new start time for the current run
            isTimerRunning = true
            subscribeToTimer()
            print("resumeTimer: at: \(formattedTime(elapsed: accumulatedTime))")
        }
    }
    
    // Helper method to set up the timer subscription
    private func subscribeToTimer() {
        gameTimerSubscription = timer
            .sink { [weak self] _ in
                self?.timerUpdate()
            }
    }
    
    // Update the timer
    private func timerUpdate() {
        if isTimerRunning {
            guard let startTime = self.startTime else {
                return
            }
            
            // Calculate the elapsed time since the current start and add the accumulated time
            let elapsedTime = Date().timeIntervalSince(startTime)
            self.scoreTime = elapsedTime + self.accumulatedTime
            
            // Update UI
            onTimerUpdate?(formattedTime(elapsed: self.scoreTime))
            
            // Check for level progression
            checkLevelProgression()
        }
    }
    
    // Check if it's time to advance to the next level
    private func checkLevelProgression() {
        if currentLevel < 5 {
            let newLevel = (Int(scoreTime) / secondsBetweenLevels) + 1
            if newLevel > currentLevel {
                currentLevel = newLevel
                onLevelUpdate?(currentLevel)
                print("timerUpdate: level up \(currentLevel)")
            }
        }
    }
    
    // Format the timer for display
    func formattedTime(elapsed: TimeInterval) -> String {
        let totalSeconds = Int(elapsed)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        // Calculate the hundredths part from the fractional seconds
        let hundredths = Int((elapsed - Double(totalSeconds)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, hundredths)
    }
    
    // Get the current level
    func getCurrentLevel() -> Int {
        return currentLevel
    }
    
    // Get the current elapsed time
    func getCurrentTime() -> TimeInterval {
        return scoreTime
    }
    
    // Set the time between level progressions
    func setSecondsBetweenLevels(_ seconds: Int) {
        secondsBetweenLevels = seconds
    }
}
