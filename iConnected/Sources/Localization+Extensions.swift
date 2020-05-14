/**
*  iConnected
*  Copyright (c) Andrii Myk 2020
*  Licensed under the MIT license (see LICENSE file)
*/

import UIKit

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "Made in extension")
    }
}

extension UILabel {
    @IBInspectable var localizedText: String? {
        set {
            self.text = newValue?.localized
        }
        get {
            return nil
        }
    }
}

extension UIButton {
    @IBInspectable var localizedTitle: String? {
        set {
            self.setTitle(newValue?.localized, for: .normal)
            self.setTitle(newValue?.localized, for: .highlighted)
            self.setTitle(newValue?.localized, for: .disabled)
        }
        get {
            return nil
        }
    }
}


