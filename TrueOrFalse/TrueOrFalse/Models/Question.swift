//
//  Question.swift
//  TrueOrFalse
//
//  Created by Joshua Reed on 7/5/26.
//

import Foundation

struct Question: Identifiable, Equatable {
    let id: UUID = UUID()
    let statement: String
    let correctAnswer: Bool // true for True, false for False
    let hint: String
}

