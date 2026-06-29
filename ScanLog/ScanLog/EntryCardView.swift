//
//  EntryCardView.swift
//  ScanLog
//
//  Created by Joshua Reed on 6/29/26.
//

import SwiftUI

struct EntryCardView: View {
    let entry: JournalEntry
    let onDelete: () -> Void
    
    private var formattedDate: String {
        entry.createdAt.formatted(date: .abbreviated, time: .shortened)
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(formattedDate)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(entry.text)
                .font(.body)
            
            HStack {
                Spacer()
                
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
                .font(.subheadline)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
