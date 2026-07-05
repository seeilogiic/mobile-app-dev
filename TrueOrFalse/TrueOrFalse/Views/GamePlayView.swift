//
//  GamePlayView.swift
//  TrueOrFalse
//
//  Created by Joshua Reed on 7/5/26.
//

import SwiftUI

struct GamePlayView: View {
    let questions: [Question]
    @Binding var currentIndex: Int
    @Binding var score: Int
    @Binding var timeLeft: Double
    let gameDuration: Double
    let onAnswer: (Bool) -> Void
    let onSkip: () -> Void
    
    @State private var showSkipFlash = false
    @State private var currentFlashID = UUID()
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Question \(currentIndex + 1) of \(questions.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Score: \(score)")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.primary)
            }
            
            Text(String(format: "Time remaining: %.1fs", timeLeft))
                .font(.title2)
                .bold()
                .monospacedDigit()
                .foregroundColor(.primary)
            
            Divider()
            
            Spacer()
            
            if currentIndex < questions.count {
                QuestionCardView(
                    question: questions[currentIndex],
                    onSwipeRight: {
                        onAnswer(true)
                    },
                    onSwipeLeft: {
                        onAnswer(false)
                    },
                    onDoubleTap: {
                        let flashID = UUID()
                        currentFlashID = flashID
                        
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            showSkipFlash = true
                        }
                        onSkip()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            if currentFlashID == flashID {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showSkipFlash = false
                                }
                            }
                        }
                    }
                )
                .id(questions[currentIndex].id)
            }
            
            ZStack {
                if showSkipFlash {
                    Text("Skipped")
                        .font(.headline)
                        .italic()
                        .foregroundColor(.secondary)
                        .transition(.opacity)
                }
            }
            .frame(height: 50)
            
            Spacer()
        }
    }
}

#Preview {
    GamePlayView(
        questions: sampleQuestions,
        currentIndex: .constant(0),
        score: .constant(3),
        timeLeft: .constant(15.5),
        gameDuration: 20.0,
        onAnswer: { _ in },
        onSkip: {}
    )
}
