/**
*  iConnected
*  Copyright (c) Andrii Myk 2020
*  Licensed under the MIT license (see LICENSE file)
*/

import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private lazy var shortcutManager: ShortcutManager = {
        print("Asked for manager")
        let result = ShortcutManager()
        result.delegate = self.window?.rootViewController as? ShortcutActions
        return result
    }()


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("scene willConnectTo")
        if let shortcutItem = connectionOptions.shortcutItem, let type = ShortcutManager.ShortcutItemType(rawValue: shortcutItem.type) {
            shortcutManager.handleItem(type)
        }
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        if let type = ShortcutManager.ShortcutItemType(rawValue: shortcutItem.type) {
            shortcutManager.handleItem(type)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

protocol ShortcutActions: AnyObject {
    func requestToPerformCheck()
}

class ShortcutManager {
    weak var delegate: ShortcutActions?
    
    enum ShortcutItemType: String {
        case check = "SHORTCUT_ITEM_TYPE_CHECK"
    }
    
    func handleItem(_ item: ShortcutItemType) {
        print("Ask to handle - \(item.rawValue)")
        switch item {
        case .check:
            delegate?.requestToPerformCheck()
        }
    }
}




