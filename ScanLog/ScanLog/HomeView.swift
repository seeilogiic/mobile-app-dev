//
//  HomeView.swift
//  ScanLog
//
//  Created by Joshua Reed on 6/29/26.
//

import SwiftUI
import PhotosUI

struct HomeView: View {
    @StateObject private var viewModel = JournalViewModel()
    @State private var selectedPhotoItem: PhotosPickerItem?
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
            
            if viewModel.entries.isEmpty {
                Text("No entries yet!")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(.secondarySystemBackground))
                    )
            } else {
                ForEach(viewModel.entries) { entry in
                    EntryCardView(entry: entry) {
                        viewModel.deleteEntry(entry)
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
