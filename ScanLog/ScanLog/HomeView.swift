//
//  HomeView.swift
//  ScanLog
//
//  Created by Joshua Reed on 6/29/26.
//

import SwiftUI
import PhotosUI
import UIKit

struct HomeView: View {
    @StateObject private var viewModel = JournalViewModel()
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var editingEntry: JournalEntry?
    @State private var searchText = ""
    
    private var filteredEntries: [JournalEntry] {
        if searchText.isEmpty {
            return viewModel.entries
        } else {
            return viewModel.entries.filter { entry in
                (entry.title?.localizedCaseInsensitiveContains(searchText) == true) ||
                entry.text.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func groupEntries(_ entries: [JournalEntry]) -> [(group: String, entries: [JournalEntry])] {
        let calendar = Calendar.current
        var today: [JournalEntry] = []
        var yesterday: [JournalEntry] = []
        var earlier: [JournalEntry] = []
        
        for entry in entries {
            if calendar.isDateInToday(entry.createdAt) {
                today.append(entry)
            } else if calendar.isDateInYesterday(entry.createdAt) {
                yesterday.append(entry)
            } else {
                earlier.append(entry)
            }
        }
        
        var result: [(group: String, entries: [JournalEntry])] = []
        if !today.isEmpty { result.append(("Today", today)) }
        if !yesterday.isEmpty { result.append(("Yesterday", yesterday)) }
        if !earlier.isEmpty { result.append(("Earlier", earlier)) }
        return result
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            headerSection
                            editorSection
                            actionSection
                            entriesSection
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("ScanLog")
            .task {
                viewModel.loadingEntries()
            }
            .alert(
                "ScanLog",
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { if !$0 {viewModel.errorMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                guard let newItem else { return }
                
                Task {
                    await loadImageFromPhotoItem(newItem)
                    selectedPhotoItem = nil
                }
            }
            .sheet(item: $editingEntry) { entry in
                EditEntryView(entry: entry) { updatedTitle, updatedText in
                    viewModel.updateEntry(entry, title: updatedTitle, with: updatedText)
                }
            }
            .searchable(text: $searchText, prompt: "Search title or text...")
            .navigationDestination(for: JournalEntry.self) { entry in
                EntryDetailView(entryId: entry.id, viewModel: viewModel)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Write or scan your thoughts.")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Scan notes, edit the extracted text, and save it as a journal entry!")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
    
    private var editorSection: some View {
        VStack(spacing: 12) {
            TextField("Title (Optional)", text: $viewModel.draftTitle)
                .padding(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.separator), lineWidth: 1)
                )
            
            TextEditor(text: $viewModel.draftText)
                .frame(minHeight: 170)
                .padding(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(.separator), lineWidth: 1)
                )
                .overlay(alignment: .topLeading) {
                    if viewModel.draftText.isEmpty {
                        Text("Type here, or select a note image...")
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 16)
                            .allowsHitTesting(false)
                    }
                }
        }
    }
    
    private var actionSection: some View {
        VStack(spacing: 12) {
            if viewModel.isScanning {
                ProgressView()
                    .frame(maxWidth: .infinity)
            }
            
            PhotosPicker(
                selection: $selectedPhotoItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Label("Gallery", systemImage: "photo.on.rectange")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.isScanning)
            
            Button {
                viewModel.addEntry()
            } label : {
                Label("Save Entry", systemImage: "square.and.arrow.down")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isScanning)
        }
    }
    
    private var entriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Journal Entries")
                .font(.headline)
            
            let filtered = filteredEntries
            if filtered.isEmpty {
                Text(searchText.isEmpty ? "No entries yet!" : "No matching entries found!")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(.secondarySystemBackground))
                    )
            } else {
                let grouped = groupEntries(filtered)
                ForEach(grouped, id: \.group) { section in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(section.group)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .padding(.top, 8)
                        
                        ForEach(section.entries) { entry in
                            NavigationLink(value: entry) {
                                EntryCardView(entry: entry, onEdit: {
                                    editingEntry = entry
                                }, onDelete: {
                                    viewModel.deleteEntry(entry)
                                })
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
    
    private func loadImageFromPhotoItem(_ item: PhotosPickerItem) async {
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else {
                viewModel.errorMessage = "Could not load the selected image!"
                return
            }
            
            await viewModel.recognizeText(from: image)
        } catch {
            viewModel.errorMessage = "Could not read the selected image!"
        }
    }
}

#Preview {
    HomeView()
}

struct EditEntryView: View {
    let entry: JournalEntry
    let onSave: (String?, String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var text: String
    
    init(entry: JournalEntry, onSave: @escaping (String?, String) -> Void) {
        self.entry = entry
        self.onSave = onSave
        _title = State(initialValue: entry.title ?? "")
        _text = State(initialValue: entry.text)
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Edit the content of your journal entry below.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                
                TextField("Title (Optional)", text: $title)
                    .padding(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(.separator), lineWidth: 1)
                    )
                    .padding(.horizontal)
                
                TextEditor(text: $text)
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.separator), lineWidth: 1)
                    )
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top)
            .navigationTitle("Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(title, text)
                        dismiss()
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

struct EntryDetailView: View {
    let entryId: UUID
    @ObservedObject var viewModel: JournalViewModel
    @State private var isEditing = false
    
    @Environment(\.dismiss) private var dismiss
    
    private var currentEntry: JournalEntry? {
        viewModel.entries.first(where: { $0.id == entryId })
    }
    
    var body: some View {
        Group {
            if let entry = currentEntry {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(entry.createdAt.formatted(date: .long, time: .shortened))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            if let title = entry.title, !title.isEmpty {
                                Text(title)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.primary)
                            }
                        }
                        
                        Divider()
                        
                        Text(entry.text)
                            .font(.body)
                            .lineSpacing(6)
                            .textSelection(.enabled)
                        
                        Spacer()
                    }
                    .padding(20)
                }
                .navigationTitle("Journal Entry")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .primaryAction) {
                        ShareLink(item: entry.text, subject: Text(entry.title ?? "Journal Entry")) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        
                        Button {
                            UIPasteboard.general.string = entry.text
                        } label: {
                            Image(systemName: "doc.on.doc")
                        }
                        
                        Button {
                            isEditing = true
                        } label: {
                            Image(systemName: "pencil")
                        }
                    }
                }
                .sheet(isPresented: $isEditing) {
                    EditEntryView(entry: entry) { updatedTitle, updatedText in
                        viewModel.updateEntry(entry, title: updatedTitle, with: updatedText)
                    }
                }
                .onChange(of: currentEntry) { _, newEntry in
                    if newEntry == nil {
                        dismiss()
                    }
                }
            } else {
                VStack {
                    Text("Entry not found")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
