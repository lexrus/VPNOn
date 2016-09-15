//
//  AppDelegate+URLSchemes.swift
//  VPNOn
//
//  Created by Lex on 10/3/15.
//  Copyright © 2016 lexrus.com. All rights reserved.
//

import UIKit
import CoreData
import VPNOnKit

extension AppDelegate {
    
    @objc(application:handleOpenURL:) func application(_ application: UIApplication, handleOpen URL: URL) -> Bool {
        var willConnect = false
        var callback: String = ""
        
        // Ignore query while the host is equal to "disconnect"
        if URL.host == "disconnect" {
            VPNManager.sharedManager.disconnect()
            return true
        }
        
        if let query = URL.query {
            let comps = query.components(separatedBy: "&")
            if query == "connect" {
                willConnect = true
            } else if comps.count > 1 {
                if comps[0] == "connect" {
                    willConnect = true
                }
                let callbackQuery = comps[1].components(separatedBy: "=")
                if callbackQuery[0] == "callback" {
                    callback = callbackQuery[1]
                }
            }
        }
        
        if willConnect {
            let delayTime = DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                [weak self] in
                self?.connectVPNWithURL(URL, callback: callback)
            }
        } else {
            initialCreateViewWithURL(URL)
        }
        
        return true
    }
    
    fileprivate func connectVPNWithURL(_ URL: Foundation.URL, callback: String) {
        guard let title = URL.host else { return }
        
        let vpns = VPNDataManager.sharedManager.VPNHasTitle(title)
        guard let vpn = vpns.first else { return }
        
        VPNDataManager.sharedManager.selectedVPNID = vpn.objectID
        
        NotificationCenter.default
            .post(name: Notification.Name(rawValue: kSelectionDidChange), object: nil)
        
        VPNManager.sharedManager.saveAndConnect(vpn.toAccount())
        
        if !callback.isEmpty {
            if let url = Foundation.URL(string: callback) {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    fileprivate func initialCreateViewWithURL(_ URL: Foundation.URL) {
        // If the host is empty, do nothing
        guard let _ = URL.host, let info = VPN.parseURL(URL) else { return }
        guard let splitVC = window?.rootViewController as? UISplitViewController else { return }
        guard let detailNC = splitVC.viewControllers.last as? UINavigationController else { return }
        let mainSB = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        guard let editorVC = mainSB.instantiateViewController(withIdentifier: "VPNEditor") as? VPNEditor else { return }
        editorVC.initializedVPNInfo = info
        detailNC.pushViewController(editorVC, animated: false)
    }

}
