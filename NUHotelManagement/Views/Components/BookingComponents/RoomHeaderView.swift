//
//  RoomHeaderView.swift
//  NUHotelManagement
//
//  Created by Emre on 16/12/2024.
//

import SwiftUI

struct RoomHeaderView: View {
    let room: Room
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: room.detailImageUrls.first ?? "")) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle().foregroundColor(.gray.opacity(0.2))
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            HStack {
                Text(room.name)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Text("$\(Int(room.price))/night")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
        }
    }
}
