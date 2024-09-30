//
//  CurrencyListView.swift
//  Swap Money
//
//  Created by Akashlal Bathe on 29/09/24.
//

import SwiftUI

struct CurrencyListView: View {
    @StateObject var viewModel: CurrencyConvertVM
    @State private var inputValue: String = "1"
    
    var body: some View {
        VStack() {
            // Input Bar
            HStack() {
                // Input TextField
                TextField("Enter amount", text: $inputValue)
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedCornersShape(radius: 8, corners: [.topLeft, .bottomLeft])) // Round only left corners
                    .frame(maxWidth: .infinity)

                // Base Currency Capsule
                Text(viewModel.baseCurrency)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .clipShape(RoundedCornersShape(radius: 8, corners: [.topRight, .bottomRight])) // Round only right corners
            }
            .padding()
            
            // List of currencies
            List {
                ForEach(viewModel.currencies, id: \.self) { currency in
                    CurrencyRowView(
                        currency: currency,
                        isPinned: viewModel.isFavourite(currency: currency),
                        amount: viewModel.getValue(for: currency, value: inputValue),
                        pinAction: {
                            viewModel.toggleFavourite(for: currency)
                        },
                        reverseCurrencyAction: {
                            self.inputValue = "\(viewModel.updateBaseCurrencyAndReturnValue(with: currency, value: Double(inputValue) ?? 0.0))"
                        }
                    )
                }
            }
        }
    }
    
    
}

struct CurrencyRowView: View {
    var currency: String
    var isPinned: Bool
    var amount: Double
    var pinAction: () -> Void
    var reverseCurrencyAction: () -> Void
    
    var body: some View {
        HStack {
            // Pin Button
            Button(action: pinAction) {
                Image(systemName: isPinned ? "pin.fill" : "pin")
                    .foregroundColor(isPinned ? .yellow : .gray)
            }
            .buttonStyle(PlainButtonStyle())  // Prevent default button interaction style

            
            // Currency Code
            Text(currency)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.green))
            
            Spacer()
            
            // Converted Currency Value
            Text(String(format: "%.2f", amount))
                .font(.title3)
                .padding(.trailing, 8)
            
            // Reverse Base Currency Button (Emoji Style)
            Button(action: reverseCurrencyAction) {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.callout)
                    .frame(width: 15)
                    .padding()
                    .background(Color.orange)
                    .clipShape(Circle())
                    .foregroundColor(.white)
            }
            .buttonStyle(PlainButtonStyle())  // Prevent default button interaction style

        }
        .contentShape(Rectangle()) // This ensures that only the actual content is tappable, not the whole HStack by default.
    }
}


struct RoundedCornersShape: Shape {
    var radius: CGFloat = 10.0
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    CurrencyListView(viewModel: CurrencyConvertVM(coordinator: nil, currencyService: nil))
}
