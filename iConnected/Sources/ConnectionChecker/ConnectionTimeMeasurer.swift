/**
*  iConnected
*  Copyright (c) Andrii Myk 2020
*  Licensed under the MIT license (see LICENSE file)
*/

import Foundation

typealias TimeMeasureCompletion = (CFTimeInterval?) -> ()

/// Measures connection timing
protocol ConnectionTimeMeasuring {
    /// Starts to measure connection time
    func performMeasure(completion: @escaping TimeMeasureCompletion)
}

/// Measures connection timing
class ConnectionTimeMeasurer: ConnectionTimeMeasuring {

    // MARK: - Private properties

    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpCookieAcceptPolicy = .never
        configuration.httpShouldSetCookies = false
        configuration.httpCookieStorage = nil
        configuration.timeoutIntervalForRequest = 30
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil
        configuration.httpShouldUsePipelining = false
        var result = URLSession(configuration: configuration)
        print("made session")
        return result
    }()
    
    // MARK: - Public

    /// Starts to measure connection time
    func performMeasure(completion: @escaping TimeMeasureCompletion) {
        let url = URL(string: "https://google.com")!
        var request = URLRequest(url: url)

        request.httpMethod = "HEAD"
        
        let timeMeasurer = TimeMeasurer()
        let task = session.dataTask(with: request) { (data, response, err) in
            guard err == nil else { completion(nil); return }
            
            let passTime = timeMeasurer.measure()
            completion(passTime)
        }
        
        task.resume()
    }
}

class MockConnectionTimeMeasurer: ConnectionTimeMeasuring {
    func performMeasure(completion: @escaping TimeMeasureCompletion) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
            let range = 0.1...0.5
            let result = Double.random(in: range)
            completion(result)
        }
    }
}
