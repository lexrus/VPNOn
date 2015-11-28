//
//  VPNEditor+Save.swift
//  VPNOn
//
//  Created by Lex on 1/23/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit
import VPNOnKit

extension VPNEditor {

    @IBAction func saveVPN(sender: AnyObject) {
        if let currentVPN = vpn {
            currentVPN.title = titleTextField.text
            currentVPN.server = serverTextField.text
            currentVPN.account = accountTextField.text
            currentVPN.group = groupTextField.text
            currentVPN.alwaysOn = alwaysOnSwitch.on
            currentVPN.ikev2 = typeSegment.selectedSegmentIndex == 1
            
            Keychain.setPassword(passwordTextField.text ?? "", forVPNID: currentVPN.ID)
            
            Keychain.setSecret(secretTextField.text ?? "", forVPNID: currentVPN.ID)
            
            VPNDataManager.sharedManager.saveContext()
            
            NSNotificationCenter.defaultCenter().postNotificationName(kVPNDidUpdate, object: currentVPN)
        } else {
            if let lastVPN = VPNDataManager.sharedManager.createVPN(
                titleTextField.text ?? "",
                server: serverTextField.text ?? "",
                account: accountTextField.text ?? "",
                password: passwordTextField.text ?? "",
                group: groupTextField.text ?? "",
                secret: secretTextField.text ?? "",
                alwaysOn: alwaysOnSwitch.on,
                ikev2: typeSegment.selectedSegmentIndex == 1
                ) {
                    NSNotificationCenter.defaultCenter().postNotificationName(kVPNDidCreate, object: lastVPN)
            }
        }
    }
    
    func toggleSaveButtonByStatus() {
        saveButton?.enabled = false
        if let title = titleTextField.text, account = accountTextField.text, server = serverTextField.text {
            if !title.isEmpty && !account.isEmpty && !server.isEmpty {
                saveButton?.enabled = true
            }
        }
    }

}
