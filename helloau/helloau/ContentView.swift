//
//  ContentView.swift
//  helloau
//  Module 2 testing
//
//  Created by Joshua Reed on 5/29/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack (spacing: 20){
            Image("helloau")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, AU!")
                .font(.largeTitle)
                .foregroundColor(.blue)
            ListItem(iconName: "phone.fill", labelText: "1234567890")
            ListItem(iconName: "envelope.fill", labelText: "jtr0064")
            ListItem(iconName: "building.fill", labelText: "AUB 1234")
                
        }
        .padding()
    }
}

struct ListItem: View {
    var iconName: String
    var labelText: String
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(labelText)
                .font(.title2)
                .foregroundColor(.blue)
        }
    }
}
#Preview {
    ContentView()
}
