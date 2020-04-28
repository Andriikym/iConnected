/**
*  iConnected
*  Copyright (c) Andrii Myk 2020
*  Licensed under the MIT license (see LICENSE file)
*/
import Foundation

class ConnectionQualityMeasurer {
    enum State {
        case ready, inProgress, finished, aborted
    }
    
    // MARK: - Private properties
    
    private let numberOfProbes = 5

    private let workingQueue = DispatchQueue(label: "com.connection_quality_measurer.measuring_queue")
    private let groupe = DispatchGroup()
    private var measureWorkers = [DispatchWorkItem]()

    private let timeMeasurer: ConnectionTimeMeasuring
    private let timeAnalyzer: ConnectionTimeAnalyzing
    private let handler: (ConnectionQuality?) -> Void

    // MARK: - Public properties
    
    var state: State = .ready
    var result: ConnectionQuality?

    // MARK: - Public

    init(timeMeasurer: ConnectionTimeMeasuring, timeAnalyzer: ConnectionTimeAnalyzing, handler: @escaping (ConnectionQuality?) -> Void) {
        self.timeMeasurer = timeMeasurer
        self.timeAnalyzer = timeAnalyzer
        self.handler = handler
    }
    
    deinit {
        print("Measurr deinttoo")
    }
    
    func abort() {
        guard state == .inProgress else { return }
        
        state = .aborted
        
        workingQueue.async {
            self.measureWorkers.forEach {
                $0.cancel()
                self.groupe.leave()
            }
        }
    }
    /// Starts the measuring. Handler will be called on *Main queue* after end or abort.
    func performMeasure() {
        guard state == .ready else {
            if state == .finished {
                handler(result)
            }
            
            return
        }
                
        state = .inProgress
        var measureResult = [CFTimeInterval?]()
        
        for i in 1...numberOfProbes {
            groupe.enter()

            let item = DispatchWorkItem { [weak self] in
                print(i)
                
                self?.measureWorkers.removeFirst()
                self?.timeMeasurer.performMeasure { time in
                    print("SOm \(time ?? 0)")
                    
                    measureResult.append(time)
                                        
                    self?.groupe.leave()
                }
            }
            
            measureWorkers.append(item)
            let time: DispatchTime = DispatchTime.now() + DispatchTimeInterval.seconds(i)
            workingQueue.asyncAfter(deadline: time, execute: item)
        }
        
        groupe.notify(queue: .main) { [weak self] in
            if self?.state == .inProgress {
                let result = self?.timeAnalyzer.analyze(measureResult)
                self?.result = result
                self?.state = .finished
            }
            
            print("Measurr notifffo")
            self?.handler(self?.result)
        }
    }
}
