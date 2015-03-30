//
//  InterfaceController.swift
//  VPN On WatchKit Extension
//
//  Created by Lex Tang on 3/30/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import WatchKit
import Foundation
import VPNOnKit
import CoreData
import NetworkExtension

let kVPNOnSelectedIDInToday = "kVPNOnSelectedIDInToday"

class InterfaceController: WKInterfaceController {
    var vpns: [VPN] {
        get {
            return VPNDataManager.sharedManager.allVPN()
        }
    }
    
    @IBOutlet weak var tableView: WKInterfaceTable!
    
    var selectedID: String? {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey(kVPNOnSelectedIDInToday) as String?
        }
        set {
            if let newID = newValue {
                NSUserDefaults.standardUserDefaults().setObject(newID, forKey: kVPNOnSelectedIDInToday)
            } else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey(kVPNOnSelectedIDInToday)
            }
            
        }
    }

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("coreDataDidSave:"),
            name: NSManagedObjectContextDidSaveNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("VPNStatusDidChange:"),
            name: NEVPNStatusDidChangeNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("pingDidUpdate:"),
            name: "kLTPingDidUpdate",
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: Selector("didTurnOnVPN:"),
            name: kDidTurnOnVPN,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: Selector("didTurnOffVPN:"),
            name: kDidTurnOffVPN,
            object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        loadVPNs()
    }
    
    func loadVPNs() {
        if vpns.count > 0 {
            self.tableView.setNumberOfRows(vpns.count, withRowType: "VPNRow")
            
            for i in 0...vpns.count-1 {
                if let row = self.tableView.rowControllerAtIndex(i) as VPNRow? {
                    let vpn = vpns[i]
                    
                    if let countryCode = vpn.countryCode {
                        row.flag.setImageNamed(countryCode)
                    }
                    
                    row.latency = LTPingQueue.sharedQueue.latencyForHostname(vpn.server)
                    
                    let connected = Bool(VPNManager.sharedManager.status == .Connected && vpn.ID == selectedID)
                    row.VPNSwitch.setOn(connected)
                }
            }
        } else {
            self.tableView.setNumberOfRows(1, withRowType: "HintRow")
        }
    }
    
    func didTurnOnVPN(notifiction: NSNotification) {
        if let userInfo = notifiction.userInfo as [String: Int]? {
            if let index = userInfo[kVPNIndexKey] {
                let vpn = vpns[index]
                selectedID = vpn.ID
                connectVPN(vpn)
            }
        }
    }
    
    func didTurnOffVPN(notification: NSNotification) {
        VPNManager.sharedManager.disconnect()
        loadVPNs()
    }
    
    func connectVPN(vpn: VPN) {
        let passwordRef = VPNKeychainWrapper.passwordForVPNID(vpn.ID)
        let secretRef = VPNKeychainWrapper.secretForVPNID(vpn.ID)
        let certificate = VPNKeychainWrapper.certificateForVPNID(vpn.ID)
        let titleWithSubfix = "Widget - \(vpn.title)"
        
        if vpn.ikev2 {
            VPNManager.sharedManager.connectIKEv2(titleWithSubfix,
                server: vpn.server,
                account: vpn.account,
                group: vpn.group,
                alwaysOn: vpn.alwaysOn,
                passwordRef: passwordRef,
                secretRef: secretRef,
                certificate: certificate)
        } else {
            VPNManager.sharedManager.connectIPSec(titleWithSubfix,
                server: vpn.server,
                account: vpn.account,
                group: vpn.group,
                alwaysOn: vpn.alwaysOn,
                passwordRef: passwordRef,
                secretRef: secretRef,
                certificate: certificate)
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
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
