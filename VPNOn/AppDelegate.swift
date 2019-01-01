//
//  AppDelegate.swift
//  VPNOn
//
//  Created by Lex Tang on 12/5/14.
//  Copyright (c) 2017 lexrus.com. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate:
    UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if let splitViewController = window?.rootViewController
            as? UISplitViewController {
            splitViewController.delegate = self
            splitViewController.preferredDisplayMode = .allVisible
        }
        
        LTThemeManager.shared.activateTheme()

        return true
    }
    
    // MARK: - Split view
    
    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController:UIViewController,
        onto primaryViewController:UIViewController
        ) -> Bool {
            guard
                let secondaryAsNavController = secondaryViewController as? UINavigationController,
                secondaryAsNavController.topViewController != nil
            else { return false }

            return true
    }
}
