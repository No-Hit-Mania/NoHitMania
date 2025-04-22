//
//  ContentView.swift
//  NoHitMania
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    @State var direction: String = "Swipe to move the box"
    @State var alive: Bool = true
    @State var elapsedTime: TimeInterval = 0.0
    @State var startTime: Date? = nil
    @State var currentLevel: Int = 1
    private let timer = Timer.publish(every: 1.0/60.0, on: .main, in: .common).autoconnect()
    
    func formattedTime(elapsed: TimeInterval) -> String {
        let totalSeconds = Int(elapsed)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        // Calculate the hundredths part from the fractional seconds
        let hundredths = Int((elapsed - Double(totalSeconds)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, hundredths)
    }
    
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
            SpriteView(scene: scene)
                .frame(width: 300, height: 300)
                .ignoresSafeArea()
        }
        .onAppear {
            // Capture the starting time when the view appears.
            startTime = Date()
        }
        .onReceive(timer) { _ in
            // If "alive" becomes false, stop the timer.
            if !alive {
                timer.upstream.connect().cancel()
            }
            // Update the elapsed time based on the start time.
            if let start = startTime {
                elapsedTime = Date().timeIntervalSince(start)
            }
            // Update the displayed text with the formatted elapsed time.
            direction = formattedTime(elapsed: elapsedTime)
        }
    }
}

#Preview {
    ContentView()
}
