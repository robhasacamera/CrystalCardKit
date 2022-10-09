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

import CrystalButtonKit
import SwiftUI

public protocol CUIStylizedToolTip: CUIStylizedWindow where Control == ToolTip {
    associatedtype ToolTip: CUIStylizedToolTip

    var arrowOffset: CGFloat { get set }
    var arrowWidth: CGFloat { get set }

    /// Sets the offset for the arrow from center.
    ///
    /// The arrow defaults to the center of the tooltip.
    /// - Parameter offset: The offset to move the arrow from center.
    ///     A postive offset will more the arrow towards the leading side when using a vertical presentation edge.
    ///     A postive offset will more the arrow towards the top side when using a horizontal presentation edge.
    /// - Returns: Tooltip with the arrow offset from center
    func arrowOffset(_ offset: CGFloat) -> ToolTip

    /// Sets the width of the tooltip.
    ///
    /// The arrow's height will be half of the provided with.
    /// - Parameter width: The width for the arrow to be displayed.
    /// - Returns: Tooltip with the arrow adjusted to the provided width.
    func arrowWidth(_ width: CGFloat) -> ToolTip
}

public extension CUIStylizedToolTip {
    func arrowOffset(_ offset: CGFloat) -> ToolTip {
        var newSelf = self

        newSelf.arrowOffset = offset

        return newSelf as! Self.ToolTip
    }

    func arrowWidth(_ width: CGFloat) -> ToolTip {
        var newSelf = self

        newSelf.arrowWidth = width

        return newSelf as! Self.ToolTip
    }
}
