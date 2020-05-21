/**
*  iConnected
*  Copyright (c) Andrii Myk 2020
*  Licensed under the MIT license (see LICENSE file)
*/

import UIKit
import ConnectionChecker

class ViewController: UIViewController, ConnectionQualityCheckerDelegate {

    @IBOutlet weak var infoLabel: UILabel!
    
    lazy var checker: ConnectionQualityChecker = {
        let result = ConnectionQualityChecker()
        result.delegate = self
        return result
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if checker.inProgress {
            infoLabel?.text = "title.main_screen.check_progress".localized
        }
    }
    
    @IBAction func go() {
        checker.start()
    }
    
    @IBAction func stop() {
        checker.cancel()
    }
    
    func connectionCheckerDidStart(_ instance: ConnectionQualityChecking) {
          infoLabel?.text = "title.main_screen.check_progress".localized
    }
    
    func connectionCheckerDidFinish(result: ConnectionQuality?, instance: ConnectionQualityChecking) {
        infoLabel?.text = result?.rawValue ?? "title.main_screen.check_canceled".localized
    }
    
    func connectionCheckerDidUpdate(progress: Double, instance: ConnectionQualityChecking) {
        let progressString = " \(progress * 100)%"
        infoLabel?.text = "title.main_screen.check_progress".localized + progressString
    }
}

extension ViewController: ShortcutActions {
    func requestToPerformCheck() {
        go()
    }
}


class MockChecker: ConnectionQualityChecking {
    var inProgress: Bool = false
    var delegate: ConnectionQualityCheckerDelegate?
    
    var index = 0
    
    func start() {
        index += 1
        print("check started - \(index)")
    }
    
    func cancel() {
        print("check aborted")
    }
}
