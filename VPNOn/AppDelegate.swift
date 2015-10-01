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
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        splitViewController.delegate = self
        splitViewController.preferredDisplayMode = .AllVisible
        
        LTThemeManager.sharedManager.activateTheme()
        
        return true
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
                    
                    VPNDataManager.sharedManager.selectedVPNID = vpn.objectID
                    NSNotificationCenter.defaultCenter().postNotificationName("kSelectionDidChange", object: nil)
                    
                    if vpn.ikev2 {
                        VPNManager.sharedManager.connectIKEv2(vpn.title, server: vpn.server, account: vpn.account, group: vpn.group, alwaysOn: vpn.alwaysOn, passwordRef: passwordRef, secretRef: secretRef)
                    } else {
                        VPNManager.sharedManager.connectIPSec(vpn.title, server: vpn.server, account: vpn.account, group: vpn.group, alwaysOn: vpn.alwaysOn, passwordRef: passwordRef, secretRef: secretRef)
                    }
                    
                    if !callback.isEmpty {
                        if let url = NSURL(string: callback) {
                            UIApplication.sharedApplication().openURL(url)
                        }
                    }
                }
            }
        } else {
            if let _ = url.host, info = VPN.parseURL(url) {
                let splitVC = window!.rootViewController as! UISplitViewController
                
                let detailNC = splitVC.viewControllers.last! as! UINavigationController
                detailNC.popToRootViewControllerAnimated(false)
                
                let createVC = splitVC.storyboard!.instantiateViewControllerWithIdentifier(
                    NSStringFromClass(VPNConfigViewController)
                    ) as! VPNConfigViewController
                createVC.initializedVPNInfo = info
                
                detailNC.pushViewController(createVC, animated: false)
            }
        }
        
        return true
    }
    
    // MARK: - Split view
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        if let secondaryAsNavController = secondaryViewController as? UINavigationController {
            if let _ = secondaryAsNavController.topViewController {
                // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
                return true
            }
        }
        return false
    }
}

