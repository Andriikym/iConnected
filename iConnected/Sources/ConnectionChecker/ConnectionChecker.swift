/**
*  iConnected
*  Copyright (c) Andrii Myk 2020
*  Licensed under the MIT license (see LICENSE file)
*/

import Foundation

/// The general connection quality
enum ConnectionQuality: String {
    case absent
    case poor
    case slow
    case good
    case excelent
}

protocol ConnectionChecking {
    var delegate: ConnectionCheckerDelegate? { get set }
    var inProgress: Bool { get }
    
    func start()
    func abort()
}

protocol ConnectionCheckerDelegate: AnyObject {
    func connectionCheckerDidStart(_ instance: ConnectionChecking)
    func connectionCheckerDidFinish(result: ConnectionQuality?, instance: ConnectionChecking)
    func connectionCheckerDidUpdate(progress: Int, instance: ConnectionChecking)
}

class ConnectionChecker: ConnectionChecking {
    
    // MARK: - Private properties
    
    private var qualityMeasurer: ConnectionQualityMeasurer?

    var inProgress: Bool {
        qualityMeasurer != nil
    }

    // MARK: - Public properties

    weak var delegate: ConnectionCheckerDelegate?
        
    // MARK: - Public

    func start() {
        guard !inProgress else { return }

        delegate?.connectionCheckerDidStart(self)
        performMeasure()
    }
    
    func abort() {
        qualityMeasurer?.abort()
    }
    
    // MARK: - Private

    private func performMeasure() {
        qualityMeasurer = ConnectionQualityMeasurer(timeMeasurer: ICMPConnectionTimeMeasurer(),
                                                    timeAnalyzer: ConnectionTimeAnalyzer()) { [weak self] result in
            guard let self = self else { return }

            self.qualityMeasurer = nil
            self.delegate?.connectionCheckerDidFinish(result: result, instance: self)
        }
        
        qualityMeasurer?.performMeasure()
    }
}

