//
//  QuestionCardView.swift
//  TrueOrFalse
//
//  Created by Joshua Reed on 7/5/26.
//

import SwiftUI

struct QuestionCardView: View {
    let question: Question
    let onSwipeRight: () -> Void
    let onSwipeLeft: () -> Void
    let onDoubleTap: () -> Void
    
    @State private var cardOffset: CGSize = .zero
    @State private var isAnimatingOut = false
    @State private var showHint = false
    
    let swipeThreshold: CGFloat = 100
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary, lineWidth: 1.5)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
            
            VStack(spacing: 12) {
                Spacer()
                
                Text(question.statement)
                    .font(.title3)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .foregroundColor(.primary)
                
                if showHint {
                    Text(question.hint)
                        .font(.subheadline)
                        .italic()
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .transition(.opacity.combined(with: .scale))
                } else {
                    Text("Tap for a hint")
                        .font(.caption)
                        .foregroundColor(.secondary.opacity(0.7))
                        .padding(.top, 4)
                }
                
                Spacer()
            }
            
            if cardOffset.width > 20 {
                VStack {
                    HStack {
                        Text("TRUE")
                            .font(.headline)
                            .bold()
                            .padding(8)
                            .border(Color.primary, width: 2)
                            .foregroundColor(.primary)
                            .rotationEffect(.degrees(-15))
                        Spacer()
                    }
                    Spacer()
                }
                .padding()
            }
            
            if cardOffset.width < -20 {
                VStack {
                    HStack {
                        Spacer()
                        Text("FALSE")
                            .font(.headline)
                            .bold()
                            .padding(8)
                            .border(Color.primary, width: 2)
                            .foregroundColor(.primary)
                            .rotationEffect(.degrees(15))
                    }
                    Spacer()
                }
                .padding()
            }
            
            if cardOffset.height < -20 {
                VStack {
                    Text("SKIP")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                        .border(Color.orange, width: 3)
                        .foregroundColor(.orange)
                        .rotationEffect(.degrees(-5))
                }
            }
        }
        .frame(height: 300)
        .offset(cardOffset)
        .rotationEffect(.degrees(Double(cardOffset.width / 15)))
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture(count: 2) {
            animateCardSkip()
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                showHint.toggle()
            }
        }
        .gesture(
            DragGesture(minimumDistance: 10)
                .onChanged { value in
                    if !isAnimatingOut {
                        cardOffset = value.translation
                    }
                }
                .onEnded { value in
                    if !isAnimatingOut {
                        if value.translation.width > swipeThreshold {
                            animateCardOut(swipeRight: true)
                        } else if value.translation.width < -swipeThreshold {
                            animateCardOut(swipeRight: false)
                        } else {
                            snapCardBack()
                        }
                    }
                }
        )
        .animation(.easeOut(duration: 0.2), value: cardOffset)
    }
    
    private func snapCardBack() {
        withAnimation(.spring()) {
            cardOffset = .zero
        }
    }
    
    private func animateCardOut(swipeRight: Bool) {
        isAnimatingOut = true
        withAnimation(.easeOut(duration: 0.2)) {
            cardOffset = CGSize(width: swipeRight ? 500 : -500, height: cardOffset.height)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if swipeRight {
                onSwipeRight()
            } else {
                onSwipeLeft()
            }
            cardOffset = .zero
            isAnimatingOut = false
        }
    }
    
    private func animateCardSkip() {
        guard !isAnimatingOut else { return }
        isAnimatingOut = true
        withAnimation(.easeOut(duration: 0.2)) {
            cardOffset = CGSize(width: cardOffset.width, height: -600)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onDoubleTap()
            cardOffset = .zero
            isAnimatingOut = false
        }
    }
}

#Preview {
    QuestionCardView(
        question: Question(statement: "The capital of France is Paris.", correctAnswer: true, hint: "It's known as the City of Light."),
        onSwipeRight: {},
        onSwipeLeft: {},
        onDoubleTap: {}
    )
}
