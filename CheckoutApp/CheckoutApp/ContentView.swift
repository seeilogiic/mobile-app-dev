//  ContentView.swift
//  CheckoutApp
//
//  Created by Joshua Reed on 5/29/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedFruit: String? = nil
    @State private var fruitCounters: [String: Int] = [
        "Apple": 0,
        "Banana": 0,
        "Strawberry": 0,
        "Pear": 0
    ]
    
    @State private var flag: Bool = false
    @State private var tip: Int = 10
    
    private let fruitPrices: [String: Int] = [
        "Apple": 2,
        "Banana": 1,
        "Strawberry": 5,
        "Pear": 100
    ]
    
    private var totalPrice: Double {
        let subtotal = fruitCounters.reduce(0) { sum, pair in
            let fruitName = pair.key
            let quantity = pair.value
            let price = fruitPrices[fruitName] ?? 0
            return sum + (price * quantity)
        }
        
        if flag {
            let multiplier = 1.0 + (Double(tip) / 100.0)
            return Double(subtotal) * multiplier
        } else {
            return Double(subtotal)
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Group {
                    ListItem(iconName: "apple", itemName: "Apple", price: 2, selectedFruit: $selectedFruit)
                    ListItem(iconName: "banana", itemName: "Banana", price: 1, selectedFruit: $selectedFruit)
                    ListItem(iconName: "strawberry", itemName: "Strawberry", price: 5, selectedFruit: $selectedFruit)
                    ListItem(iconName: "pear", itemName: "Pear", price: 100, selectedFruit: $selectedFruit)
                }
                Section {
                    ActionItem(selectedFruit: selectedFruit, fruitCounters: $fruitCounters)
                }
                Section {
                    PickerItem(flag: $flag, tip: $tip)
                }
                Section {
                    HStack {
                        Text("Total Price")
                            .bold()
                        Spacer()
                        Text(String(format: "$%.2f", totalPrice))
                            .bold()
                    }
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
    
    @Binding var selectedFruit: String?
    
    var body: some View {
        HStack {
            Image(iconName)
                .imageScale(.medium)
            Text(itemName)
            Spacer()
            Text("$\(price)")
        }
        .padding()
        .background(selectedFruit == itemName ? Color.gray.opacity(0.2) : Color.clear)
        .cornerRadius(8)
        .foregroundStyle(Color("theme"))
        .contentShape(Rectangle())
        .onTapGesture {
            selectedFruit = itemName
        }
    }
}

struct ActionItem : View {
    
    var selectedFruit: String?
    @Binding var fruitCounters: [String: Int]
    
    // .alert modifier for user input validation feedback
    @State private var showAlert: Bool = false
    
    private var currentCount: Int {
        guard let selectedFruit = selectedFruit else { return 0 }
        return fruitCounters[selectedFruit] ?? 0
    }
    
    var body : some View {
        // Stepper replaces manual +/- buttons for quantity control
        ZStack(alignment: .trailing) {
            Stepper("Quantity: \(currentCount)", value: Binding(
                get: { currentCount },
                set: { newValue in
                    if let fruit = selectedFruit {
                        fruitCounters[fruit] = newValue
                    }
                }
            ), in: 0...99)
            
            if selectedFruit == nil {
                Color.clear
                    .frame(width: 94, height: 44)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showAlert = true
                    }
            }
        }
        .alert("No Fruit Selected", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please select a fruit from the list before adjusting the quantity.")
        }
    }
}

struct PickerItem : View {
    
    @Binding var flag : Bool
    @Binding var tip: Int
    var tipOptions : [Int] = [10, 15, 20, 25]
    
    var body : some View {
        VStack {
            Toggle("Add a Tip?", isOn: $flag)
            
            if flag {
                Picker("Tip Percentage", selection: $tip) {
                    ForEach(tipOptions, id: \.self) { option in Text("\(option)%")
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.top, 8)
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
