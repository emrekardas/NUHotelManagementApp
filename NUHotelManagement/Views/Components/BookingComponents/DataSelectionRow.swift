//
//  DataSelectionRow.swift
//  NUHotelManagement
//
//  Created by Emre on 16/12/2024.
//

import SwiftUI

// Helper View
struct DateSelectionRow: View {
    let title: String
    @Binding var date: Date
    let range: PartialRangeFrom<Date>
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            DatePicker(
                "",
                selection: $date,
                in: range,
                displayedComponents: .date
            )
        }
    }
}
