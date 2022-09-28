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
        presentFullScreen(
            isPresented: isPresented,
            dimmed: dimmed,
            tapBackgroundToDismiss: tapBackgroundToDismiss,
            onDismiss: onDismiss
        ) {
            WindowPresentor { content() }
        }
    }
}

struct WindowPresentor<Content>: View where Content: View {
    @State
    var hidden = true

    var content: Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 0, height: 0)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        hidden = false
                    }
                }

            if !hidden {
                CUIWindow { content }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.default, value: hidden)
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

#endif
