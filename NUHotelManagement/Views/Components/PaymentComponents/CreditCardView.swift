import SwiftUI

struct CreditCardView: View {
    @Binding var cardNumber: String
    @Binding var cardHolderName: String
    @Binding var expiryDate: String
    @Binding var cvv: String
    @State private var isCardFlipped = false
    
    var body: some View {
        VStack {
            // Kredi Kartı Görünümü
            ZStack {
                // Kart Ön Yüzü
                CreditCardFront(
                    cardNumber: cardNumber,
                    cardHolderName: cardHolderName,
                    expiryDate: expiryDate
                )
                .opacity(isCardFlipped ? 0 : 1)
                .rotation3DEffect(
                    .degrees(isCardFlipped ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )
                
                // Kart Arka Yüzü
                CreditCardBack(cvv: cvv)
                    .opacity(isCardFlipped ? 1 : 0)
                    .rotation3DEffect(
                        .degrees(isCardFlipped ? 0 : -180),
                        axis: (x: 0, y: 1, z: 0)
                    )
            }
            .frame(width: 320, height: 200)
            .onTapGesture {
                withAnimation(.spring()) {
                    isCardFlipped.toggle()
                }
            }
            
            // Input Alanları
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Card Number")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("1234 5678 9012 3456", text: $cardNumber)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: cardNumber) { newValue in
                            cardNumber = formatCardNumber(newValue)
                        }
                        .keyboardType(.numberPad)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Card Holder Name")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("JOHN DOE", text: $cardHolderName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textCase(.uppercase)
                }
                
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Expiry Date")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("MM/YY", text: $expiryDate)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: expiryDate) { newValue in
                                expiryDate = formatExpiryDate(newValue)
                            }
                            .keyboardType(.numberPad)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("CVV")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("123", text: $cvv)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: cvv) { newValue in
                                if newValue.count > 3 {
                                    cvv = String(newValue.prefix(3))
                                }
                                if !newValue.isEmpty {
                                    isCardFlipped = true
                                }
                            }
                            .keyboardType(.numberPad)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
        }
    }
    
    // Helper fonksiyonlar
    private func formatCardNumber(_ number: String) -> String {
        let cleaned = number.filter { $0.isNumber }
        var formatted = ""
        for (index, char) in cleaned.enumerated() {
            if index > 0 && index % 4 == 0 {
                formatted += " "
            }
            formatted.append(char)
        }
        return String(formatted.prefix(19))
    }
    
    private func formatExpiryDate(_ date: String) -> String {
        let cleaned = date.filter { $0.isNumber }
        var formatted = cleaned
        if cleaned.count > 2 {
            formatted.insert("/", at: formatted.index(formatted.startIndex, offsetBy: 2))
        }
        return String(formatted.prefix(5))
    }
}

// Yardımcı View'lar
struct CreditCardFront: View {
    let cardNumber: String
    let cardHolderName: String
    let expiryDate: String
    
    var body: some View {
        ZStack {
            // Kart Arka Planı
            RoundedRectangle(cornerRadius: 15)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
            
            VStack(alignment: .leading, spacing: 20) {
                // Chip ve Logo
                HStack {
                    Image(systemName: "creditcard.circle.fill")
                        .font(.largeTitle)
                    Spacer()
                    Image(systemName: "wave.3.right")
                        .font(.title)
                }
                
                // Kart Numarası
                Text(cardNumber.isEmpty ? "•••• •••• •••• ••••" : cardNumber)
                    .font(.title2)
                    .kerning(3)
                
                HStack {
                    // Kart Sahibi
                    VStack(alignment: .leading) {
                        Text("CARD HOLDER")
                            .font(.caption2)
                            .opacity(0.7)
                        Text(cardHolderName.isEmpty ? "YOUR NAME" : cardHolderName)
                            .font(.callout)
                    }
                    
                    Spacer()
                    
                    // Son Kullanma Tarihi
                    VStack(alignment: .leading) {
                        Text("EXPIRES")
                            .font(.caption2)
                            .opacity(0.7)
                        Text(expiryDate.isEmpty ? "MM/YY" : expiryDate)
                            .font(.callout)
                    }
                }
            }
            .foregroundColor(.white)
            .padding(20)
        }
    }
}

struct CreditCardBack: View {
    let cvv: String
    
    var body: some View {
        ZStack {
            // Kart Arka Planı
            RoundedRectangle(cornerRadius: 15)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
            
            VStack {
                // Manyetik Şerit
                Rectangle()
                    .fill(Color.black)
                    .frame(height: 50)
                    .padding(.top, 20)
                
                // CVV Alanı
                HStack {
                    Spacer()
                    ZStack(alignment: .trailing) {
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 200, height: 40)
                        
                        Text(cvv.isEmpty ? "CVV" : cvv)
                            .foregroundColor(.black)
                            .padding(.trailing, 10)
                    }
                    .padding(.trailing, 20)
                }
                
                Spacer()
            }
        }
    }
} 
