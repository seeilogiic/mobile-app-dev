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
    @State private var editingEntry: JournalEntry?
    @State private var searchText = ""
    @State private var isShowingComposer = false
    
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
            ZStack(alignment: .bottom) {
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 14) {
                                headerSection
                                statsSection
                                entriesSection
                            }
                            .padding(16)
                            .padding(.bottom, 80) // Leave space for the floating scan button
                        }
                    }
                }
                
                // Floating Action Button for scanning
                floatingActionButton
            }
            .navigationTitle("ScanLog")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingComposer = true
                    } label: {
                        Image(systemName: "doc.badge.plus")
                            .fontWeight(.medium)
                    }
                }
            }
            .task {
                viewModel.loadingEntries()
            }
            .alert(
                "ScanLog",
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { if !$0 { viewModel.errorMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .sheet(isPresented: $isShowingComposer) {
                ScanComposerView(viewModel: viewModel)
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
            Text("Your Documents")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Scan paper notes, capture text, and organize your scanned library.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
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
                                EntryCardView(entry: entry)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
    
    private var statsSection: some View {
        HStack(spacing: 12) {
            statCard(
                title: "Total Logs",
                value: "\(viewModel.entries.count)",
                icon: "books.vertical.fill",
                color: .blue
            )
            
            let weeklyCount = viewModel.entries.filter { entry in
                guard let days = Calendar.current.dateComponents([.day], from: entry.createdAt, to: Date()).day else { return false }
                return days < 7
            }.count
            statCard(
                title: "This Week",
                value: "\(weeklyCount)",
                icon: "calendar",
                color: .green
            )
            
            let totalWords = viewModel.entries.reduce(0) { sum, entry in
                sum + entry.text.split(whereSeparator: { $0.isWhitespace }).count
            }
            statCard(
                title: "Total Words",
                value: "\(totalWords)",
                icon: "doc.text.fill",
                color: .orange
            )
        }
        .padding(.vertical, 8)
    }
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.subheadline)
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .fontWeight(.medium)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    private var floatingActionButton: some View {
        Button {
            isShowingComposer = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "doc.viewfinder.fill")
                    .font(.headline)
                Text("Scan Document")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(Color.blue.gradient)
            .clipShape(Capsule())
            .shadow(color: Color.blue.opacity(0.3), radius: 8, y: 4)
        }
        .padding(.bottom, 16)
    }
}

struct ScanComposerView: View {
    @ObservedObject var viewModel: JournalViewModel
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Select a document image from your gallery to extract and log its text, or draft a manual entry.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Document Title")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        
                        TextField("e.g. Physics Notes, Meeting Minutes...", text: $viewModel.draftTitle)
                            .padding(12)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                        
                        Text("Extracted / Drafted Text")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .padding(.top, 4)
                        
                        TextEditor(text: $viewModel.draftText)
                            .frame(minHeight: 180)
                            .padding(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.separator), lineWidth: 1)
                            )
                            .overlay(alignment: .topLeading) {
                                if viewModel.draftText.isEmpty {
                                    Text("Extracted text will appear here. Tap scan below to start...")
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 16)
                                        .allowsHitTesting(false)
                                }
                            }
                    }
                    
                    VStack(spacing: 12) {
                        if viewModel.isScanning {
                            VStack(spacing: 8) {
                                ProgressView()
                                Text("Analyzing document text...")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                        } else {
                            PhotosPicker(
                                selection: $selectedPhotoItem,
                                matching: .images,
                                photoLibrary: .shared()
                            ) {
                                Label("Scan from Gallery", systemImage: "doc.viewfinder.fill")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                            }
                            .buttonStyle(.bordered)
                            .tint(.blue)
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("New Scan / Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.draftTitle = ""
                        viewModel.draftText = ""
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.addEntry()
                        dismiss()
                    }
                    .disabled(viewModel.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isScanning)
                }
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    await loadImageFromPhotoItem(newItem)
                    selectedPhotoItem = nil
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
                        
                        Button(role: .destructive) {
                            viewModel.deleteEntry(entry)
                        } label: {
                            Image(systemName: "trash")
                        }
                        .tint(.red)
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
