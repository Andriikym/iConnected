/**
*  iConnected
*  Copyright (c) Andrii Myk 2020
*  Licensed under the MIT license (see LICENSE file)
*/

import UIKit


class ViewController: UIViewController, ConnectionCheckerDelegate {

    @IBOutlet weak var infoLabel: UILabel!
    
    lazy var checker: ConnectionChecker = {
        let result = ConnectionChecker()
        result.delegate = self
        return result
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if checker.inProgress {
            infoLabel?.text = "Checking"
        }
    }
    
    @IBAction func go() {
        
        checker.start()
        
    }
    
    @IBAction func stop() {
        
        checker.abort()
        
    }
    
    
    func connectionCheckerDidStart(_ instance: ConnectionChecking) {
          infoLabel?.text = "Checking"
    }
    
    func connectionCheckerDidFinish(result: ConnectionQuality?, instance: ConnectionChecking) {
        infoLabel?.text = result?.rawValue ?? "Aborted"
    }
    
    func connectionCheckerDidUpdate(progress: Int, instance: ConnectionChecking) {
        
    }
}

extension ViewController: ShortcutActions {
    func requestToPerformCheck() {
        go()
    }
}


class MockChecker: ConnectionChecking {
    var inProgress: Bool = false
    var delegate: ConnectionCheckerDelegate?
    
    var index = 0
    
    func start() {
        index += 1
        print("check started - \(index)")
    }
    
    func abort() {
        print("check aborted")
    }
    
    
}
