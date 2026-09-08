//
//  ProductList.swift
//  SwiftUIDemo
//
//  Created by user301385 on 9/8/26.
//

import SwiftUI

struct ProductList: View {
    @State private var products: [Product] = []
    
    var body: some View {
        NavigationStack {
            List(products) { prod in
                NavigationLink(value: prod) {
                    HStack {
                        Text("\(prod.name)")
                        Spacer()
                        Text("\(prod.color)")
                    }
                }
            }
            .navigationTitle(Text("Product List:"))
            .navigationDestination(for: Product.self) {
                selectedItem in
                ProductDetails(product: selectedItem)
            }
        }
        .task {
            loadData()
        }
    }
    func loadData() {
        products = [
            Product(id: 101, name: "Banana", productNumber: "123", color: "Yellow", listPrice: 0.49),
            Product(id: 102, name: "Apple", productNumber: "456", color: "Red", listPrice: 1.50),
            Product(id: 103, name: "Pear", productNumber: "789", color: "Green", listPrice: 1.09),
            Product(id: 104, name: "Clementine", productNumber: "159", color: "Orange", listPrice: 0.29),
        ]
    }
}

