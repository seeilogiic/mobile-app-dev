//
// FavoritesViewModel.swift : Favorites
//
// Copyright © 2025 Auburn University.
// All Rights Reserved.


import Foundation
import SwiftUI

class FavoritesViewModel : ObservableObject {
    
    @Published var cities: [CityModel] = sampleCities
    @Published var hobbies: [HobbyModel] = sampleHobbies
    @Published var books: [BookModel] = sampleBooks
    
    init() {
        loadFavoriteCities()
        loadFavoriteHobbies()
    }
    
    func filteredCities(searchText: String) -> [CityModel] {
        if searchText.isEmpty {
            return cities
        } else {
            return cities.filter {
                $0.cityName.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    func toggleFavoriteCity(city: CityModel) {
        if let index = cities.firstIndex(where: { $0.id == city.id}) {
            cities[index].isFavorite.toggle()
            saveFavoriteCities()
        }
    }
    
    func saveFavoriteCities() {
        let favoriteCities = cities.filter({ $0.isFavorite }).map { $0.id }
        UserDefaults.standard.set(favoriteCities, forKey: "favoriteCities")
    }
    
    func loadFavoriteCities() {
        if let savedCityIds = UserDefaults.standard.array(forKey: "favoriteCities") as? [Int] {
            for index in cities.indices {
                cities[index].isFavorite = savedCityIds.contains(cities[index].id)
            }
        }
    }
    
    func filteredHobbies(searchText: String) -> [HobbyModel] {
        if searchText.isEmpty {
            return hobbies
        } else {
            return hobbies.filter {
                $0.hobbyName.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    func saveFavoriteHobbies() {
        let favoriteHobbyIds = hobbies.filter({ $0.isFavorite}).map {$0.id }
        UserDefaults.standard.set(favoriteHobbyIds, forKey: "favoriteHobbies")
    }
    
    func loadFavoriteHobbies() {
        if let favoriteHobbyIds = UserDefaults.standard.array(forKey: "favoriteHobbies") as? [Int] {
            for index in hobbies.indices {
                hobbies[index].isFavorite = favoriteHobbyIds.contains(hobbies[index].id)
            }
        }
    }
    
    func toggleFavoriteHobby(hobby: HobbyModel) {
        if let index = hobbies.firstIndex(where: { $0.id == hobby.id}) {
            hobbies[index].isFavorite.toggle()
            saveFavoriteHobbies()
        }
    }

}


let sampleCities: [CityModel] = [

    CityModel(id : 1, cityName: "Cape Town", cityImage: "capetown", isFavorite: false),
    CityModel(id : 2, cityName: "Copenhagen", cityImage: "copenhagen", isFavorite: false),
    CityModel(id : 3, cityName: "Lisbon", cityImage: "lisbon", isFavorite: false),
    CityModel(id : 4, cityName: "Reykjavik", cityImage: "reykjavik", isFavorite: false),
    CityModel(id : 5, cityName: "Warsaw", cityImage: "warsaw", isFavorite: false),
    CityModel(id : 6, cityName: "London", cityImage: "london", isFavorite: false),
    CityModel(id : 7, cityName: "Monaco", cityImage: "monaco", isFavorite: false),
    CityModel(id : 8, cityName: "Amsterdam", cityImage: "amsterdam", isFavorite: false),
    CityModel(id : 9, cityName: "Los Angeles", cityImage: "losangeles", isFavorite: false)
]


let sampleHobbies: [HobbyModel] = [
    HobbyModel(id : 1, hobbyName: "Painting", hobbyIcon: "🎨", isFavorite: false),
    HobbyModel(id : 2, hobbyName: "Photography", hobbyIcon: "📷", isFavorite: false),
    HobbyModel(id : 3, hobbyName: "Guitar", hobbyIcon: "🎸", isFavorite: false),
    HobbyModel(id : 4, hobbyName: "Yoga", hobbyIcon: "🧘‍♀️", isFavorite: false),
    HobbyModel(id : 5, hobbyName: "Gardening", hobbyIcon: "🪴", isFavorite: false),
    HobbyModel(id : 6, hobbyName: "Cooking", hobbyIcon: "🍳", isFavorite: false),
    HobbyModel(id : 7, hobbyName: "Hiking", hobbyIcon: "🥾", isFavorite: false),
    HobbyModel(id : 8, hobbyName: "Writing", hobbyIcon: "✍️", isFavorite: false),
    HobbyModel(id : 9, hobbyName: "Dancing", hobbyIcon: "💃", isFavorite: false),
    HobbyModel(id : 10, hobbyName: "Knitting", hobbyIcon: "🧶", isFavorite: false),
    HobbyModel(id : 11, hobbyName: "Gaming", hobbyIcon: "🎮", isFavorite: false),
    HobbyModel(id : 12, hobbyName: "Calligraphy", hobbyIcon: "✒️", isFavorite: false),
]

let sampleBooks: [BookModel] = [
    BookModel(id : 1, bookTitle: "To Kill a Mockingbird", bookAuthor: "Harper Lee", isFavorite: false),
    BookModel(id : 2, bookTitle: "1984", bookAuthor: "George Orwell", isFavorite: false),
    BookModel(id : 3, bookTitle: "Pride and Prejudice", bookAuthor: "Jane Austen", isFavorite: false),
    BookModel(id : 4, bookTitle: "The Great Gatsby", bookAuthor: "F. Scott Fitzgerald", isFavorite: false),
    BookModel(id : 5, bookTitle: "The Catcher in the Rye", bookAuthor: "J.D. Salinger", isFavorite: false),
    BookModel(id : 6, bookTitle: "The Hobbit", bookAuthor: "J.R.R. Tolkien", isFavorite: false),
    BookModel(id : 7, bookTitle: "Fahrenheit 451", bookAuthor: "Ray Bradbury", isFavorite: false),
    BookModel(id : 8, bookTitle: "Jane Eyre", bookAuthor: "Charlotte Brontë", isFavorite: false),
    BookModel(id : 9, bookTitle: "The Alchemist", bookAuthor: "Paulo Coelho", isFavorite: false),
    BookModel(id : 10, bookTitle: "The Book Thief", bookAuthor: "Markus Zusak", isFavorite: false),
    BookModel(id : 11, bookTitle: "Moby-Dick", bookAuthor: "Herman Melville", isFavorite: false),
    BookModel(id : 12, bookTitle: "Crime and Punishment", bookAuthor: "Fyodor Dostoevsky", isFavorite: false)
]
