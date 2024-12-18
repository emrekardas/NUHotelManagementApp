//
//  PriceDetailsView.swift
//  NUHotelManagement
//
//  Created by Emre on 16/12/2024.
//

import SwiftUI

struct PriceDetailsView: View {
    let numberOfNights: Int
    let pricePerNight: Double
    let totalPrice: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Price Details").font(.headline)
            
            VStack(spacing: 8) {
                HStack {
                    Text("\(numberOfNights) nights × $\(Int(pricePerNight))")
                    Spacer()
                    Text("$\(Int(totalPrice))")
                }
                
                Divider()
                
                HStack {
                    Text("Total").fontWeight(.bold)
                    Spacer()
                    Text("$\(Int(totalPrice))").fontWeight(.bold)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}
