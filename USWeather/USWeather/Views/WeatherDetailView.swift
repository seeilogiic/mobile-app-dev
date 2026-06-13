//
//  WeatherDetailView.swift
//  USWeather
//
//  Created by Joshua Reed on 6/12/26.
//

import SwiftUI

struct WeatherDetailView: View {
    let city: CityWeather
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 30) {
                VStack(spacing: 10) {
                    Text(city.name)
                        .font(.system(size: 40, weight: .bold))
                    Text(city.state)
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                
                if let iconURL = city.iconURL {
                    AsyncImage(url: iconURL) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                }
                
                VStack(spacing: 5) {
                    Text(city.temperatureF)
                        .font(.system(size: 80, weight: .thin))
                    Text(city.condition)
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                VStack(spacing: 20) {
                    HStack {
                        WeatherDetailCard(title: "Humidity", value: formatValue(city.observation?.relativeHumidity?.value, unit: "%"))
                        WeatherDetailCard(title: "Feels Like", value: city.feelsLikeF)
                    }
                    
                    HStack {
                        WeatherDetailCard(title: "Wind Speed", value: formatWindSpeed(city.observation?.windSpeed?.value))
                        WeatherDetailCard(title: "Pressure", value: formatPressure(city.observation?.barometricPressure?.value))
                    }
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle(city.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formatValue(_ value: Double?, unit: String) -> String {
        guard let value = value else { return "--" }
        return String(format: "%.0f%@", value, unit)
    }
    
    private func formatWindSpeed(_ value: Double?) -> String {
        guard let kmh = value else { return "--" }
        let mph = kmh * 0.621371
        return String(format: "%.0f mph", mph)
    }
    
    private func formatPressure(_ value: Double?) -> String {
        guard let pa = value else { return "--" }
        let inHg = pa * 0.0002953
        return String(format: "%.2f inHg", inHg)
    }
}

struct WeatherDetailCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title.uppercased())
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
}
