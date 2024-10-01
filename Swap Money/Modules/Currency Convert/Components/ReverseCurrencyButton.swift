//
//  ReverseCurrencyButton.swift
//  Swap Money
//
//  Created by Akashlal Bathe on 01/10/24.
//

import SwiftUI

struct ReverseCurrencyButton: View {
    @Binding var showSwapText: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.callout)
                    .foregroundColor(.gray)

                if showSwapText {
                    Text("Swap")
                        .font(.callout)
                        .foregroundColor(.gray)
                        .transition(.opacity)
                }
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 12)
            .background(Color(.systemGray5))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
