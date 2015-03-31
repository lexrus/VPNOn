//
//  VPNInterfaceController.swift
//  VPNOn
//
//  Created by Lex on 3/30/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import WatchKit
import Foundation
import NetworkExtension
import CoreData
import VPNOnKit


class VPNInterfaceController: WKInterfaceController {
    
    var vpns: [VPN] {
        get {
            return VPNDataManager.sharedManager.allVPN()
        }
    }
    
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
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
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

}
