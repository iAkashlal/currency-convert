//
//  RoundedCornersShape.swift
//  Swap Money
//
//  Created by Akashlal Bathe on 01/10/24.
//

import SwiftUI

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
