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
        dimmed: Bool = true,
        tapBackgroundToDismiss: Bool = true,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View where Content: View {
        // TODO: Need to document the difference between this and a regular goemtry reader. I think it's that a regular geomtry reader provides the geometry for a parent while this one provides geometry for the child inside of it. So it can use it's own geometry on itself.
//        ToolTipWrapper(isPresented: isPresented) {
//            self
//        } content: {
//            CUIWindow {
//                content()
//            }
//        }
        CUIChildGeometryReader(id: "id") { proxy in
            presentFullScreen(
                isPresented: isPresented,
                dimmed: dimmed,
                tapBackgroundToDismiss: tapBackgroundToDismiss,
                onDismiss: onDismiss
            ) {
                ToolTipPresentor(
                    targetFrame: proxy?.frame(in: .global) ?? .zero,
                    content: CUIWindow { content() }
                )
            }
        }
    }
}

// FIXME: This works until you take into account that there are multiple elements on the screen, so this might be underneath one of the existing elements.
// FIXME: The tooltip arrow is detached for the bottom presentation style.
struct ToolTipWrapper<Target, Content>: View where Target: View, Content: View {
    let toolTipSpacing: CGFloat = .standardSpacing * 2

    @State
    var toolTipSize: CGSize = .zero
    @Binding
    var isPresented: Bool
    var target: Target
    var content: Content

    func presentationEdge(targetFrame: CGRect) -> Edge {
        let topScreenSpace = targetFrame.minY - toolTipSpacing * 2

        if topScreenSpace > toolTipSize.height {
            return .top
        }

        let bottomScreenSpace = UIScreen.height - targetFrame.maxY - toolTipSpacing * 2

        if bottomScreenSpace > toolTipSize.height {
            return .bottom
        }

        let leadingScreenSpace = targetFrame.minX - toolTipSpacing * 2

        if leadingScreenSpace > toolTipSize.width {
            return .leading
        }

        let trailingScreenSpace = UIScreen.width - targetFrame.maxX - toolTipSpacing * 2

        if trailingScreenSpace > toolTipSize.width {
            return .trailing
        }

        return .top
    }

    init(
        isPresented: Binding<Bool>,
        @ViewBuilder target: () -> Target,
        @ViewBuilder content: () -> Content
    ) {
        self._isPresented = isPresented
        self.target = target()
        self.content = content()
    }

