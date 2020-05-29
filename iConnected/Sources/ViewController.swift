/**
*  iConnected
*  Copyright (c) Andrii Myk 2020
*  Licensed under the MIT license (see LICENSE file)
*/

import UIKit
import ConnectionChecker

class ViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    
    // MARK: - Private properties

    lazy var checker: ConnectionQualityChecker = {
        let result = ConnectionQualityChecker()
        result.delegate = self
        return result
    }()
    
    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        versionLabel.text = "Version" + " " + Bundle.main.appVersion
        if checker.inProgress {
            infoLabel?.text = "title.main_screen.check_progress".localized
        }
    }
    
    // MARK: - Actions

    @IBAction func go() {
        checker.start()
    }
    
    @IBAction func stop() {
        checker.cancel()
    }
}

// MARK: - ConnectionQualityCheckerDelegate

extension ViewController: ConnectionQualityCheckerDelegate {
    func connectionCheckerDidStart(_ instance: ConnectionQualityChecking) {
          let progressString = "0%"
          infoLabel?.text = "title.main_screen.check_progress".localized + " " + progressString
    }
    
    func connectionCheckerDidFinish(result: ConnectionQuality?, instance: ConnectionQualityChecking) {
        infoLabel?.text = result?.rawValue ?? "title.main_screen.check_canceled".localized
    }
    
    func connectionCheckerDidUpdate(progress: Double, instance: ConnectionQualityChecking) {
        let progressString = "\(progress.percentRepresentation)%"
        infoLabel?.text = "title.main_screen.check_progress".localized + " " + progressString
    }
}

// MARK: - ShortcutActions

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
