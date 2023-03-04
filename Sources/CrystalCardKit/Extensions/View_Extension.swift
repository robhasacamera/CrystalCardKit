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

#if os(iOS)

extension View {
    // TODO: Add option to style the window
    /// Presents a card on top of the view heirarchy with the content provided/
    ///
    /// - Parameters:
    ///   - isPresented: A binding to a Boolean value that determines whether to present the card.
    ///   - dimmed: A Boolean that indicates whether the background should be dimmed with a transparent color. Default value is `true`.
    ///   - tapBackgroundToDismiss: A Boolean to indicate if the tapping the background should dismiss thecard. Default value is `true`. If this is set to `false`, you will still not be able to interact with the views behind the presented card, even when fully visible.
    ///   - onDismiss: The closure to execute when dismissing the card.
    ///   - content: The content to display within the card.
    func presentCard<Content>(
        isPresented: Binding<Bool>,
        dimmed: Bool = true,
        tapBackgroundToDismiss: Bool = true,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View where Content: View {
        modifier(FullScreenAnimationChainingModifier(
            isPresented: isPresented,
            dimmed: dimmed,
            tapBackgroundToDismiss: tapBackgroundToDismiss,
            onDismiss: onDismiss
        ) {
            CUICard { content() }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
        })
    }

    // TODO: Add option to style the tooltip
    /// Presents a tooltip anchored to the this view.
    ///
    /// When presented, the tooltip will be anchored and pointed to this view.
    ///
    /// - Parameters:
    ///   - isPresented: A binding to a Boolean value that determines whether to present the tooltip.
    ///   - presentationEdge: The edge that the tooltip will be presented from. When set, the tooltip will be displayed along the provided edge, regardless of the available room. When `nil`, the tooltip will default to `.top`, unless there is not enough room available above the target view `.bottom` will be used instead.
    ///   - dimmed: A Boolean that indicates whether the background should be dimmed with a transparent color. Default value is `true`. When dimmed, this view will be excluded from being dimmed.
    ///   - tapBackgroundToDismiss: A Boolean to indicate if the tapping the background should dismiss the tooltip. Default value is `true`. If this is set to `false`, you will still not be able to interact with the views behind the presented tooltip, even when fully visible.
    ///   - onDismiss: The closure to execute when dismissing the tooltip.
    ///   - content: The content to display within the tooltip.
    func presentToolTip<Content>(
        isPresented: Binding<Bool>,
        presentationEdge: Edge? = nil,
        dimmed: Bool = true,
        tapBackgroundToDismiss: Bool = true,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View where Content: View {

        // TODO: Need to document the difference between this and a regular goemtry reader. I think it's that a regular geomtry reader provides the geometry for a parent while this one provides geometry for the child inside of it. So it can use it's own geometry on itself.
        CUIChildGeometryReader(id: "id") { proxy in
            modifier(FullScreenAnimationChainingModifier(
                isPresented: isPresented,
                dimmed: false,
                tapBackgroundToDismiss: tapBackgroundToDismiss,
                onDismiss: onDismiss
            ) {
                if dimmed {
                    Color.black
                        .frame(width: UIScreen.width, height: UIScreen.height)
                        .offset(y: 10.5)
                        .opacity(0.5)
//                        .ignoresSafeArea()
                        .reverseMask {
                            self
                                .position(
                                    x: {
                                        guard let frame = proxy?.frame(in: .global) else {
                                            return 0
                                        }

                                        return frame.midX
                                    }(),
                                    y: {
                                        guard let frame = proxy?.frame(in: .global) else {
                                            return 0
                                        }

                                        return frame.midY
                                    }()
                                )
//                                .ignoresSafeArea()

                            ToolTipPresentor(
                                targetFrame: proxy?.frame(in: .global) ?? .zero,
                                presentationEdge: presentationEdge
                            ) {
                                content()
                            }
                        }
                        .onTapGesture {
                            if tapBackgroundToDismiss {
                                isPresented.wrappedValue = false
                            }
                        }
                }

                ToolTipPresentor(
                    targetFrame: proxy?.frame(in: .global) ?? .zero,
                    presentationEdge: presentationEdge
                ) {
                    content()
                }
                .animation(.linear, value: isPresented.wrappedValue)
            })
        }
    }
}

struct PresentCard_Previews: PreviewProvider {
    struct Preview: View {
        @State
        var showFullScreen = false

        var body: some View {
            ZStack {
                Circle().foregroundColor(.yellow)
                Button("showWindow=\(showFullScreen ? "true" : "false")") {
                    showFullScreen.toggle()
                }
                .presentCard(isPresented: $showFullScreen) {
                    ZStack {
                        Button("showWindow=\(showFullScreen ? "true" : "false")") {
                            showFullScreen.toggle()
                        }
                        .padding()
                    }
                }
            }
        }
    }

    static var previews: some View {
        Preview()
    }
}

struct PresentToolTip_Previews: PreviewProvider {
    struct Preview: View {
        @State
        var showTopLeading = false
        @State
        var showTopTrailing = false
        @State
        var showBottomLeading = false
        @State
        var showBottomTrailing = false
        @State
        var showCenter = false

        var body: some View {
            VStack {
                HStack {
                    CUIButton(title: "tl") {
                        showTopLeading.toggle()
                    }
                    .presentToolTip(
                        isPresented: $showTopLeading
                    ) {
                        ZStack {
                            Button("hide tooltip") {
                                showTopLeading.toggle()
                            }
                            .padding()
                        }
                    }

                    Spacer()

                    CUIButton(title: "tt") {
                        showTopTrailing.toggle()
                    }
                    .presentToolTip(isPresented: $showTopTrailing) {
                        ZStack {
                            Button("hide tooltip") {
                                showTopTrailing.toggle()
                            }
                            .padding()
                        }
                    }
                }

                Spacer()

                CUIButton(title: "c") {
                    showCenter.toggle()
                }
                .presentToolTip(isPresented: $showCenter) {
                    ZStack {
                        Button("hide tooltip") {
                            showCenter.toggle()
                        }
                        .padding()
                    }
                }

                Spacer()

                HStack {
                    CUIButton(title: "bl") {
                        showBottomLeading.toggle()
                    }
                    .presentToolTip(isPresented: $showBottomLeading) {
                        ZStack {
                            Button("hide tooltip") {
                                showBottomLeading.toggle()
                            }
                            .padding()
                        }
                    }

                    Spacer()

                    CUIButton(title: "bt") {
                        showBottomTrailing.toggle()
                    }
                    .presentToolTip(isPresented: $showBottomTrailing) {
                        ZStack {
                            Button("hide tooltip") {
                                showBottomTrailing.toggle()
                            }
                            .padding()
                        }
                    }
                }
            }
            .padding(.standardSpacing)

        }
    }

    static var previews: some View {
        Preview()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}

struct PresentToolTipForcedEdges_Previews: PreviewProvider {
    struct Preview: View {
        @State
        var showLeading = false
        @State
        var showTrailing = false
        @State
        var showTop = false
        @State
        var showBottom = false

        var body: some View {
            ZStack {
                Spacer()
                    .frame(width: UIScreen.width, height: UIScreen.height)
                    .background(.linearGradient(colors: [.red, .blue, .yellow], startPoint: .top, endPoint: .bottom))

                VStack {
                    CUIButton(title: "leading") {
                        showLeading.toggle()
                    }
                    .presentToolTip(
                        isPresented: $showLeading,
                        presentationEdge: .leading
                    ) {
                        ZStack {
                            Button("hide tooltip") {
                                showLeading.toggle()
                            }
                            .padding()
                        }
                    }

                    CUIButton(title: "trailing") {
                        showTrailing.toggle()
                    }
                    .presentToolTip(
                        isPresented: $showTrailing,
                        presentationEdge: .trailing
                    ) {
                        ZStack {
                            Button("hide tooltip") {
                                showTrailing.toggle()
                            }
                            .padding()
                        }
                    }

                    CUIButton(title: "top") {
                        showTop.toggle()
                    }
                    .presentToolTip(
                        isPresented: $showTop,
                        presentationEdge: .top
                    ) {
                        ZStack {
                            Button("hide tooltip") {
                                showTop.toggle()
                            }
                            .padding()
                        }
                    }

                    CUIButton(title: "bottom") {
                        showBottom.toggle()
                    }
                    .presentToolTip(
                        isPresented: $showBottom,
                        presentationEdge: .bottom
                    ) {
                        ZStack {
                            Button("hide tooltip") {
                                showBottom.toggle()
                            }
                            .padding()
                        }
                    }
                }
            }
        }
    }

    static var previews: some View {
        Preview()
//            .previewInterfaceOrientation(.landscapeLeft)
        Preview()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}

#endif
