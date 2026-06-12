//
// NationalParksApp.swift : NationalParks
//
// Copyright © 2025 Auburn University.
// All Rights Reserved.


import SwiftUI

@main
struct NationalParksApp: App {
    
    @StateObject var parks = NationalParksViewModel()
    @AppStorage("hasSeenIntro") var hasSeenIntro: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if hasSeenIntro {
                ContentView()
                    .environmentObject(parks)
            } else {
                IntroView {
                    hasSeenIntro = true
                }
                    .environmentObject(parks)
            }
            
        }
    }
}