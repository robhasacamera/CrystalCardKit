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

struct ToolTipShape: Shape {
    var presentationDirection: Edge
    var arrowWidth: CGFloat
    var arrowOffset: CGFloat
    var cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let roundedRectFrame: CGRect

        switch presentationDirection {
        case .top:
            roundedRectFrame = CGRect(
                x: rect.minX,
                y: rect.minY,
                width: rect.width,
                height: rect.height - arrowWidth / 2
            )

            path.move(to: CGPoint(
                x: roundedRectFrame.midX + arrowOffset,
                y: roundedRectFrame.maxY + (arrowWidth / 2)
            ))
            path.addLine(to: CGPoint(
                x: roundedRectFrame.midX + arrowOffset - arrowWidth / 2,
                y: roundedRectFrame.maxY
            ))
            path.addLine(to: CGPoint(
                x: roundedRectFrame.midX + arrowOffset + arrowWidth / 2,
                y: roundedRectFrame.maxY
            ))
        case .bottom:
            roundedRectFrame = CGRect(
                x: rect.minX,
                y: rect.minY + arrowWidth / 2,
                width: rect.width,
                height: rect.height - arrowWidth / 2
            )

            path.move(to: CGPoint(
                x: roundedRectFrame.midX + arrowOffset,
                y: roundedRectFrame.minY - arrowWidth / 2
            ))
            path.addLine(to: CGPoint(
                x: roundedRectFrame.midX + arrowOffset - arrowWidth / 2,
                y: roundedRectFrame.minY
            ))
            path.addLine(to: CGPoint(
                x: roundedRectFrame.midX + arrowOffset + arrowWidth / 2,
                y: roundedRectFrame.minY
            ))
        case .leading:
            roundedRectFrame = CGRect(
                x: rect.minX,
                y: rect.minY,
                width: rect.width - arrowWidth / 2,
                height: rect.height
            )

            path.move(to: CGPoint(
                x: roundedRectFrame.maxX + arrowWidth / 2,
                y: roundedRectFrame.midY + arrowOffset
            ))
            path.addLine(to: CGPoint(
                x: roundedRectFrame.maxX,
                y: roundedRectFrame.midY + arrowOffset - arrowWidth / 2
            ))
            path.addLine(to: CGPoint(
                x: roundedRectFrame.maxX,
                y: roundedRectFrame.midY + arrowOffset + arrowWidth / 2
            ))
        case .trailing:
            roundedRectFrame = CGRect(
                x: rect.minX + arrowWidth / 2,
                y: rect.minY,
                width: rect.width - arrowWidth / 2,
                height: rect.height
            )

            path.move(to: CGPoint(
                x: roundedRectFrame.minX - arrowWidth / 2,
                y: roundedRectFrame.midY + arrowOffset
            ))
            path.addLine(to: CGPoint(
                x: roundedRectFrame.minX,
                y: roundedRectFrame.midY + arrowOffset - arrowWidth / 2
            ))
            path.addLine(to: CGPoint(
                x: roundedRectFrame.minX,
                y: roundedRectFrame.midY + arrowOffset + arrowWidth / 2
            ))
        }

        path.closeSubpath()

        let roundedRect = RoundedRectangle(cornerRadius: cornerRadius).path(in: roundedRectFrame)

        path.addPath(roundedRect)

        return path
    }
}

struct ToolTipShape_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            // TODO: Maybe recreate this in preview kit as a test background?
            Spacer()
                .frame(width: UIScreen.width, height: UIScreen.height)
                .background(.linearGradient(colors: [.red, .blue, .yellow], startPoint: .top, endPoint: .bottom))

            VStack(spacing: .standardSpacing * 2) {
                HStack {


                    ToolTipShape(
                        presentationDirection: .top,
                        arrowWidth: .standardSpacing * 2,
                        arrowOffset: 20,
                        cornerRadius: .cornerRadius
                    )
                    .frame(width: 100, height: 50)
                    .foregroundStyle(.thinMaterial)

                    ToolTipShape(
                        presentationDirection: .top,
                        arrowWidth: .standardSpacing * 2,
                        arrowOffset: 0,
                        cornerRadius: .cornerRadius
                    )
                    .frame(width: 100, height: 50)
                    .foregroundStyle(.thinMaterial)

                    ToolTipShape(
                        presentationDirection: .top,
                        arrowWidth: .standardSpacing * 2,
                        arrowOffset: -20,
                        cornerRadius: .cornerRadius
                    )
                    .frame(width: 100, height: 50)
                    .foregroundStyle(.thinMaterial)
                }

                HStack {
                    ToolTipShape(
                        presentationDirection: .bottom,
                        arrowWidth: .standardSpacing * 2,
                        arrowOffset: 20,
                        cornerRadius: .cornerRadius
                    )
                    .frame(width: 100, height: 50)
                    .foregroundStyle(.thinMaterial)

                    ToolTipShape(
                        presentationDirection: .bottom,
                        arrowWidth: .standardSpacing * 2,
                        arrowOffset: 0,
                        cornerRadius: .cornerRadius
                    )
                    .frame(width: 100, height: 50)
                    .foregroundStyle(.thinMaterial)

                    ToolTipShape(
                        presentationDirection: .bottom,
                        arrowWidth: .standardSpacing * 2,
                        arrowOffset: -20,
                        cornerRadius: .cornerRadius
                    )
                    .frame(width: 100, height: 50)
                    .foregroundStyle(.thinMaterial)
                }


                HStack {
                    ToolTipShape(
                        presentationDirection: .leading,
                        arrowWidth: .standardSpacing * 2,
                        arrowOffset: 10,
                        cornerRadius: .cornerRadius
                    )
                    .frame(width: 100, height: 50)
                    .foregroundStyle(.thinMaterial)

                    ToolTipShape(
                        presentationDirection: .leading,
                        arrowWidth: .standardSpacing * 2,
                        arrowOffset: 0,
                        cornerRadius: .cornerRadius
                    )
                    .frame(width: 100, height: 50)
                    .foregroundStyle(.thinMaterial)

                    ToolTipShape(
                        presentationDirection: .leading,
                        arrowWidth: .standardSpacing * 2,
                        arrowOffset: -10,
                        cornerRadius: .cornerRadius
                    )
                    .frame(width: 100, height: 50)
                    .foregroundStyle(.thinMaterial)
                }

                HStack {
                    ToolTipShape(
                        presentationDirection: .trailing,
                        arrowWidth: .standardSpacing * 2,
                        arrowOffset: 10,
                        cornerRadius: .cornerRadius
                    )
                    .frame(width: 100, height: 50)
                    .foregroundStyle(.thinMaterial)

                    ToolTipShape(
                        presentationDirection: .trailing,
                        arrowWidth: .standardSpacing * 2,
                        arrowOffset: 0,
                        cornerRadius: .cornerRadius
                    )
                    .frame(width: 100, height: 50)
                    .foregroundStyle(.thinMaterial)

                    ToolTipShape(
                        presentationDirection: .trailing,
                        arrowWidth: .standardSpacing * 2,
                        arrowOffset: -10,
                        cornerRadius: .cornerRadius
                    )
                    .frame(width: 100, height: 50)
                    .foregroundStyle(.thinMaterial)
                }
            }
        }
    }
}
