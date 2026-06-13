//
//  WeatherModels.swift
//  USWeather
//
//  Created by Joshua Reed on 6/12/26.
//

import Foundation

struct WeatherObservationResponse: Codable {
    let properties: WeatherProperties
}

struct WeatherProperties: Codable {
    let stationId: String?
    let timestamp: String?
    let textDescription: String?
    let icon: String?
    let temperature: WeatherValue?
    let relativeHumidity: WeatherValue?
    let windSpeed: WeatherValue?
    let barometricPressure: WeatherValue?
    let visibility: WeatherValue?
    let windChill: WeatherValue?
    let heatIndex: WeatherValue?
    
    struct WeatherValue: Codable {
        let value: Double?
        let unitCode: String?
    }
}

struct CityWeather: Identifiable {
    let id = UUID()
    let name: String
    let state: String
    let stationId: String
    var observation: WeatherProperties?
    
    var temperatureF: String {
        guard let celsius = observation?.temperature?.value else { return "--" }
        let fahrenheit = (celsius * 9/5) + 32
        return String(format: "%.0f°F", fahrenheit)
    }
    
    var feelsLikeF: String {
        let value = observation?.heatIndex?.value ?? observation?.windChill?.value ?? observation?.temperature?.value
        guard let celsius = value else { return "--" }
        let fahrenheit = (celsius * 9/5) + 32
        return String(format: "%.0f°F", fahrenheit)
    }
    
    var condition: String {
        observation?.textDescription ?? "Unknown"
    }
    
    var iconURL: URL? {
        guard let iconString = observation?.icon else { return nil }
        return URL(string: iconString)
    }
}
