//
//  VPNList+Toggle.swift
//  VPNOn
//
//  Created by Lex on 12/20/15.
//  Copyright © 2015 LexTang.com. All rights reserved.
//

import UIKit
import VPNOnKit

extension VPNList {
    
    @IBAction func toggleVPN(sender: UISwitch) {
        if sender.on {
            guard let vpn = VPNDataManager.sharedManager.activatedVPN else {
                return
            }
            let passwordRef = Keychain.passwordForVPNID(vpn.ID)
            let secretRef = Keychain.secretForVPNID(vpn.ID)
            
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
        } else {
            VPNManager.sharedManager.disconnect()
        }
    }
    
}
