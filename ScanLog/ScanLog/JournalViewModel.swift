//
//  JournalViewModel.swift
//  ScanLog
//
//  Created by Joshua Reed on 6/29/26.
//

import Foundation
import PhotosUI
import SwiftUI
import Combine

@MainActor
final class JournalViewModel: ObservableObject {
    @Published var entries: [JournalEntry] = []
    @Published var draftTitle: String = ""
    @Published var draftText: String = ""
    @Published var isLoading: Bool = false
    @Published var isScanning: Bool = false
    @Published var errorMessage: String?
    
    private let storage = JournalStorage()
    private let textRecognitionService = TextRecognitionService()
    
    func loadingEntries() {
        isLoading = true
        entries = storage.loadEntries()
        isLoading = false
    }
    
    func addEntry() {
        let cleanedText = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedTitle = draftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanedText.isEmpty else {
            errorMessage = "Write or scan something before saving!"
            return
        }
        
        let title = cleanedTitle.isEmpty ? nil : cleanedTitle
        let entry = JournalEntry(id: UUID(), title: title, text: cleanedText)
        entries.insert(entry, at: 0)
        draftText = ""
        draftTitle = ""
        errorMessage = nil
        storage.saveEntries(entries)
    }
    
    func deleteEntry(_ entry: JournalEntry) {
        entries.removeAll { $0.id == entry.id }
        storage.saveEntries(entries)
    }
    
    func updateEntry(_ entry: JournalEntry, title: String?, with newText: String) {
        let cleanedText = newText.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedTitle = (title ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanedText.isEmpty else {
            errorMessage = "Entry text cannot be empty!"
            return
        }
        
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            let finalTitle = cleanedTitle.isEmpty ? nil : cleanedTitle
            entries[index] = JournalEntry(id: entry.id, title: finalTitle, text: cleanedText, createdAt: entry.createdAt)
            errorMessage = nil
            storage.saveEntries(entries)
        }
    }
    
    func recognizeText(from image: UIImage) async {
        isScanning = true
        errorMessage = nil
        
        do {
            let text = try await textRecognitionService.recognizeText(from: image)
            let cleanedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if cleanedText.isEmpty {
                errorMessage = "No text was found in this image!"
            } else {
                draftText = cleanedText
            }
        } catch {
            errorMessage = "Text scan failed: \(error.localizedDescription)"
        }
        
        isScanning = false
    }
}
