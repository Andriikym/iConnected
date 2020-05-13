/**
*  iConnected
*  Copyright (c) Andrii Myk 2020
*  Licensed under the MIT license (see LICENSE file)
*/

import Foundation

/// Thread safe key/value storage.
final class AtomicStorage<Key, Value> where Key : Hashable {
    private let semaphore = DispatchSemaphore(value: 1)
    private var dic: [Key : Value] = [ : ]
        
    func setValue(_ value: Value, forKey key: Key) {
        semaphore.wait(); defer { semaphore.signal() }
        
        dic[key] = value
    }
    
    func removeValue(forKey key: Key) -> Value? {
        semaphore.wait(); defer { semaphore.signal() }
        
        return dic.removeValue(forKey: key)
    }
    
    var values: [Value] {
        semaphore.wait(); defer { semaphore.signal() }
        
        return dic.values.map { $0 }
    }
}
