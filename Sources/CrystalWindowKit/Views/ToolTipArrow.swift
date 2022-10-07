//
// CrystalWindowKit
//
// MIT License
//
// Copyright (c) 2022 Robert Cole
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
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
