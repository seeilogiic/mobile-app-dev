//
//  EntryCardView.swift
//  ScanLog
//
//  Created by Joshua Reed on 6/29/26.
//

import SwiftUI

struct EntryCardView: View {
    let entry: JournalEntry
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    private var formattedDate: String {
        entry.createdAt.formatted(date: .abbreviated, time: .shortened)
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(formattedDate)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            if let title = entry.title, !title.isEmpty {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            
            Text(entry.text)
                .font(.body)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            HStack {
                Spacer()
                
                Button(action: onEdit) {
                    Label("Edit", systemImage: "pencil")
                }
                .font(.subheadline)
                .foregroundStyle(.tint)
                .buttonStyle(.borderless)
                
                Spacer()
                    .frame(width: 16)
                
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
                .font(.subheadline)
                .buttonStyle(.borderless)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
