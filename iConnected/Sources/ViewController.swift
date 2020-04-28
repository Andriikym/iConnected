/**
*  iConnected
*  Copyright (c) Andrii Myk 2020
*  Licensed under the MIT license (see LICENSE file)
*/

import UIKit


class ViewController: UIViewController, ConnectionCheckerDelegate {

    @IBOutlet weak var infoLabel: UILabel!
    
    var checker = ConnectionChecker()

    override func viewDidLoad() {
        super.viewDidLoad()

        checker.delegate = self
    }
    
    @IBAction func go() {
        
        checker.start()
        
    }
    
    @IBAction func stop() {
        
        checker.abort()
        
    }
    
    func connectionCheckerDidStart(_ instance: ConnectionChecking) {
          infoLabel.text = "Checking"
    }
    
    func connectionCheckerDidFinish(result: ConnectionQuality?, instance: ConnectionChecking) {
        infoLabel.text = result?.rawValue ?? "Aborted"
    }
    
    func connectionCheckerDidUpdate(progress: Int, instance: ConnectionChecking) {
        
    }
}

