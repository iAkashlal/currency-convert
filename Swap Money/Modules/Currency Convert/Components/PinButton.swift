//
//  PinButton.swift
//  Swap Money
//
//  Created by Akashlal Bathe on 01/10/24.
//

import SwiftUI

struct PinButton: View {
    let isPinned: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isPinned ? "pin.fill" : "pin")
                .foregroundColor(isPinned ? .yellow : .gray)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
