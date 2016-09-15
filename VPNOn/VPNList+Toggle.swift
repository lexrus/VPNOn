//
//  VPNList+Toggle.swift
//  VPNOn
//
//  Created by Lex on 12/20/15.
//  Copyright © 2016 lexrus.com. All rights reserved.
//

import UIKit
import VPNOnKit

extension VPNList {
    
    @IBAction func toggleVPN(_ sender: UISwitch) {
        if sender.isOn {
            guard let vpn = VPNDataManager.sharedManager.activatedVPN else {
                return
            }
            VPNManager.sharedManager.saveAndConnect(vpn.toAccount())
        } else {
            VPNManager.sharedManager.disconnect()
        }
    }
    
}
