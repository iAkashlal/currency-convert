//
//  CurrencyListView.swift
//  Swap Money
//
//  Created by Akashlal Bathe on 29/09/24.
//

import SwiftUI

struct CurrencyListView: View {
    @StateObject var viewModel: CurrencyConvertVM
    
    @State private var showSwapText: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Input Bar
            HStack(spacing: 0) {
                // Input TextField
                TextField("Enter amount", text: $viewModel.inputValue)
                    .keyboardType(.decimalPad)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedCornersShape(radius: 8, corners: [.topLeft, .bottomLeft])) // Round only left corners
                    .frame(maxWidth: .infinity)
                    .onChange(of: viewModel.inputValue) { _, _ in
                        viewModel.validateInput()
                    }

                // Base Currency Capsule
                Text(viewModel.baseCurrency)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .clipShape(RoundedCornersShape(radius: 8, corners: [.topRight, .bottomRight])) // Round only right corners
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
            
            // Show error message
            if viewModel.showError {
                Text(viewModel.errorMessage ?? "Some error occured")
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
            }
            
            // List of currencies
            List {
                ForEach(viewModel.currencies, id: \.self) { currency in
                    CurrencyRowView(
                        currency: currency,
                        isPinned: viewModel.isFavourite(currency: currency),
                        amount: viewModel.getValue(for: currency),
                        pinAction: {
                            viewModel.toggleFavourite(for: currency)
                        },
                        reverseCurrencyAction: {
                            viewModel.updateBaseCurrency(to: currency)
                        }, showSwapText: $showSwapText
                    )
                }
            }
            .padding(.top, 0)
        }
        .navigationTitle("swap.money")
        .onAppear {
            // After 4 seconds, animate the disappearance of the text
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation {
                    showSwapText = false
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
    @Binding var showSwapText: Bool

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
                .padding(.vertical, 2)
                .padding(.horizontal, 8)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.green))
            
            Spacer()
            
            // Converted Currency Value
            Text(amount, format: .currency(code: currency))
                .font(.title3)
                .foregroundStyle(.primary)
            
            // Reverse Base Currency Button (Emoji Style)
            Button(action: reverseCurrencyAction) {
                HStack {
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.callout)
                        .foregroundColor(.gray)
                    
                    // Animate disappearance of "Swap" text
                    if showSwapText {
                        Text("Swap")
                            .font(.callout)
                            .foregroundColor(.gray)
                            .transition(.opacity)  // Smooth transition for the text
                    }
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 12)
                .background(Color(.systemGray5))
                .cornerRadius(8)
            }
            .padding(.vertical, 4)
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
