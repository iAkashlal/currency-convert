//
//  CurrencyListView.swift
//  Swap Money
//
//  Created by Akashlal Bathe on 29/09/24.
//

import SwiftUI

struct CurrencyListView: View {
    @State var viewModel: CurrencyConvertVM!
    
    @State private var inputValue: String = "100" // Default input value
    @State private var pinnedCurrencies: Set<String> = [] // Holds pinned currencies
    @State private var rates: [String: Double] = [
        "USD": 1.0, "EUR": 0.85, "JPY": 110.0, "GBP": 0.75, "INR": 74.0, // Sample rates
        "CAD": 1.2, "AUD": 1.35, "CHF": 0.92
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Input Bar
            HStack(spacing: 0) {
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
                ForEach(pinnedAndUnpinnedCurrencies(), id: \.self) { currency in
                    CurrencyRowView(
                        currency: currency,
                        isPinned: pinnedCurrencies.contains(currency),
                        amount: Double(inputValue) ?? 0.0,
                        pinAction: {
                            togglePin(for: currency)
                        },
                        reverseCurrencyAction: {
                            viewModel.updateBaseCurrency(with: currency)
                        }
                    )
                }
            }
        }
    }
    
    // Function to toggle pin/unpin currencies
    private func togglePin(for currency: String) {
        if pinnedCurrencies.contains(currency) {
            pinnedCurrencies.remove(currency)
        } else {
            pinnedCurrencies.insert(currency)
        }
    }
    
    // Function to return pinned currencies at the top followed by unpinned
    private func pinnedAndUnpinnedCurrencies() -> [String] {
        let unpinnedCurrencies = rates.keys.filter { !pinnedCurrencies.contains($0) }.sorted()
        let pinnedCurrencyArray = pinnedCurrencies.sorted()
        return pinnedCurrencyArray + unpinnedCurrencies
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
        }
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
    CurrencyListView()
}
