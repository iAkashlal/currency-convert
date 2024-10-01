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
    @FocusState private var isInputFocused: Bool  // Focus state to control keyboard dismissal
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Input Bar
                HStack(spacing: 0) {
                    // Input TextField
                    TextField("Enter amount", text: $viewModel.inputValue)
                        .keyboardType(.decimalPad)
                        .focused($isInputFocused)  // Attach focus state to the TextField
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedCornersShape(radius: 8, corners: [.topLeft, .bottomLeft])) // Round only left corners
                        .frame(maxWidth: .infinity)
                        .onChange(of: viewModel.inputValue) { _ in
                            viewModel.validateInput()
                        }
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer() // Push the Done button to the right
                                Button("Done") {
                                    isInputFocused = false  // Dismiss the keyboard
                                }
                            }
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
                
                if viewModel.isLoading {
                    // Show loading spinner
                    ProgressView("Loading currencies...")
                        .padding(.top, 20)
                    Spacer()
                } else {
                    // List of currencies
                    List {
                        ForEach(viewModel.currencies, id: \.self) { currency in
                            CurrencyRowView(
                                currency: currency,
                                isPinned: viewModel.isFavourite(currency: currency),
                                amount: viewModel.getValue(for: currency),
                                pinAction: {
                                    withAnimation {
                                        viewModel.toggleFavourite(for: currency)
                                    }
                                },
                                reverseCurrencyAction: {
                                    viewModel.swapButtonTapped(for: currency)
                                }, showSwapText: $showSwapText
                            )
                        }
                        .animation(.default, value: viewModel.currencies)
                    }
                    .padding(.top, 0)
                }
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
        .contentShape(Rectangle())  // Makes the entire VStack tappable
        .onTapGesture {
            isInputFocused = false
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
            PinButton(
                isPinned: isPinned,
                action: pinAction
            )
            Text(currency)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.vertical, 2)
                .padding(.horizontal, 8)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.green))
            Spacer()
            Text(amount, format: .currency(code: currency))
                .font(.title3)
                .foregroundStyle(.primary)
            ReverseCurrencyButton(
                showSwapText: $showSwapText,
                action: reverseCurrencyAction
            )
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle()) // This ensures that only the actual content is tappable, not the whole HStack by default.
    }
}

#Preview {
    CurrencyListView(viewModel: CurrencyConvertVM())
}
