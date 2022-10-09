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

import CrystalViewUtilities
import SwiftUI

struct ToolTipPresentor<Content>: View where Content: View {
    internal init(
        targetFrame: CGRect,
        presentationEdge: Edge? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.targetFrame = targetFrame
        self.presentationEdge = presentationEdge
        self.content = content()
    }

    let toolTipSpacing: CGFloat = .standardSpacing
    var toolTipArrowSize: CGFloat { toolTipSpacing * 2 }

    @State
    var size: CGSize = .zero

    var targetFrame: CGRect
    var presentationEdge: Edge?
    var content: Content

    var targetEdge: Edge {
        if let presentationEdge {
            return presentationEdge
        }

        let topScreenSpace = targetFrame.minY - toolTipSpacing * 2

        if topScreenSpace > size.height {
            return .top
        }

        let bottomScreenSpace = UIScreen.height - targetFrame.maxY - toolTipSpacing * 2

        if bottomScreenSpace > size.height {
            return .bottom
        }

        let leadingScreenSpace = targetFrame.minX - toolTipSpacing * 2

        if leadingScreenSpace > size.width {
            return .leading
        }

        let trailingScreenSpace = UIScreen.width - targetFrame.maxX - toolTipSpacing * 2

        if trailingScreenSpace > size.width {
            return .trailing
        }

        return .top
    }

    // Add animation to scale from center of target
    var body: some View {
        CUIToolTip(presentationEdge: targetEdge) {
            CUISizeReader(size: $size, id: "ToolTipContent") {
                content
            }
        }
        .arrowOffset({
            switch targetEdge {
            case .top: fallthrough
            case .bottom:
                let toolTipMidX = min(max(targetFrame.midX, toolTipSpacing + size.width / 2), UIScreen.width - toolTipSpacing - size.width / 2)

                return targetFrame.midX - toolTipMidX
            case .leading: fallthrough
            case .trailing:
                let toolTipMidY = min(max(targetFrame.minY, toolTipSpacing + size.height / 2), UIScreen.height - toolTipSpacing - size.height / 2)

                return targetFrame.minY - toolTipMidY
            }
        }())
        .arrowWidth(toolTipArrowSize)
        .position(
            // TODO: Need to take the safe area into account
            x: {
                let x: CGFloat

                switch targetEdge {
                case .top: fallthrough
                case .bottom:
                    x = targetFrame.midX
                case .leading:
                    x = targetFrame.minX - toolTipSpacing - size.width / 2
                case .trailing:
                    x = targetFrame.maxX + toolTipSpacing + size.width / 2
                }

                return min(max(x, toolTipSpacing + size.width / 2), UIScreen.width - toolTipSpacing - size.width / 2)
            }(),
            y: {
                let y: CGFloat

                switch targetEdge {
                case .top:
                    y = targetFrame.minY - toolTipSpacing - size.height / 2
                case .bottom:
                    y = targetFrame.maxY + toolTipSpacing + size.height / 2
                case .leading: fallthrough
                case .trailing:
                    y = targetFrame.midY
                }

                return min(max(y, toolTipSpacing + size.height / 2), UIScreen.height - toolTipSpacing - size.height / 2)
            }()
        )
        .ignoresSafeArea()
    }
}
