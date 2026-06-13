//
//  ContentView.swift
//  USWeather
//
//  Created by Joshua Reed on 6/12/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = WeatherViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.cities.allSatisfy({ $0.observation == nil }) {
                    ProgressView("Fetching National Weather...")
                } else {
                    List(viewModel.cities) { city in
                        NavigationLink(destination: WeatherDetailView(city: city)) {
                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(city.name)
                                        .font(.headline)
                                    Text(city.state)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if let iconURL = city.iconURL {
                                    AsyncImage(url: iconURL) { image in
                                        image.resizable()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 40, height: 40)
                                }
                                
                                Text(city.temperatureF)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .frame(width: 60, alignment: .trailing)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await viewModel.fetchAllWeather()
                    }
                }
            }
            .navigationTitle("National Weather")
            .task {
                await viewModel.fetchAllWeather()
            }
            .alert("Error", isPresented: $viewModel.hasError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "Unknown error")
            }
        }
    }
}

#Preview {
    ContentView()
}
