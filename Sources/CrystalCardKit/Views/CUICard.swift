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

import CUIPreviewKit
import CrystalButtonKit
import CrystalViewUtilities
import SwiftUI

/// A stylized card that displays some content and provides a control for closing.
public struct CUICard<Icon, Content>: _CUIStylizedCard where Icon: View, Content: View {
    public typealias Control = CUICard<Icon, Content>
    public typealias Card = CUICard<Icon, Content>

    public var control: CUIExpandableButton<Icon, Content>

    /// Creates a card using the icon and the content provided.
    /// - Parameters:
    ///   - icon: View that is displayed as an icon.
    ///   - content: The content that will be displayed when the button is expanded.
    ///   - closeAction: Action that will be performed when the close button is pressed.
    ///         If this action is not provided, the close button will not be shown.
    public init(
        @ViewBuilder icon: () -> Icon,
        @ViewBuilder content: () -> Content,
        closeAction: CUIAction? = nil
    ) {
        control = CUIExpandableButton(
            expanded: .constant(true),
            icon: icon,
            content: content,
            action: closeAction
        )
        .hideCloseButton(closeAction == nil)
    }

    public var body: some View {
        control
    }
}

public extension CUICard where Icon == CUISFSymbolIcon {
    /// Creates card, using a SF Symbol as the icon and the content provided.
    /// - Parameters:
    ///   - sfSymbolName: The name of the SF Symbol to use as the icon.
    ///   - content: The content that will be displayed when the button is expanded.
    ///   - action: Action that will be performed when the close button is pressed.
    ///         If this action is not provided, the close button will not be shown.
    init(
        sfSymbolName: String,
        @ViewBuilder content: () -> Content,
        closeAction: CUIAction? = nil
    ) {
        control = CUIExpandableButton(
            expanded: .constant(true),
            sfSymbolName: sfSymbolName,
            content: content,
            action: closeAction
        )
        .hideCloseButton(closeAction == nil)
    }
}

public extension CUICard where Icon == EmptyView {
    /// Creates card, using the content provide.
    ///
    /// This is a conveneince constructor that creates a window without a header.
    /// - Parameters:
    ///   - content: The content that will be displayed when the button is expanded.
    ///   - action: Action that will be performed when the close button is pressed.
    ///         If this action is not provided, the close button will not be shown.
    init(
        @ViewBuilder content: () -> Content
    ) {
        control = CUIExpandableButton(
            expanded: .constant(true),
            icon: { EmptyView() },
            content: content
        )
        .hideHeader()
    }
}

struct CUICard_Previews: PreviewProvider {
    static var previews: some View {
        CUICenteredPreview(title: "CUIWindow") {
            VStack {
                CUICaptionedView("Custom Icon Init") {
                    CUICard {
                        Rectangle()
                            .foregroundColor(.black)
                            .frame(
                                width: 10,
                                height: 10
                            )
                    } content: {
                        Text(CUILoremIpsum.words(8))
                            .padding()
                            .frame(width: 200)
                    } closeAction: {
                        print("button pressed")
                    }
                }

                CUICaptionedView("SF Symbol Init") {
                    CUICard(sfSymbolName: "doc.fill") {
                        Text(CUILoremIpsum.words(8))
                            .padding()
                            .frame(width: 200)
                    } closeAction: {
                        print("button pressed")
                    }
                }

                CUICaptionedView("No Header Init") {
                    CUICard {
                        Text(CUILoremIpsum.words(8))
                            .padding()
                            .frame(width: 200)
                    }
                }

                CUICaptionedView(".title(...) & .subtitle(...)") {
                    CUICard(sfSymbolName: "doc.fill") {
                        Text(CUILoremIpsum.words(8))
                            .padding()
                            .frame(width: 200)
                    }
                    .title("Title")
                    .subtitle("Subtitle")
                }
            }
        }
    }
}
