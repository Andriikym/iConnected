/**
*  iConnected
*  Copyright (c) Andrii Myk 2020
*  Licensed under the MIT license (see LICENSE file)
*/

import Foundation

extension Bundle {
    enum Key: String {
        case bundleDisplayName = "CFBundleDisplayName"
        case bundleShortVersionString = "CFBundleShortVersionString"
        case bundleVersion = "CFBundleVersion"
    }

    func value<T>(forKey key: Bundle.Key) -> T? {
        return infoDictionary?[key.rawValue] as? T
    }
}

extension Bundle {
    var bundleShortVersionString: String {
        value(forKey: .bundleShortVersionString) ?? ""
    }
    
    var bundleVersionString: String {
        value(forKey: .bundleVersion) ?? ""
    }
    
    var bundleDisplayNameString: String {
        value(forKey: .bundleDisplayName) ?? ""
    }
    
    var appVersion: String {
        bundleShortVersionString + " (\(bundleVersionString))"
    }
}
