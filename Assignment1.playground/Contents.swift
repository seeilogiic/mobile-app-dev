import UIKit

// 5 data items
var products_and_prices: [(String, Double)] = []
products_and_prices.append(("Shampoo", 9.99))
products_and_prices.append(("Toothpaste", 4.99))
products_and_prices.append(("Soap", 2.99))
products_and_prices.append(("Toothbrush", 19.99))
products_and_prices.append(("Razor", 14.99))

// summary function
func summarizePrices(_ products: [(String, Double)]) -> (min: Double, max: Double) {
    var minVal = products[0].1
    var maxVal = products[0].1
    
    for product in products {
        if product.1 < minVal { minVal = product.1 }
        if product.1 > maxVal { maxVal = product.1 }
    }
    return (min: minVal, max: maxVal)
}

print(summarizePrices(products_and_prices))

// filter function with closure
let affordableProducts = products_and_prices.filter { $0.1 < 10.00 }
print(affordableProducts)
