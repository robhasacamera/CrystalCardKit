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
import CrystalViewUtilities
import SwiftUI

/// A stylized tooltip that displays some content and has an arrow that can point towards content.
///
/// This is a wrapper for ``CUICard`` that provides an options to display an arrow.
public struct CUIToolTip<Icon, Content>: CUIStylizedToolTip, _CUIStylizedCard where Icon: View, Content: View {
    public typealias Control = CUIToolTip<Icon, Content>
    public typealias Card = CUIToolTip<Icon, Content>

    public var control: CUICard<Icon, Content>
    var presentationEdge: Edge

    public var arrowWidth: CGFloat = .standardSpacing * 2
    public var arrowOffset: CGFloat = 0

    /// Creates a tooltip using the icon and the content provided.
    ///
    /// - Parameters:
    ///   - presentationEdge: The edge that the tooltip will be presented from. The inverted edge will display the arrow.
    ///   - icon: View that is displayed as an icon.
    ///   - content: The content that will be displayed in the tooltip.
    ///   - closeAction: Action that will be performed when the close button is pressed. If an action is not provided, the close button will not be shown.
    public init(
        presentationEdge: Edge,
        @ViewBuilder icon: () -> Icon,
        @ViewBuilder content: () -> Content,
        closeAction: CUIAction? = nil
    ) {
        self.presentationEdge = presentationEdge
        control = CUICard(icon: icon, content: content, closeAction: closeAction)
            .hideBackground()
    }

    public var body: some View {
        control
            .padding(presentationEdge.inverted, arrowWidth / 2)
            .background(
                ToolTipShape(
                    presentationEdge: presentationEdge,
                    arrowWidth: arrowWidth,
                    arrowOffset: arrowOffset,
                    cornerRadius: .cornerRadius
                )
                .foregroundStyle(.thinMaterial)
            )
//            .ignoresSafeArea()
    }
}

public extension CUIToolTip where Icon == EmptyView {
    /// Creates a tooltip using the content provided.
    ///
    /// The header for this
    ///
    /// - Parameters:
    ///   - presentationEdge: The edge that the tooltip will be presented from. The inverted edge will display the arrow.
    ///   - content: The content that will be displayed in the tooltip.
    ///   - closeAction: Action that will be performed when the close button is pressed. If an action is not provided, the close button will not be shown.
    init(
        presentationEdge: Edge,
        @ViewBuilder content: () -> Content,
        closeAction: CUIAction? = nil
    ) {
        self.init(presentationEdge: presentationEdge, icon: { EmptyView() }, content: content, closeAction: closeAction)
        control = control.hideHeader()
    }
}

public extension CUIToolTip where Icon == CUISFSymbolIcon {
    /// Creates window, using a SF Symbol as the icon and the content provided.
    /// - Parameters:
    ///   - sfSymbolName: The name of the SF Symbol to use as the icon.
    ///   - content: The content that will be displayed when the button is expanded.
    ///   - action: Action that will be performed when the close button is pressed.
    ///         If this action is not provided, the close button will not be shown.
    init(
        presentationEdge: Edge,
        sfSymbolName: String,
        @ViewBuilder content: () -> Content,
        closeAction: CUIAction? = nil
    ) {
        self.presentationEdge = presentationEdge
        control = CUICard(sfSymbolName: sfSymbolName, content: content, closeAction: closeAction)
            .hideBackground()
    }
}

// TODO: Move to view utilities
extension Edge {
    var inverted: Edge.Set {
        switch self {
        case .top:
            return .bottom
        case .leading:
            return .trailing
        case .bottom:
            return .top
        case .trailing:
            return .leading
        }
    }
}

struct CUIToolTip_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Spacer()
                .frame(width: UIScreen.width, height: UIScreen.height)
                .background(.linearGradient(colors: [.red, .blue, .yellow], startPoint: .top, endPoint: .bottom))

            VStack {
                CUIToolTip(presentationEdge: .top) {
                    Text("I'm a tooltip")
                        .padding()
                }
                .arrowOffset(20)

                CUIToolTip(presentationEdge: .bottom) {
                    Text("I'm a tooltip")
                        .padding()
                }
                CUIToolTip(presentationEdge: .leading) {
                    Text("I'm a tooltip")
                        .padding()
                }
                CUIToolTip(presentationEdge: .trailing) {
                    Text("I'm a tooltip")
                        .padding()
                }
            }
        }
    }
}
