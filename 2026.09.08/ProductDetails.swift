//
//  ProductDetails.swift
//  SwiftUIDemo
//
//  Created by user301385 on 9/8/26.
//

import SwiftUI

struct ProductDetails: View {
    
    var product: Product

    var body: some View {
        @Bindable var empBinding = product
        
        VStack {
            Text("Fruit: \(product.name)")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Product ID: \(product.id)")
                .font(Font.title)
                .padding().textFieldStyle(.roundedBorder)
                .padding(5)
            Text("Product #: \(product.productNumber)")
                .font(Font.title)
                .padding().textFieldStyle(.roundedBorder)
                .padding(5)
            Text("Color: \(product.color)")
                .font(Font.title)
                .padding().textFieldStyle(.roundedBorder)
                .padding(5)
            Text("Price: $\(String(format: "%.2f", product.listPrice))")
                .font(Font.title)
                .padding().textFieldStyle(.roundedBorder)
                .padding(5)
        }
        .padding()
    }
    
}


#Preview {
    ContentView()
}

