//
//  NationalParksViewModel.swift
//  NationalParks
//
//  Created by Joshua Reed on 6/10/26.
//

import Foundation

class NationalParksViewModel : ObservableObject {
    @Published var introPages : [IntroPage] = []
    @Published var nationalParks : [ParkModel] = []
    @Published var isLoading = false
    @Published var hasError = false
    @Published var parkError : ParkModelError?
    
    func loadIntroPages() {
        guard introPages.isEmpty else { return }
        
        let captions = ["Discover America’s wild places",
                           "Plan your perfect park day",
                           "Learn about park activities and details",
                           "Start exploring national parks today"]
        
        let randomImages = (1...15)
            .map { String($0) }
            .shuffled()
            .prefix(4)
        
        introPages = zip(randomImages, captions).map {
            IntroPage(imageName: $0, caption: $1)
        }
    }
    
    @MainActor
    func fetchNationalParks(stateCode: String) async {
        self.isLoading = true
        self.nationalParks.removeAll()
        
        let baseUrl = "https://developer.nps.gov/api/v1/parks"
        let apiKey = "MQuVg9TchhiC72NDxGabqb7TqU91iLBFWvmcG6cy"
        
        guard var components = URLComponents(string : baseUrl) else { return }
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "limit", value: "50"),
            URLQueryItem(name: "stateCode", value: stateCode)
        ]
        
        guard let url = components.url else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let response = try JSONDecoder().decode(ParkAPIResponse.self, from: data)

            let filtered = response.data.filter {
                $0.designation == "National Park" || $0.designation == "National Park & Preserve"
            }
            
            self.nationalParks = filtered
            self.isLoading = false
            
            
        } catch {
            self.hasError = true
            self.parkError = .customError(error: error)
            self.isLoading = false
        }
    }
    
    struct ParkAPIResponse : Codable {
        let data : [ParkModel]
    }
    
    enum ParkModelError : LocalizedError {
        case decodingError
        case customError(error: Error)
        
        var errorDescription: String? {
            switch self {
                case .decodingError:
                return "Error decoding JSON"
            case .customError(error: let error):
                return error.localizedDescription
            }
        }
    }
}