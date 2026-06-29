//
//  JournalEntry.swift
//  ScanLog
//
//  Created by Joshua Reed on 6/29/26.
//

import Foundation

struct JournalEntry: Identifiable, Codable {
    let id: UUID
    let text: String
    let createdAt: Date
    
    init(id: UUID, text: String, createdAt: Date = Date()) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
    }
}
