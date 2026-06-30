//
//  EntryCardView.swift
//  ScanLog
//
//  Created by Joshua Reed on 6/29/26.
//

import SwiftUI

struct EntryCardView: View {
    let entry: JournalEntry
    
    private var formattedDate: String {
        entry.createdAt.formatted(date: .abbreviated, time: .shortened)
    }
    
    private var wordCount: Int {
        entry.text.split(whereSeparator: { $0.isWhitespace }).count
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: entry.title != nil ? "doc.text.fill" : "doc.viewfinder.fill")
                .font(.title3)
                .foregroundStyle(.blue)
                .padding(10)
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    Text(entry.title ?? "Untitled Scan")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(formattedDate)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Text(entry.text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Label("\(wordCount) words", systemImage: "character.book.closed")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
                .padding(.top, 4)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
