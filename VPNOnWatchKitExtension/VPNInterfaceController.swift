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

let kGreetingsFromContainer = "Greetings"


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
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: Selector("loadVPNs"),
            name: kGreetingsFromContainer,
            object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func willActivate() {
        super.willActivate()
        
        VPNManager.sharedManager.wormhole.listenForMessageWithIdentifier(kGreetingsFromContainer) {
            messageObject in
            NSNotificationCenter.defaultCenter().postNotificationName(kGreetingsFromContainer, object: nil)
        }
    }

    override func didDeactivate() {
        super.didDeactivate()
        
        VPNManager.sharedManager.wormhole.stopListeningForMessageWithIdentifier(kGreetingsFromContainer)
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
