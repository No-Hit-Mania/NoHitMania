//
//  MenuView.swift
//  NoHitMania
//
//  Created by Cristobal Elizarraraz on 4/15/25.
//
import SwiftUI
import SpriteKit

struct MenuView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("Main Menu")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 50)
                
                NavigationLink(destination: GameView()) {
                    Text("Start Game")
                }
                .buttonStyle(MenuButtonStyle())
                
                Button("Store") {
                    
                }
                .buttonStyle(MenuButtonStyle())
                
                Button("Options") {
                }
                .buttonStyle(MenuButtonStyle())
                
                Spacer()
            }
            .padding()
        }
    }
}

struct MenuButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

#Preview {
    MenuView()
}
