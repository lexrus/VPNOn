//
//  AppDelegate.swift
//  VPNOn
//
//  Created by Lex Tang on 12/5/14.
//  Copyright (c) 2014 LexTang.com. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let splitViewController = self.window!.rootViewController as UISplitViewController
        splitViewController.delegate = self
        splitViewController.preferredDisplayMode = .AllVisible
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
    
    // MARK: - URL scheme
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        var title = ""
        var server = url.host ?? ""
        var account = url.user ?? ""
        var password = url.password ?? ""
        var group = ""
        var secret = ""
        
        // The server is required, otherwise we just open the container app.
        if server.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 {
            return true
        }
        
        // Parse the query string.
        if let params = url.query {
            for paramString in params.componentsSeparatedByString("&") {
                let param = paramString.componentsSeparatedByString("=")
                if param.count == 2 {
                    let value = param[1] ?? ""
                    switch param[0] {
                    case "title":
                        title = value
                        break
                    case "group":
                        group = value
                        break
                    case "secret":
                        secret = value
                        break
                    default:
                        ()
                    }
                }
            }
        }
        
        let splitVC = window!.rootViewController as UISplitViewController
        
        let detailNC = splitVC.viewControllers.last! as UINavigationController
        detailNC.popToRootViewControllerAnimated(false)
        
        let createVC = splitVC.storyboard!.instantiateViewControllerWithIdentifier(
            NSStringFromClass(LTVPNCreateViewController)
            ) as LTVPNCreateViewController
        
        detailNC.pushViewController(createVC, animated: false)
        
        if let info = createVC.initializedVPNInfo {
            info.title = title
            info.server = server
            info.account = account
            info.password = password
            info.group = group
            info.secret = secret
        }
        
        return true
    }
    
    // MARK: - Split view
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController!, ontoPrimaryViewController primaryViewController:UIViewController!) -> Bool {
        if let secondaryAsNavController = secondaryViewController as? UINavigationController {
            if let topAsDetailController = secondaryAsNavController.topViewController {
                // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
                return true
            }
        }
        return false
    }
}

