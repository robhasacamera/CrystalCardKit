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

#if os(iOS)

// TODO: This and FullScreenCoverContainer can probably be made in a very generic way. They're both essentially doing the say thing, chaining presenting/dismissing behavior.
struct CardPresentor<OriginalContent, PresentedContent>: View where OriginalContent: View, PresentedContent: View {
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
                        .foregroundColor(.black)
                        .opacity(0.01)
                        .ignoresSafeArea()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + animationTime) {
                                windowHidden = false
                            }
                        }
                        .onTapGesture {
                            isPresented = false
                            onDismiss?()
                        }

                    if !windowHidden {
                        CUICard { presentedContent }
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
            .onChange(of: internalIsPresented) { _ in
                // Keeping thes values in sync when internalIsPresented is updated by presentFullScreen independently of isPresented
                if !internalIsPresented && isPresented || internalIsPresented && !isPresented {
                    isPresented = internalIsPresented
                }
            }
    }
}

// This should help with chaining animations in generation
struct Helper<PresentedContent>: ViewModifier where PresentedContent: View {
    @State
    var internalIsPresented: Bool = false
    @State
    var windowHidden: Bool = true

    @Binding
    var isPresented: Bool
    var transition: AnyTransition
    let presentedContent: PresentedContent

    let animationTime: TimeInterval = 0.1

    init(
        isPresented: Binding<Bool>,
        transition: AnyTransition = .opacity,
        @ViewBuilder presentedContent: @escaping () -> PresentedContent
    ) {
        self.presentedContent = presentedContent()
        self.transition = transition

        self._isPresented = isPresented
        self.internalIsPresented = isPresented.wrappedValue
    }

    func body(content: Content) -> some View {
        content
            // Wonder if I should pass a view proxy instead. So it can decide what to show. Though view chainging with fullscreen is different then regular view chainging. Mayybe I should make a regular view chainer so I can decide what this should look like. Or I can just like with this and add the rest of the values in. I think that might be better.
            .presentFullScreen(
                isPresented: $internalIsPresented
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
                        presentedContent
                            .transition(transition)
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

struct FullScreenPrentationAnimationHelper<OriginalContent, PresentedContent>: View where OriginalContent: View, PresentedContent: View {
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
                        CUICard { presentedContent }
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

// Ok, so the general idea here is that, you have to wait for the fullscreen to finish, once it's finished (on appear), you make another thing happen, like animating in a card.
// But when going the other way, you have to wait for the inner content to disappear, before making this disappear.

// So we want a generic way to do this. Pass in some content and an transition style, then present the content, after the fullscreen is done, and dismiss fullscreen, after the content is hidden. It has to have an animation time for the moment to work properly.

#endif
