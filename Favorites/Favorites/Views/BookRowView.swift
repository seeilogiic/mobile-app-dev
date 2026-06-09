//
//  BookRowView.swift
//  Favorites
//
//  Created by GitHub Copilot on 2026/06/08.
//

import SwiftUI

struct BookRowView: View {
    let book: BookModel
    @EnvironmentObject private var favorites: FavoritesViewModel

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(book.bookTitle)
                    .font(.body)
                    .fontWeight(.semibold)
                Text(book.bookAuthor)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: {
                favorites.toggleFavoriteBook(book: book)
            }) {
                Image(systemName: book.isFavorite ? "heart.fill" : "heart")
                    .foregroundStyle(book.isFavorite ? .red : .gray)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    BookRowView(book: BookModel(id: 1, bookTitle: "To Kill a Mockingbird", bookAuthor: "Harper Lee"))
        .environmentObject(FavoritesViewModel())
}
