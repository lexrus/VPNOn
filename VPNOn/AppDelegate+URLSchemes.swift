//
//  AppDelegate+URLSchemes.swift
//  VPNOn
//
//  Created by Lex on 10/3/15.
//  Copyright © 2015 LexTang.com. All rights reserved.
//

import UIKit
import CoreData
import VPNOnKit

extension AppDelegate {
    
    func application(application: UIApplication, handleOpenURL URL: NSURL) -> Bool {
        var willConnect = false
        var callback: String?
        
        if let query = URL.query {
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
            connectVPNWithURL(URL, callback: callback ?? "")
        } else {
            initialCreateViewWithURL(URL)
        }
        
        return true
    }
    
    private func connectVPNWithURL(URL: NSURL, callback: String) {
        if let title = URL.host {
            let vpns = VPNDataManager.sharedManager.VPNHasTitle(title)
            if vpns.count > 0 {
                let vpn = vpns[0]
                let passwordRef = VPNKeychainWrapper.passwordForVPNID(vpn.ID)
                let secretRef = VPNKeychainWrapper.secretForVPNID(vpn.ID)
                
                VPNDataManager.sharedManager.selectedVPNID = vpn.objectID
                NSNotificationCenter.defaultCenter().postNotificationName("kSelectionDidChange", object: nil)
                
                if vpn.ikev2 {
                    VPNManager.sharedManager.connectIKEv2(
                        vpn.title,
                        server: vpn.server,
                        account: vpn.account,
                        group: vpn.group,
                        alwaysOn: vpn.alwaysOn,
                        passwordRef: passwordRef,
                        secretRef: secretRef)
                } else {
                    VPNManager.sharedManager.connectIPSec(
                        vpn.title,
                        server: vpn.server,
                        account: vpn.account,
                        group: vpn.group,
                        alwaysOn: vpn.alwaysOn,
                        passwordRef: passwordRef,
                        secretRef: secretRef)
                }
                
                if !callback.isEmpty {
                    if let url = NSURL(string: callback) {
                        UIApplication.sharedApplication().openURL(url)
                    }
                }
            }
        }
    }
    
    private func initialCreateViewWithURL(URL: NSURL) {
        if let _ = URL.host, info = VPN.parseURL(URL) {
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
}