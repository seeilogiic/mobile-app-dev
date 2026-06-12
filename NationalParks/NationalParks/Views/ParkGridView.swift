//
//  ParkGridView.swift
//  NationalParks
//
//  Created by Joshua Reed on 6/12/26.
//

import SwiftUI

struct ParkGridView: View {
    
    var stateCode : String
    
    var body: some View {
        Text("Parks for \(stateCode)")
            .font(.headline)
            .padding()
    }
}

#Preview {
    ParkGridView(stateCode: "CA")
}
