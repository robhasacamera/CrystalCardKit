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
    // TODO: Add option to force an edge to be used.
    // TODO: Add pointer option
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
            presentFullScreen(
                isPresented: isPresented,
                // This has custom dimming
                dimmed: false,
                tapBackgroundToDismiss: tapBackgroundToDismiss,
                onDismiss: onDismiss
            ) {
                if dimmed {
                    Color.black
                        .frame(width: UIScreen.width, height: UIScreen.height)
                        .opacity(0.2)
                        .ignoresSafeArea()
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
                                .ignoresSafeArea()

                            ToolTipPresentor(
                                targetFrame: proxy?.frame(in: .global) ?? .zero,
                                presentationEdge: presentationEdge
                            ) {
                                CUIWindow { content() }
                            }
                        }
                        .onTapGesture {
                            withoutAnimation {
                                isPresented.wrappedValue = false
                            }
                        }
                }

                ToolTipPresentor(
                    targetFrame: proxy?.frame(in: .global) ?? .zero,
                    presentationEdge: presentationEdge
                ) {
                    CUIWindow { content() }
                }
            }
        }
    }
}

// From: https://www.fivestars.blog/articles/reverse-masks-how-to/
// TODO: Move to view utilities
public extension View {
    @inlinable
    func reverseMask<Mask: View>(
        alignment: Alignment = .center,
        @ViewBuilder _ mask: () -> Mask
    ) -> some View {
        self.mask {
            Rectangle()
//            .frame(width: UIScreen.width, height: UIScreen.height)
                .ignoresSafeArea()
                .overlay(alignment: alignment) {
                    mask()
                        .blendMode(.destinationOut)
                }
        }
    }
}

// TODO: Think about moving these presentors to their own files. This one is getting a bit crowded.
// TODO: Add a proper init
// TODO: Add a way to specify a target edge
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
    let toolTipArrowSize: CGFloat = .standardSpacing * 2

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
        CUISizeReader(size: $size, id: "ToolTipContent") {
            content
        }
        // TODO: Need to take the safe area into account
        .position(
            x: {
                let x: CGFloat

                switch targetEdge {
                case .top: fallthrough
                case .bottom:
                    x = targetFrame.midX
                case .leading:
                    x = targetFrame.minX - toolTipArrowSize - size.width / 2
                case .trailing:
                    x = targetFrame.maxX + toolTipArrowSize + size.width / 2
                }

                return min(max(x, toolTipSpacing + size.width / 2), UIScreen.width - toolTipSpacing - size.width / 2)
            }(),
            y: {
                let y: CGFloat

                switch targetEdge {
                case .top:
                    y = targetFrame.minY - toolTipArrowSize - size.height / 2
                case .bottom:
                    y = targetFrame.maxY + toolTipArrowSize + size.height / 2
                case .leading: fallthrough
                case .trailing:
                    y = targetFrame.midY
                }

                return min(max(y, toolTipSpacing + size.height / 2), UIScreen.height - toolTipSpacing - size.height / 2)
            }()
        )
        .ignoresSafeArea()

        ToolTipArrow(
            toolTipDirection: targetEdge,
            toolTipSpacing: toolTipArrowSize
        )
        .foregroundStyle(.ultraThinMaterial)
        .frame(width: toolTipArrowSize, height: toolTipArrowSize)
        .position(
            x: {
                let x: CGFloat

                switch targetEdge {
                case .top: fallthrough
                case .bottom:
                    x = targetFrame.midX
                case .leading:
                    x = targetFrame.minX - toolTipArrowSize / 2
                case .trailing:
                    x = targetFrame.maxX + toolTipArrowSize / 2
                }

                return min(max(x, toolTipSpacing + toolTipArrowSize / 2), UIScreen.width - toolTipSpacing - toolTipArrowSize / 2)
            }(),
            y: {
                let y: CGFloat

                switch targetEdge {
                case .top:
                    y = targetFrame.minY - toolTipArrowSize / 2
                case .bottom:
                    y = targetFrame.maxY + toolTipArrowSize / 2
                case .leading: fallthrough
                case .trailing:
                    y = targetFrame.midY
                }

                return min(max(y, toolTipSpacing + toolTipSpacing / 2), UIScreen.height - toolTipSpacing - toolTipSpacing / 2)
            }()
        )
        .ignoresSafeArea()
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
//            .previewInterfaceOrientation(.landscapeLeft)
        }
    }

    static var previews: some View {
        Preview()
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
    }
}

#endif
