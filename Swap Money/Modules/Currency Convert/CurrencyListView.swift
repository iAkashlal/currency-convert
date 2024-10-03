import SwiftUI

struct CurrencyListView: View {
    @StateObject var viewModel: CurrencyConvertVM

    @Namespace private var animationNamespace
    @State private var showSwapText: Bool = true
    @FocusState private var isInputFocused: Bool  // Focus state to control keyboard dismissal

    @State private var currencyRowRects: [String: CGRect] = [:]

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
                            .identified(by: "BaseCurrencyCapsule")
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
                            .identified(by: "CurrencyRow-\(currency)")
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
        .onPreferenceChange(ViewIdentifierKey.self) { preferences in
            for (key, value) in preferences {
                currencyRowRects[key] = value
            }
        }
    }

    private func getRectForCurrencyRow(currency: String) -> CGRect {
        return currencyRowRects["CurrencyRow-\(currency)"] ?? .zero
    }

    private func getRectForBaseCurrency() -> CGRect {
        return currencyRowRects["BaseCurrencyCapsule"] ?? .zero
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
                .identified(by: "CurrencyRow-\(currency)")
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
                    .position(x: startRect.midX, y: startRect.midY)
                    .animation(.easeInOut(duration: 0.5), value: animationInProgress)
            }
        }
    }
}

#Preview {
    CurrencyListView(viewModel: CurrencyConvertVM())
}

struct ViewIdentifierKey: PreferenceKey {
    typealias Value = [String: CGRect]

    static var defaultValue: [String: CGRect] = [:]

    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct ViewIdentifier: ViewModifier {
    let id: String

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: ViewIdentifierKey.self, value: [id: proxy.frame(in: .global)])
                }
            )
    }
}

extension View {
    func identified(by id: String) -> some View {
        self.modifier(ViewIdentifier(id: id))
    }
}
