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
        var callback: String = ""
        
        // Ignore query while the host is equal to "disconnect"
        if URL.host == "disconnect" {
            VPNManager.sharedManager.disconnect()
            return true
        }
        
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
            let delayTime = dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(0.3 * Double(NSEC_PER_SEC))
            )
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                [weak self] in
                self?.connectVPNWithURL(URL, callback: callback)
            }
        } else {
            initialCreateViewWithURL(URL)
        }
        
        return true
    }
    
    private func connectVPNWithURL(URL: NSURL, callback: String) {
        guard let title = URL.host else { return }
        
        let vpns = VPNDataManager.sharedManager.VPNHasTitle(title)
        guard let vpn = vpns.first else { return }
        
        VPNDataManager.sharedManager.selectedVPNID = vpn.objectID
        
        NSNotificationCenter.defaultCenter()
            .postNotificationName(kSelectionDidChange, object: nil)
        
        VPNManager.sharedManager.saveAndConnect(vpn.toAccount())
        
        if !callback.isEmpty {
            if let url = NSURL(string: callback) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }
    
    private func initialCreateViewWithURL(URL: NSURL) {
        // If the host is empty, do nothing
        guard let _ = URL.host, info = VPN.parseURL(URL) else { return }
        guard let splitVC = window?.rootViewController as? UISplitViewController else { return }
        guard let detailNC = splitVC.viewControllers.last as? UINavigationController else { return }
        let mainSB = UIStoryboard.init(name: "Main", bundle: NSBundle.mainBundle())
        guard let editorVC = mainSB.instantiateViewControllerWithIdentifier("VPNEditor") as? VPNEditor else { return }
        editorVC.initializedVPNInfo = info
        detailNC.pushViewController(editorVC, animated: false)
    }

}
