//
//  LTVPNConfigViewController+Save.swift
//  VPNOn
//
//  Created by Lex on 1/23/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit
import VPNOnKit

extension LTVPNConfigViewController
{
    @IBAction func saveVPN(sender: AnyObject) {
        if let currentVPN = vpn {
            currentVPN.title = titleTextField.text
            currentVPN.server = serverTextField.text
            currentVPN.account = accountTextField.text
            currentVPN.group = groupTextField.text
            currentVPN.alwaysOn = alwaysOnSwitch.on
            currentVPN.ikev2 = typeSegment.selectedSegmentIndex == 1
            currentVPN.certificateURL = certificateURL
            
            VPNKeychainWrapper.setPassword(passwordTextField.text, forVPNID: currentVPN.ID)
            
            VPNKeychainWrapper.setSecret(secretTextField.text, forVPNID: currentVPN.ID)
            
            VPNDataManager.sharedManager.saveContext()
            
            NSNotificationCenter.defaultCenter().postNotificationName(kLTVPNDidUpdate, object: currentVPN)
        } else {
            if let lastVPN = VPNDataManager.sharedManager.createVPN(
                titleTextField.text,
                server: serverTextField.text,
                account: accountTextField.text,
                password: passwordTextField.text,
                group: groupTextField.text,
                secret: secretTextField.text,
                alwaysOn: alwaysOnSwitch.on,
                ikev2: typeSegment.selectedSegmentIndex == 1,
                certificateURL: certificateURL ?? "",
                certificate: temporaryCertificateData
                ) {
                    NSNotificationCenter.defaultCenter().postNotificationName(kLTVPNDidCreate, object: lastVPN)
            }
        }
    }
    
    func toggleSaveButtonByStatus() {
        if self.titleTextField.text.isEmpty
            || self.accountTextField.text.isEmpty
            || self.serverTextField.text.isEmpty {
                self.saveButton?.enabled = false
        } else {
            self.saveButton?.enabled = true
        }
    }
}
