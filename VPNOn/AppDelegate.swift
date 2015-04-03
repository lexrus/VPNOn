//
//  AppDelegate.swift
//  VPNOn
//
//  Created by Lex Tang on 12/5/14.
//  Copyright (c) 2014 LexTang.com. All rights reserved.
//

import UIKit
import CoreData
import VPNOnKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let splitViewController = self.window!.rootViewController as UISplitViewController
        splitViewController.delegate = self
        splitViewController.preferredDisplayMode = .AllVisible
        
        LTThemeManager.sharedManager.activateTheme()
        
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
        var willConnect = false
        var callback = ""
        
        if let query = url.query {
            let comps = query.componentsSeparatedByString("&")
            if query == "connect" {
                willConnect = true
            } else if comps.count > 1 {
                if comps[0] == "connect" {
                    willConnect = true
                }
                let callbackQuery = comps[1].componentsSeparatedByString("=")
                if callbackQuery[0] == "callback" {
                    callback = callbackQuery[1]
                }
            }
        }
        
        if willConnect {
            if let title = url.host {
                let vpns = VPNDataManager.sharedManager.VPNHasTitle(title)
                if vpns.count > 0 {
                    let vpn = vpns[0]
                    let passwordRef = VPNKeychainWrapper.passwordForVPNID(vpn.ID)
                    let secretRef = VPNKeychainWrapper.secretForVPNID(vpn.ID)
                    let certificate = VPNKeychainWrapper.certificateForVPNID(vpn.ID)
                    
                    VPNDataManager.sharedManager.selectedVPNID = vpn.objectID
                    NSNotificationCenter.defaultCenter().postNotificationName("kLTSelectionDidChange", object: nil)
                    
                    if vpn.ikev2 {
                        VPNManager.sharedManager.connectIKEv2(vpn.title, server: vpn.server, account: vpn.account, group: vpn.group, alwaysOn: vpn.alwaysOn, passwordRef: passwordRef, secretRef: secretRef, certificate: certificate)
                    } else {
                        VPNManager.sharedManager.connectIPSec(vpn.title, server: vpn.server, account: vpn.account, group: vpn.group, alwaysOn: vpn.alwaysOn, passwordRef: passwordRef, secretRef: secretRef, certificate: certificate)
                    }
                    
                    if !callback.isEmpty {
                        if let url = NSURL(string: callback) {
                            UIApplication.sharedApplication().openURL(url)
                        }
                    }
                }
            }
        } else {
            if let host = url.host {
                if let info = VPN.parseURL(url) {
                    let splitVC = window!.rootViewController as UISplitViewController
                    
                    let detailNC = splitVC.viewControllers.last! as UINavigationController
                    detailNC.popToRootViewControllerAnimated(false)
                    
                    let createVC = splitVC.storyboard!.instantiateViewControllerWithIdentifier(
                        NSStringFromClass(LTVPNConfigViewController)
                        ) as LTVPNConfigViewController
                    createVC.initializedVPNInfo = info
                    
                    detailNC.pushViewController(createVC, animated: false)
                }
            }
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

