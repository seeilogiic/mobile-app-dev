//
//  FavoritesView.swift
//  Favorites
//
//  Created by Joshua Reed on 6/8/26.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var favorites: FavoritesViewModel
    
    var body: some View {
        NavigationStack {
            Group {
                if favorites.hasAnyFavorites {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            if !favorites.favoriteCities.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Favorite Cities")
                                        .font(.headline)
                                        .padding(.horizontal)
                                    ForEach(favorites.favoriteCities, id: \.id) { city in
                                        CityCardView(city: city)
                                    }
                                }
                                .id("favoriteCitiesSection")
                            }
                            
                            if !favorites.favoriteHobbies.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Favorite Hobbies")
                                        .font(.headline)
                                        .padding(.horizontal)
                                    ForEach(favorites.favoriteHobbies, id: \.id) { hobby in
                                        HobbyRowView(hobby: hobby)
                                            .padding(.horizontal)
                                    }
                                }
                                .id("favoriteHobbiesSection")
                            }
                            
                            if !favorites.favoriteBooks.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Favorite Books")
                                        .font(.headline)
                                        .padding(.horizontal)
                                    ForEach(favorites.favoriteBooks, id: \.id) { book in
                                        BookRowView(book: book)
                                            .padding(.horizontal)
                                    }
                                }
                                .id("favoriteBooksSection")
                            }
                        }
                        .padding(.vertical)
                    }
                } else {
                    VStack(spacing: 16) {
                        Text("No favorites yet.")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("Favorite cities, hobbies, or books to see them here.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
            }
            .navigationTitle("Favorites")
        }
    }
}

#Preview {
    FavoritesView()
        .environmentObject(FavoritesViewModel())
}
