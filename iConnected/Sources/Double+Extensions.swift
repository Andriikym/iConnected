/**
*  iConnected
*  Copyright (c) Andrii Myk 2020
*  Licensed under the MIT license (see LICENSE file)
*/

import Foundation

extension Double {
    var percentRepresentation: Int {
        Int((self * 100).rounded(.toNearestOrEven))
    }
}
