//
//  TrueOrFalseScreen.swift
//  TrueOrFalse
//
//  Created by Joshua Reed on 7/5/26.
//

import SwiftUI
import Combine

enum GameState {
    case notStarted
    case playing
    case gameOver
}

struct TrueOrFalseScreen: View {
    @State private var questions: [Question] = sampleQuestions
    @State private var currentIndex = 0
    @State private var score = 0
    @State private var timeLeft: Double = 20.0
    @State private var gameState: GameState = .notStarted
    @AppStorage("trueOrFalseHighScore") private var highScore: Int = 0
    
    let totalQuestions = 10
    let gameDuration: Double = 20.0 // 20 seconds total
    
    let timerPublisher = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack {
                    switch gameState {
                    case .notStarted:
                        StartView(highScore: highScore, onStart: startGame)
                    case .playing:
                        GamePlayView(
                            questions: questions,
                            currentIndex: $currentIndex,
                            score: $score,
                            timeLeft: $timeLeft,
                            gameDuration: gameDuration,
                            onAnswer: handleAnswer,
                            onSkip: handleSkip
                        )
                    case .gameOver:
                        GameOverView(
                            score: score,
                            totalQuestions: questions.count,
                            highScore: highScore,
                            timeFinished: gameDuration - timeLeft,
                            didTimeRunOut: timeLeft <= 0,
                            onRestart: restartGame
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("True or False")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
        .onReceive(timerPublisher) { _ in
            guard gameState == .playing else { return }
            if timeLeft > 0.05 {
                timeLeft -= 0.1
            } else {
                timeLeft = 0.0
                endGame()
            }
        }
    }
    
    private func startGame() {
        questions = sampleQuestions.shuffled()
        currentIndex = 0
        score = 0
        timeLeft = gameDuration
        gameState = .playing
    }
    
    private func handleAnswer(answeredTrue: Bool) {
        let question = questions[currentIndex]
        
        if answeredTrue == question.correctAnswer {
            score += 1
            if score > highScore {
                highScore = score
            }
        }
        
        if currentIndex < questions.count - 1 {
            currentIndex += 1
        } else {
            endGame()
        }
    }
    
    private func handleSkip() {
        guard gameState == .playing else { return }
        
        let question = questions[currentIndex]
        questions.remove(at: currentIndex)
        questions.append(question)
    }
    
    private func endGame() {
        if score > highScore {
            highScore = score
        }
        gameState = .gameOver
    }
    
    private func restartGame() {
        startGame()
    }
}

#Preview {
    TrueOrFalseScreen()
}
