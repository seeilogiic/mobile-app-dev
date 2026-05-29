//
//  ContentView.swift
//  CheckoutApp
//
//  Created by Joshua Reed on 5/29/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Group {
                    ListItem(iconName: "apple", itemName: "Apple", price: 2)
                    ListItem(iconName: "banana", itemName: "Banana", price: 1)
                    ListItem(iconName: "strawberry", itemName: "Strawberry", price: 5)
                    ListItem(iconName: "pear", itemName: "Pear", price: 100)
                }
                Section {
                    ActionItem()
                }
                Section {
                    PickerItem()
                }
                Section {
                    ConfirmItem()
                }
            }
            .listStyle(GroupedListStyle())
            .navigationTitle(Text("Fruit Store"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ListItem: View {
    
    var iconName: String
    var itemName: String
    var price: Int
    
    var body: some View {
        HStack {
            Image(iconName)
                .imageScale(.medium)
            Text(itemName)
            Spacer()
            Text("$\(price)")
        }
        .padding()
        .foregroundStyle(Color("theme"))
    }
}

struct ActionItem : View {
    
    @State var counter : Int = 0
    
    var body : some View {
        HStack {
            Image(systemName: "plus")
                .imageScale(.large)
                .onTapGesture {apGesture in
                    counter += 1
                }
            Spacer()
            Text("\(counter)")
        }
    }
}

struct PickerItem : View {
    
    @State var flag : Bool = false
    @State var tip: Int = 0
    var tipOptions : [Int] = [10, 15, 20, 25]
    
    var body : some View {
        VStack {
            Toggle("Add a Tip?", isOn: $flag)
            
            if flag {
                Picker("Tip Percentage", selection: $tip) {
                    ForEach(tipOptions, id: \.self) { option in Text("\(option)")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                }
            }
        }
    }
}

struct ConfirmItem : View {
    
    @State var present : Bool = false
    
    var body: some View {
        Button("Confirm Order") {
            present.toggle()
        }
        .sheet(isPresented: $present, content: {
            secondView(present: $present)
        })
    }
}

struct secondView: View {
    @Binding var present : Bool
    var body: some View {
        Text("Order Confirmed!")
        Button("Dismiss") {
            present.toggle()
        }
    }
}
#Preview {
    ContentView()
        .preferredColorScheme(.light)
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
