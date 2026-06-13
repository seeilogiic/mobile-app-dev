//
//  WeatherViewModel.swift
//  USWeather
//
//  Created by Joshua Reed on 6/12/26.
//

import SwiftUI
import Foundation
import Combine

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var cities: [CityWeather] = [
        CityWeather(name: "New York", state: "NY", stationId: "KJFK"),
        CityWeather(name: "Los Angeles", state: "CA", stationId: "KLAX"),
        CityWeather(name: "Chicago", state: "IL", stationId: "KORD"),
        CityWeather(name: "Houston", state: "TX", stationId: "KIAH"),
        CityWeather(name: "Phoenix", state: "AZ", stationId: "KPHX"),
        CityWeather(name: "Miami", state: "FL", stationId: "KMIA"),
        CityWeather(name: "Seattle", state: "WA", stationId: "KSEA"),
        CityWeather(name: "Denver", state: "CO", stationId: "KDEN"),
        CityWeather(name: "Atlanta", state: "GA", stationId: "KATL"),
        CityWeather(name: "Boston", state: "MA", stationId: "KBOS"),
        CityWeather(name: "Dallas", state: "TX", stationId: "KDFW"),
        CityWeather(name: "San Francisco", state: "CA", stationId: "KSFO"),
        CityWeather(name: "Washington D.C.", state: "DC", stationId: "KDCA"),
        CityWeather(name: "Las Vegas", state: "NV", stationId: "KLAS"),
        CityWeather(name: "Minneapolis", state: "MN", stationId: "KMSP"),
        CityWeather(name: "New Orleans", state: "LA", stationId: "KMSY"),
        CityWeather(name: "St. Louis", state: "MO", stationId: "KSTL"),
        CityWeather(name: "Salt Lake City", state: "UT", stationId: "KSLC"),
        CityWeather(name: "Detroit", state: "MI", stationId: "KDTW"),
        CityWeather(name: "Nashville", state: "TN", stationId: "KBNA"),
        CityWeather(name: "Honolulu", state: "HI", stationId: "PHNL"),
        CityWeather(name: "Anchorage", state: "AK", stationId: "PANC")
    ]
    
    @Published var isLoading = false
    @Published var hasError = false
    @Published var errorMessage: String?
    
    func fetchAllWeather() async {
        self.isLoading = true
        self.hasError = false
        self.errorMessage = nil
        
        var successCount = 0
        var lastError: Error?
        
        await withTaskGroup(of: (Int, Result<WeatherProperties, Error>).self) { group in
            for index in cities.indices {
                let stationId = cities[index].stationId
                group.addTask {
                    do {
                        let observation = try await self.fetchWeather(for: stationId)
                        return (index, .success(observation))
                    } catch {
                        return (index, .failure(error))
                    }
                }
            }
            
            for await (index, result) in group {
                switch result {
                case .success(let observation):
                    self.cities[index].observation = observation
                    successCount += 1
                case .failure(let error):
                    lastError = error
                    print("Error fetching weather for \(cities[index].name): \(error)")
                }
            }
        }
        
        if successCount == 0 && !cities.isEmpty {
            self.hasError = true
            self.errorMessage = "Unable to fetch weather data. Please check your internet connection. (Error: \(lastError?.localizedDescription ?? "Unknown"))"
        }
        
        self.isLoading = false
    }
    
    private func fetchWeather(for stationId: String) async throws -> WeatherProperties {
        let urlString = "https://api.weather.gov/stations/\(stationId)/observations/latest"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.addValue("(USWeather, contact@example.com)", forHTTPHeaderField: "User-Agent")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            throw URLError(.init(rawValue: httpResponse.statusCode))
        }
        
        let observationResponse = try JSONDecoder().decode(WeatherObservationResponse.self, from: data)
        return observationResponse.properties
    }
}
