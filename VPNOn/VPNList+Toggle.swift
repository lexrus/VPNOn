//
//  VPNList+Toggle.swift
//  VPNOn
//
//  Created by Lex on 12/20/15.
//  Copyright © 2017 lexrus.com. All rights reserved.
//

import UIKit
import VPNOnKit

extension VPNList {
    
    @IBAction func toggleVPN(_ sender: UISwitch) {
        if sender.isOn {
            guard let vpn = VPNDataManager.shared.activatedVPN else {
                return
            }
            VPNManager.shared.saveAndConnect(vpn.toAccount())
            pendingProfile = true
        } else {
            VPNManager.shared.disconnect()
            pendingProfile = false
        }
    }
    
}
