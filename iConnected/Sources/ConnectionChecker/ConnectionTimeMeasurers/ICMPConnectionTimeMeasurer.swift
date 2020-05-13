/**
*  iConnected
*  Copyright (c) Andrii Myk 2020
*  Licensed under the MIT license (see LICENSE file)
*/

import Foundation

/// Measures connection timing
final class ICMPConnectionTimeMeasurer: NSObject, ConnectionTimeMeasuring {
    
    // MARK: - Private types

    typealias PingMeasure = (timeMeasurer: TimeMeasurer, handler: TimeMeasureCompletion, cancelAction: DispatchWorkItem)
    typealias Action = () -> Void
    typealias PacketNumber = UInt16

    // MARK: - Private properties

    private static let timeout = 3.0
    
    private var measurers =  AtomicStorage<PacketNumber, PingMeasure>()
    private var coldMeasureActions = [Action]()

    private let pinger: SimplePing
    
    private let pingQueue = DispatchQueue(label: "com.icmp-connection-checker.ping-queue")
    private let timeoutQueue = DispatchQueue(label: "com.icmp-connection-checker.timeout-queue", attributes: .concurrent)
    
    // MARK: - Initialization & Deallocation

    override init() {
        let pinger = SimplePing(hostName: "8.8.8.8")
//        let pinger = SimplePing(hostName: "192.168.0.1")
        self.pinger = pinger
        
        super.init()
        pinger.delegate = self
        pinger.start()
        print("ICMP measurer finish init")
    }
    
    deinit {
        pinger.stop()
        print("Time measurert dealll")
    }
    
    // MARK: - Public
    
    /// Starts to measure connection time. Consider nil result as timeout or error.
    func performMeasure(completion: @escaping TimeMeasureCompletion) {
        guard pinger.hostAddress != nil else { // Check pinger warmed up
            print("Putting cold measurer")
            let coldMeasurer = measureWith(pinger: pinger, completion: completion)
            coldMeasureActions.append(coldMeasurer)
            return
        }
    
        pingQueue.async {
            self.measureWith(pinger: self.pinger, completion: completion)()
        }
    }
    
    // MARK: - Private

    private func measureWith(pinger: SimplePing, completion: @escaping TimeMeasureCompletion) -> Action {
        
    { [weak self] in
        let sequenceNumber = pinger.nextSequenceNumber
        
        let cancelWork = DispatchWorkItem { [weak self] in
            print("Timeout fired for \(sequenceNumber)")
            self?.handlePacketWithNumber(sequenceNumber, cancel: true)
        }
        
        let measure = (timeMeasurer: TimeMeasurer(), handler: completion, cancelAction: cancelWork)
        self?.measurers.setValue(measure, forKey: sequenceNumber)
        
        self?.timeoutQueue.asyncAfter(deadline: .now() + Self.timeout, execute: measure.cancelAction)
        pinger.send(with: nil)
        }
    }
    
    private func handlePacketWithNumber(_ number: PacketNumber, cancel: Bool) {
        print("Dequeueing measurer \(number)")
        let action = measurers.removeValue(forKey: number)
        action == nil ? print("No action for \(number)") : print("Execute action for \(number)")
        action?.cancelAction.cancel()
        action?.handler(cancel ? nil : action?.timeMeasurer.measure())
    }
}

extension ICMPConnectionTimeMeasurer: SimplePingDelegate {
    func simplePing(_ pinger: SimplePing, didSendPacket packet: Data, sequenceNumber: PacketNumber) {
        print("didSendPacket - \(sequenceNumber)")
    }
    
    func simplePing(_ pinger: SimplePing, didReceivePingResponsePacket packet: Data, sequenceNumber: PacketNumber) {
        print("didReceivePingResponsePacket - \(sequenceNumber)")

        handlePacketWithNumber(sequenceNumber, cancel: false)
    }
    
    func simplePing(_ pinger: SimplePing, didFailToSendPacket packet: Data, sequenceNumber: PacketNumber, error: Error) {
        print("didFailToSendPacket - \(sequenceNumber)")

        handlePacketWithNumber(sequenceNumber, cancel: true)
    }
        
    func simplePing(_ pinger: SimplePing, didStartWithAddress address: Data) {
        print("didStartWithAddress")
        
        pingQueue.async {
            print("processing cold measurers \(self.coldMeasureActions.count)")
            self.coldMeasureActions.forEach { $0() }
            self.coldMeasureActions = []
        }
    }
    
    func simplePing(_ pinger: SimplePing, didFailWithError error: Error) {
        print("didFailWithError")
    }
    
    func simplePing(_ pinger: SimplePing, didReceiveUnexpectedPacket packet: Data) { }
}
