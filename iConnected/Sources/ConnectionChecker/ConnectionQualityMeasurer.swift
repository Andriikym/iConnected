/**
*  iConnected
*  Copyright (c) Andrii Myk 2020
*  Licensed under the MIT license (see LICENSE file)
*/
import Foundation

class ConnectionQualityMeasurer {
    
    // MARK: - Private types

    enum State {
        case ready, inProgress, finished, aborted
    }
    
    typealias Millisecond = Int
    
    // MARK: - Private properties
    
    private let numberOfProbes = 5
    private let probeInterval: Millisecond = 1000
    
    private let workingQueue = DispatchQueue(label: "com.connection_quality_measurer.measuring_queue")
    private let groupe = DispatchGroup()
    private var measureWorkers = [DispatchWorkItem]()
    
    private let timeMeasurer: ConnectionTimeMeasuring
    private let timeAnalyzer: ConnectionTimeAnalyzing
    private let handler: (ConnectionQuality?) -> Void
    
    // MARK: - Public properties
    
    var state: State = .ready
    var result: ConnectionQuality?
    
    // MARK: - Initialization & Deallocation

    init(timeMeasurer: ConnectionTimeMeasuring, timeAnalyzer: ConnectionTimeAnalyzing, handler: @escaping (ConnectionQuality?) -> Void) {
        self.timeMeasurer = timeMeasurer
        self.timeAnalyzer = timeAnalyzer
        self.handler = handler
    }
    
    deinit {
        print("QM deinit")
    }
    
    // MARK: - Public

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

    /// Starts the measuring. Handler will be called on *Main queue* after finish or abort.
    func performMeasure() {
        guard state == .ready else {
            if state == .finished {
                handler(result)
            }
            
            return
        }
        
        state = .inProgress
        let measureResult = AtomicStorage<Int, CFTimeInterval?>()
        let now = DispatchTime.now()
        workingQueue.sync {
            for i in 0...numberOfProbes - 1 {
                print("Appending probe - \(i)")
                groupe.enter()
                let work = measureWork(number: i, measureResult: measureResult)
                measureWorkers.append(work)
                let time: DispatchTime = now + .milliseconds(i * probeInterval)
                workingQueue.asyncAfter(deadline: time, execute: work)
            }
            
        }
        let time = TimeMeasurer() //DEBUG
        groupe.notify(queue: .main) { [weak self] in
            if self?.state == .inProgress {
                let result = self?.timeAnalyzer.analyze(measureResult.values)
                self?.result = result
                self?.state = .finished
            }
            
            print("QM got notify - \(time.measure())")
            self?.handler(self?.result)
        }
    }
    
    // MARK: - Private
    
    private func measureWork(number: Int, measureResult: AtomicStorage<Int, CFTimeInterval?>) -> DispatchWorkItem {
        DispatchWorkItem { [weak self, weak measureResult] in
            print("Probe - \(number)")
            
            self?.measureWorkers.removeFirst()
            self?.timeMeasurer.performMeasure { time in
                print("Measure \(number) \(time ?? 0)")
                self?.workingQueue.async {
                    measureResult?.setValue(time, forKey: number)
                    self?.groupe.leave()
                }
            }
        }
    }
}

