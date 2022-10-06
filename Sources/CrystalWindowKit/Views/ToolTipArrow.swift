//
//  File.swift
//  
//
//  Created by Robert Cole on 10/5/22.
//

import SwiftUI

struct ToolTipArrow: Shape {
    var toolTipDirection: Edge
    var toolTipSpacing: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: toolTipSpacing / 2, y: toolTipSpacing / 2))

        switch toolTipDirection {
        case .top:
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: toolTipSpacing, y: 0))
        case .leading:
            path.addLine(to: CGPoint(x: 0, y: toolTipSpacing))
            path.addLine(to: CGPoint(x: 0, y: 0))
        case .bottom:
            path.addLine(to: CGPoint(x: toolTipSpacing, y: toolTipSpacing))
            path.addLine(to: CGPoint(x: 0, y: toolTipSpacing))
        case .trailing:
            path.addLine(to: CGPoint(x: toolTipSpacing, y: toolTipSpacing))
            path.addLine(to: CGPoint(x: toolTipSpacing, y: 0))
        }

        path.closeSubpath()

        return path
    }
}
