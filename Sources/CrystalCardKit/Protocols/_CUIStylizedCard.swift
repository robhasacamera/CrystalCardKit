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

// TODO: Rename CUIStylizedWindow to CUIStylizedCard to match this.
protocol _CUIStylizedCard: CUIStylizedWindow, _CUIStylizedControl {
    associatedtype _Window: CUIStylizedWindow

    var control: _Window { get set }
}

extension _CUIStylizedCard {
    public var hideHeader: Bool {
        get {
            control.hideHeader
        }
        set {
            var newControl = control

            newControl.hideHeader = newValue

            control = newControl
        }

    }
    public var hideSeparator: Bool {
        get {
            control.hideSeparator
        }
        set {
            var newControl = control

            newControl.hideSeparator = newValue

            control = newControl
        }

    }
    public var hideCloseButton: Bool {
        get {
            control.hideCloseButton
        }
        set {
            var newControl = control

            newControl.hideCloseButton = newValue

            control = newControl
        } }
}
