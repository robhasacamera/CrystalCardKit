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

#endif
