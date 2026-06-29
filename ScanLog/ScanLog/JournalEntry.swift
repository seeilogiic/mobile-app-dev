//
//  JournalEntry.swift
//  ScanLog
//
//  Created by Joshua Reed on 6/29/26.
//

import Foundation

struct JournalEntry: Identifiable, Codable {
    let id: UUID
    var title: String?
    let text: String
    let createdAt: Date
    
    init(id: UUID, title: String? = nil, text: String, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.text = text
        self.createdAt = createdAt
    }
}
