//
//  NationalParksViewModel.swift
//  NationalParks
//
//  Created by Joshua Reed on 6/10/26.
//

import Foundation

class NationalParksViewModel: ObservableObject {
    @Published var introPages : [IntroPage] = []
    @Published var nationalParks : [ParkModel] = []
    
    func loadIntroPages() {
        guard introPages.isEmpty else { return }
        
        let captions = ["Discover America's wild places",
                            "Plan your perfect park day",
                            "Learn about park activities and details",
                            "Start exploring national parks today"]
        
        let randomImages = (1...15)
            .map{ String($0) }
            .shuffled()
            .prefix(4)
            
        introPages = zip(randomImages, captions).map {
            IntroPage(imageName: $0, caption: $1)
        }
    }
    
    func fetchNationalParks(stateCode : String) {
        let baseUrl = "https://develoepr.nps.gov/api/v1/parks"
        let apiKey = "MQuVg9TchhiC72NDxGabqb7TqU91iLBFWvmcG6cy"
        
        guard var components = URLComponents(string: baseUrl) else { return }
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "limit", value: "50"),
            URLQueryItem(name: "stateCode", value: stateCode)
        ]
        
        guard let url = components.url else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                print("Error \(error!)")
                return
            }
            
            guard let data = data else {
                print("No data returned")
                return
            }
            
            do {
                let response = try JSONDecoder().decode(ParkAPIResponse.self, from: data)
                
                let filtered = response.data.filter {
                    $0.designation == "National Park"
                }
                
                DispatchQueue.main.async {
                    self.nationalParks = filtered
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }
        
    }
    
    struct ParkAPIResponse: Codable {
        let data: [ParkModel]
    }
}
