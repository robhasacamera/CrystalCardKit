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
    // TODO: Document
    func presentWindow<Content>(
        isPresented: Binding<Bool>,
        dimmed: Bool = true,
        tapBackgroundToDismiss: Bool = true,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View where Content: View {
        WindowPresentor(
            isPresented: isPresented,
            dimmed: dimmed,
            tapBackgroundToDismiss: tapBackgroundToDismiss,
            onDismiss: onDismiss
        ) {
            self
        } presentedContent: {
            content()
        }
    }

    // TODO: Document
    // TODO: Add anchor options (placement on view and on tooltip
    func presentToolTip<Content>(
        isPresented: Binding<Bool>,
        alignment: Alignment = .top,
        dimmed: Bool = true,
        tapBackgroundToDismiss: Bool = true,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View where Content: View {
        // TODO: Need to document the difference between this and a regular goemtry reader. I think it's that a regular geomtry reader provides the geometry for a parent while this one provides geometry for the child inside of it. So it can use it's own geometry on itself.
        CUIChildGeometryReader(id: "cui_tooltip_child") { proxy in
            self
                .presentFullScreen(isPresented: isPresented) {
                    ToolTipPresentor(
                        targetFrame: proxy?.frame(in: .global) ?? .zero,
                        content: CUIWindow { content() }
                    )
                    .overlay {
                        Text(
                            String(
                                format: "x=%.0f,y=%.0f",
                                proxy?.frame(in: .global).minX ?? 1,
                                proxy?.frame(in: .global).minY ?? 1
                            )
                        )
                    }
                }
        }
    }
}

// FIXME, This is working pretty well, still not sure why it's off by about 6 points vertically
struct ToolTipPresentor<Content>: View where Content: View {
    @State
    var size: CGSize = .zero

    var targetFrame: CGRect
    var content: Content

    let toolTipSpacing: CGFloat = 10

    var targetEdge: Edge {
        let topScreenSpace = targetFrame.minY - toolTipSpacing * 2

        if topScreenSpace > size.height {
            return .top
        }

        // TODO: Add buffer here
        let bottomScreenSpace = UIScreen.height - targetFrame.maxX - toolTipSpacing * 2

        if bottomScreenSpace > size.height {
            return .bottom
        }

        let leadingScreenSpace = targetFrame.minX - toolTipSpacing * 2

        if leadingScreenSpace > size.width {
            return .leading
        }

        let trailingScreenSpace = UIScreen.width - targetFrame.maxX - toolTipSpacing * 2

        if trailingScreenSpace > toolTipSpacing {
            return .trailing
        }

        return .top
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Spacer()
                .frame(width: UIScreen.width, height: UIScreen.height)

            CUISizeReader(size: $size, id: "1") {
                content

            }
            // FIXME: Still have no idea why everything is off by a few points (~6 points vertically), and sometimes half points
            // TODO: Do a lot of calculations regarding the frame to decide if the tooltip should be above or below and centered versus off center. Thinking that the arrow will always point to the center top/bottom of the target
            .offset(
                x: {
                    let x: CGFloat

                    switch targetEdge {
                    case .top: fallthrough
                    case .bottom:
                        // TODO: need to make sure this can actually fit on screen and adjust if not.
                        x = targetFrame.minX + (targetFrame.width - size.width) / 2
                    case .leading:
                        x = targetFrame.minX - toolTipSpacing - size.width
                    case .trailing:
                        x = targetFrame.maxX + toolTipSpacing
                    }

                    return min(max(x, toolTipSpacing), UIScreen.width - toolTipSpacing - size.width)
                }(),
                y: {
                    let y: CGFloat

                    switch targetEdge {
                    case .top:
                        y = targetFrame.minY - toolTipSpacing - size.height
                    case .bottom:
                        y = targetFrame.maxY + toolTipSpacing
                    case .leading: fallthrough
                    case .trailing:
                        // TODO: need to make sure this can actually fit on screen and adjust if not.
                        y = targetFrame.minY + (targetFrame.height - size.height) / 2
                    }

                    return min(max(y, toolTipSpacing), UIScreen.height - toolTipSpacing - size.height)
                }()
            )
            .overlay {
                Text(
                    String(
                        format: "x=%.0f,y=%.0f",
                        targetFrame.minX,
                        targetFrame.minY
                    )
                )
                .foregroundColor(.yellow)
            }
        }
    }
}

// TODO: This and FullScreenCoverContainer can probably be made in a very generic way. They're both essentially doing the say thing, chaining presenting/dismissing behavior.
struct WindowPresentor<OriginalContent, PresentedContent>: View where OriginalContent: View, PresentedContent: View {
    @State
    var internalIsPresented: Bool = false
    @State
    var windowHidden: Bool = true

    @Binding
    var isPresented: Bool

    let dimmed: Bool
    let tapBackgroundToDismiss: Bool
    let onDismiss: (() -> Void)?
    let originalContent: OriginalContent
    let presentedContent: PresentedContent

    let animationTime: TimeInterval = 0.1

    init(
        isPresented: Binding<Bool>,
        dimmed: Bool = true,
        tapBackgroundToDismiss: Bool = true,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder originalContent: @escaping () -> OriginalContent,
        @ViewBuilder presentedContent: @escaping () -> PresentedContent
    ) {
        self.dimmed = dimmed
        self.tapBackgroundToDismiss = tapBackgroundToDismiss
        self.onDismiss = onDismiss
        self.originalContent = originalContent()
        self.presentedContent = presentedContent()

        self._isPresented = isPresented
        self.internalIsPresented = isPresented.wrappedValue
    }

    var body: some View {
        originalContent
            .presentFullScreen(
                isPresented: $internalIsPresented,
                dimmed: dimmed,
                tapBackgroundToDismiss: tapBackgroundToDismiss,
                onDismiss: onDismiss
            ) {
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 0, height: 0)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + animationTime) {
                                windowHidden = false
                            }
                        }

                    if !windowHidden {
                        CUIWindow { presentedContent }
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .animation(.linear(duration: animationTime), value: windowHidden)
            }
            .onChange(of: isPresented) { _ in
                // if presented, then present the window after fade in animation
                // if not presented, then fade out window before triggering the presented animation

                if isPresented {
                    internalIsPresented = true
                } else {
                    windowHidden = true

                    DispatchQueue.main.asyncAfter(deadline: .now() + animationTime) {
                        internalIsPresented = false
                    }
                }
            }
    }
}

struct PresentWindow_Previews: PreviewProvider {
    struct Preview: View {
        @State
        var showFullScreen = false

        var body: some View {
            ZStack {
                Circle().foregroundColor(.yellow)
                Button("showWindow=\(showFullScreen ? "true" : "false")") {
                    showFullScreen.toggle()
                }
                .presentWindow(isPresented: $showFullScreen) {
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
        var showFullScreen = false

        var body: some View {
            HStack {
                Circle().foregroundColor(.yellow)
                    .frame(width: 200, height: 200)
                    .fixedSize()
                    .background(.green)

                CUIButton(title: "s") {
                    showFullScreen.toggle()
                }
                .presentToolTip(isPresented: $showFullScreen) {
                    ZStack {
                        Button("hide tooltip") {
                            showFullScreen.toggle()
                        }
                        .padding()
                    }
                }
                .offset(x: 50, y: -360)
            }
        }
    }

    static var previews: some View {
        Preview()
    }
}

#endif
