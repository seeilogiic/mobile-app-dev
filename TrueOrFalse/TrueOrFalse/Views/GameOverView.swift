//
//  GameOverView.swift
//  TrueOrFalse
//
//  Created by Joshua Reed on 7/5/26.
//

import SwiftUI

struct GameOverView: View {
    let score: Int
    let totalQuestions: Int
    let highScore: Int
    let timeFinished: Double
    let didTimeRunOut: Bool
    let onRestart: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text(didTimeRunOut ? "Time's Up!" : "Game Over")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                Text("Final Score: \(score) / \(totalQuestions)")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.primary)
                
                Text(String(format: "Time Taken: %.1fs", timeFinished))
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Text("High Score: \(highScore) / \(totalQuestions)")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            Spacer()
            
            Button(action: onRestart) {
                Text("Play Again")
                    .bold()
                    .foregroundColor(Color(.systemBackground))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primary)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    GameOverView(
        score: 8,
        totalQuestions: 10,
        highScore: 10,
        timeFinished: 12.4,
        didTimeRunOut: false,
        onRestart: {}
    )
}
