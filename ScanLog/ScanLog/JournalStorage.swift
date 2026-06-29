//
//  JournalStorage.swift
//  ScanLog
//
//  Created by Joshua Reed on 6/29/26.
//

import Foundation

final class JournalStorage {
    private let entriesKey = "journal_entries"
    
    func saveEntries(_ entries: [JournalEntry]) {
        do {
            let data = try JSONEncoder().encode(entries)
            UserDefaults.standard.set(data, forKey: entriesKey)
        } catch {
            print("Failed to save entries: \(error)")
        }
    }
    
    func loadEntries() -> [JournalEntry] {
        guard let data = UserDefaults.standard.data(forKey: entriesKey) else {
            return []
        }
        
        do {
            let entries = try JSONDecoder().decode([JournalEntry].self, from: data)
            return entries.sorted { $0.createdAt > $1.createdAt }
        } catch {
            print("Failed to load entries: \(error)")
            return []
        }
    }
}
