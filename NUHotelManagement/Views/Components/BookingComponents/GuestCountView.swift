//
//  GuestCountView.swift
//  NUHotelManagement
//
//  Created by Emre on 16/12/2024.
//

import SwiftUI

struct GuestCountView: View {
    @Binding var numberOfGuests: Int
    let maxCapacity: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Guests").font(.headline)
            
            HStack {
                Text("Number of Guests")
                Spacer()
                Button(action: { if numberOfGuests > 1 { numberOfGuests -= 1 } }) {
                    Image(systemName: "minus.circle.fill").foregroundColor(.blue)
                }
                Text("\(numberOfGuests)").frame(width: 40, alignment: .center)
                Button(action: { if numberOfGuests < maxCapacity { numberOfGuests += 1 } }) {
                    Image(systemName: "plus.circle.fill").foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}
