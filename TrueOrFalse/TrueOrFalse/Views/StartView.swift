//
//  StartView.swift
//  TrueOrFalse
//
//  Created by Joshua Reed on 7/5/26.
//

import SwiftUI

struct StartView: View {
    let highScore: Int
    let onStart: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text("True or False Blitz")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
            
            Text("Swipe right for True. Swipe left for False.\nDouble tap to skip and answer at the end.\nYou have 20 seconds to answer all questions.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("High Score: \(highScore) / 10")
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: onStart) {
                Text("Start Game")
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
    StartView(highScore: 5, onStart: {})
}
