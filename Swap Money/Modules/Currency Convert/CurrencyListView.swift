import SwiftUI

struct CurrencyListView: View {
    @StateObject var viewModel: CurrencyConvertVM

    @Namespace private var animationNamespace
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
                    ZStack {
                        if let animatedCurrency = viewModel.animatedCurrency {
                            Text(animatedCurrency)
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 8)
                                .background(RoundedRectangle(cornerRadius: 8).fill(Color.green))
                                .matchedGeometryEffect(id: animatedCurrency, in: animationNamespace)
                        }

                        Text(viewModel.baseCurrency)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 8)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.green))
                            .opacity(viewModel.animatedCurrency == nil ? 1 : 0)
                    }
                    Spacer()
                        .frame(width: 5)
                }
                .background(Color(.systemGray6))
                .clipShape(RoundedCornersShape(radius: 8, corners: [.topLeft, .bottomLeft, .topRight, .bottomRight])) // Round only left corners
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
                                    let startRect = getRectForCurrencyRow(currency: currency)
                                    viewModel.swapButtonTapped(for: currency, startRect: startRect)
                                }, showSwapText: $showSwapText,
                                animationNamespace: animationNamespace,
                                animationInProgress: viewModel.animationInProgress
                            )
                        }
                        .animation(.default, value: viewModel.currencies)
                    }
                    .padding(.top, 0)
                    .onAppear {
                        Task {
                            try? await Task.sleep(nanoseconds: 4_000_000_000) // 4 seconds in nanoseconds
                            withAnimation {
                                showSwapText = false
                            }
                        }
                    }
                }
            }
            .navigationTitle("swap.money")

            // Overlay for animated currency
            if let animatedCurrency = viewModel.animatedCurrency {
                CurrencyAnimationOverlay(
                    currency: animatedCurrency,
                    namespace: animationNamespace,
                    startRect: viewModel.animationStartRect,
                    endRect: getRectForBaseCurrency(),
                    animationInProgress: viewModel.animationInProgress
                )
            }
        }
        .contentShape(Rectangle())  // Makes the entire VStack tappable
        .onTapGesture {
            isInputFocused = false
        }
    }

    private func getRectForCurrencyRow(currency: String) -> CGRect {
        // Calculate and return the CGRect for the given currency row
        // This needs to be implemented based on your layout
        return .zero
    }

    private func getRectForBaseCurrency() -> CGRect {
        // Calculate and return the CGRect for the base currency capsule
        // This needs to be implemented based on your layout
        return .zero
    }
}

struct CurrencyRowView: View {
    var currency: String
    var isPinned: Bool
    var amount: Double
    var pinAction: () -> Void
    var reverseCurrencyAction: () -> Void
    @Binding var showSwapText: Bool

    var animationNamespace: Namespace.ID
    var animationInProgress: Bool

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
                .matchedGeometryEffect(id: currency, in: animationNamespace)
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

struct CurrencyAnimationOverlay: View {
    var currency: String
    var namespace: Namespace.ID
    var startRect: CGRect
    var endRect: CGRect
    var animationInProgress: Bool

    var body: some View {
        GeometryReader { geometry in
            if animationInProgress {
                Text(currency)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 8)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.green))
                    .matchedGeometryEffect(id: currency, in: namespace)
//                    .position(startRect.center(in: geometry.frame(in: .global)))
                    .animation(.easeInOut(duration: 0.5), value: animationInProgress)
            }
        }
    }
}

#Preview {
    CurrencyListView(viewModel: CurrencyConvertVM())
}
