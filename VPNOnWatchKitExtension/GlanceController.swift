//
//  GlanceController.swift
//  VPN On WatchKit Extension
//
//  Created by Lex Tang on 3/30/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import WatchKit
import Foundation
import VPNOnKit


class GlanceController: VPNInterfaceController {

    @IBOutlet weak var tableView: WKInterfaceTable!
    
    override func willActivate() {
        super.willActivate()
        
        loadVPNs()
    }
    
    func loadVPNs() {
        if vpns.count > 0 {
            self.tableView.setNumberOfRows(vpns.count, withRowType: "VPNRow")
            
            for i in 0...vpns.count-1 {
                if let row = self.tableView.rowControllerAtIndex(i) as! VPNRowInGlance? {
                    let vpn = vpns[i]
                    
                    if let countryCode = vpn.countryCode {
                        row.flag.setImageNamed(countryCode)
                    }
                    row.titleLabel.setText(vpn.title)
                    row.latency = LTPingQueue.sharedQueue.latencyForHostname(vpn.server)
                    
                    let connected = Bool(VPNManager.sharedManager.status == .Connected && vpn.ID == selectedID)
                    let backgroundColor = connected ? UIColor(red:0, green:0.6, blue:1, alpha:1) : UIColor(white: 1.0, alpha: 0.2)
                    row.group.setBackgroundColor(backgroundColor)
                }
            }
        } else {
            self.tableView.setNumberOfRows(1, withRowType: "HintRow")
        }
    }
    
    // MARK: - Notification
    
    func pingDidUpdate(notification: NSNotification) {
        loadVPNs()
    }
    
    func coreDataDidSave(notification: NSNotification) {
        VPNDataManager.sharedManager.managedObjectContext?.mergeChangesFromContextDidSaveNotification(notification)
        loadVPNs()
    }
    
    func VPNStatusDidChange(notification: NSNotification?) {
        loadVPNs()
        if VPNManager.sharedManager.status == .Disconnected {
            LTPingQueue.sharedQueue.restartPing()
        }
    }

}
