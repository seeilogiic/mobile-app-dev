//
// ContentView.swift : NationalParks
//
// Copyright © 2025 Auburn University.
// All Rights Reserved.


import SwiftUI

struct ContentView: View {
    
    let usStates: [String] = [
                    "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA",
                    "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD",
                    "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ",
                    "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
                    "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"]
    
    @State var selectedState = "CA"
    
    var body: some View {
        NavigationStack {
            VStack(spacing : 32) {
                Picker("Select a State", selection: $selectedState) {
                    ForEach(usStates, id: \.self) { state in
                        Text(state).tag(state)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                
                NavigationLink(destination: ParkGridView(stateCode: selectedState)) {
                    Text("Search")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .padding(.horizontal)
                }
             }
            .navigationTitle("Find National Park")
        }
    }
}

#Preview {
    ContentView()
}
