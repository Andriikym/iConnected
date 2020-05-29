/**
*  iConnected
*  Copyright (c) Andrii Myk 2020
*  Licensed under the MIT license (see LICENSE file)
*/

import UIKit
import NotificationCenter
import ConnectionChecker

class TodayViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    // MARK: - Private properties

    private lazy var checker: ConnectionQualityChecker = {
        let result = ConnectionQualityChecker()
        result.delegate = self
        return result
    }()
    
    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        checker.start()
        
        if checker.inProgress {
            if checker.inProgress {
                infoLabel?.text = "title.main_screen.check_progress".localized
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        checker.cancel()
    }

    // MARK: - Actions

    @IBAction func onButton(_ sender: Any) {
        checker.start()
    }
    
    @IBAction func onOpen(_ sender: Any) {
        guard let url = URL(string: "iconnected:") else { return }
           
        extensionContext?.open(url, completionHandler: { [weak self] opened in
            if opened {
                self?.checker.cancel()
            }
        })
    }
}

extension TodayViewController: ConnectionQualityCheckerDelegate {
    func connectionCheckerDidStart(_ instance: ConnectionQualityChecking) {
        actionButton.isHidden = true
        let progressString = " 0%"
        infoLabel?.text = "title.main_screen.check_progress".localized + progressString
    }
    
    func connectionCheckerDidFinish(result: ConnectionQuality?, instance: ConnectionQualityChecking) {
        infoLabel?.text = result?.rawValue ?? "title.main_screen.check_canceled".localized
        actionButton.isHidden = false
    }
    
    func connectionCheckerDidUpdate(progress: Double, instance: ConnectionQualityChecking) {
        let progressString = " \(progress.percentRepresentation)%"
        infoLabel?.text = "title.main_screen.check_progress".localized + progressString
    }
}