    var body: some View {
        CUIChildGeometryReader(id: "__target") { proxy in
            target
                .overlay {
                    Color.black.opacity(isPresented ? 0.2 : 0).frame(width: UIScreen.width, height: UIScreen.height)
                        .offset(
                            x: {
                                let targetFrame = proxy?.frame(in: .global) ?? .zero

                                return UIScreen.width / 2 - targetFrame.size.width / 2 - targetFrame.minX
                            }(),
                            y: {
                                let targetFrame = proxy?.frame(in: .global) ?? .zero

                                return UIScreen.height / 2 - targetFrame.size.height / 2 - targetFrame.minY
                            }()
                        )
                        .onTapGesture {
                            isPresented.toggle()
                        }
                }
                .overlay {
                    ToolTipArrow(
                        toolTipDirection: presentationEdge(
                            targetFrame: proxy?.frame(in: .global) ?? .zero
                        ),
                        toolTipSpacing: toolTipSpacing
                    )
                    .foregroundStyle(.ultraThinMaterial)
                    .frame(width: toolTipSpacing, height: toolTipSpacing)
                    .offset(
                        x: {
                            let targetFrame = proxy?.frame(in: .global) ?? .zero

                            let edge = presentationEdge(targetFrame: targetFrame)

                            let offset = (targetFrame.size.width + toolTipSpacing) / 2

                            switch edge {
                            case .bottom: fallthrough
                            case .top:
                                return 0
                            case .leading:
                                return -offset
                            case .trailing:
                                return offset
                            }
                    }(),
                        y: {
                            let targetFrame = proxy?.frame(in: .global) ?? .zero

                            let edge = presentationEdge(targetFrame: targetFrame)

                            let offset = (targetFrame.size.height + toolTipSpacing) / 2

                            switch edge {
                            case .bottom:
                                return offset
                            case .top:
                                return -offset
                            case .leading: fallthrough
                            case .trailing:
                                return 0
                            }
                        }()
                    )
                    .opacity(isPresented ? 1 : 0)
                    .scaleEffect(isPresented ? 1 : 0)
                }
                .overlay {
                    CUISizeReader(size: $toolTipSize, id: "__tooltip") {
                        content
                    }
                    .offset(
                        // TODO: need to do the calculations for what edge to use.
                        x: {
                            let targetFrame = proxy?.frame(in: .global) ?? .zero

                            let edge = presentationEdge(targetFrame: targetFrame)

                            let offset = (targetFrame.size.width + toolTipSize.width) / 2 + toolTipSpacing

                            let minX = toolTipSize.width / 2 - targetFrame.midX + toolTipSpacing

                            let maxX = -(toolTipSize.width / 2 + targetFrame.midX - UIScreen.width + toolTipSpacing)

                            let x: CGFloat

                            switch edge {
                            case .bottom: fallthrough
                            case .top:
                                x = 0
                            case .leading:
                                x = -offset
                            case .trailing:
                                x = offset
                            }

                            return min(maxX, max(minX, x))
                        }(),
                        y: {
                            let targetFrame = proxy?.frame(in: .global) ?? .zero

                            let edge = presentationEdge(targetFrame: targetFrame)

                            let offset = (targetFrame.size.height + toolTipSize.height) / 2 + toolTipSpacing

                            let minY = toolTipSize.height / 2 - targetFrame.midY + toolTipSpacing

                            let maxY = -(toolTipSize.height / 2 + targetFrame.midY - UIScreen.height + toolTipSpacing)

                            let y: CGFloat

                            switch edge {
                            case .bottom:
                                y = offset
                            case .top:
                                y = -offset
                            case .leading: fallthrough
                            case .trailing:
                                y = 0
                            }

                            return min(maxY, max(minY, y))
                        }()
                    )
                    .opacity(isPresented ? 1 : 0)
                    .scaleEffect(isPresented ? 1 : 0)
                }
                .animation(.default, value: isPresented)
        }
    }
}

// TODO: Think about moving these presentors to their own files. This one is getting a bit crowded.
// TODO: Add a proper init
// TODO: Add a way to specify a target edge
// FIXME: This is working pretty well, still not sure why it's off by about 6 points vertically
struct ToolTipPresentor<Content>: View where Content: View {
    let toolTipSpacing: CGFloat = .standardSpacing
    let yAdjustment_FIXME_SHOULD_NOT_BE_NEEDED: CGFloat = 0 // -6

    @State
    var size: CGSize = .zero

    var targetFrame: CGRect
    var content: Content

    var targetEdge: Edge {
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

    var _targetEdgeString: String {
        switch targetEdge {
        case .top:
            return "top"
        case .leading:
            return "leading"
        case .bottom:
            return "bottom"
        case .trailing:
            return "trailing"
        }
    }

    var body: some View {
//        ZStack(alignment: .topLeading) {
            // FIXME: When this is added, it causes the ZStack to shift outside of the frame. Without it the ZStack will not be large enough. Using the rectangle to visualize things.
//             Spacer()
//            Rectangle()
//                .foregroundColor(.black.opacity(0.2))
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .opacity(0)
//            Color.black.opacity(0.2).ignoresSafeArea()

            CUISizeReader(size: $size, id: "1") {
                content
            }
            // TODO: Need to take the safe area into account
            // FIXME: Still have no idea why everything is off by a few points (~6 points vertically), and sometimes half points
            // TODO: Do a lot of calculations regarding the frame to decide if the tooltip should be above or below and centered versus off center. Thinking that the arrow will always point to the center top/bottom of the target
            .position(
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
                        y = targetFrame.minY - toolTipSpacing - size.height  / 2
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
//        .frame(width: UIScreen.width, height: UIScreen.height)
//        .overlay {
//            VStack {
//                Text(String(format: "origin = (%.0f, %.0f)", targetFrame.minX, targetFrame.minY))
//                Text(String(format: "size = (%.0f, %.0f)", targetFrame.width, targetFrame.height))
//                Text(String(format: "tooltip size = (%.0f, %.0f)", size.width, size.height))
//                Text("\(_targetEdgeString)")
//            }
//            .padding(.standardSpacing)
//            .background(.thinMaterial)
//        }
//    }
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
                    .presentToolTip(isPresented: $showTopLeading) {
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

#endif
