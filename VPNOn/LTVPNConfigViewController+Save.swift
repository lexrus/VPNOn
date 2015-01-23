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
            
            if passwordTextField!.text != kImpossibleHash {
                VPNKeychainWrapper.setPassword(passwordTextField!.text, forVPNID: currentVPN.ID)
            }
            
            if secretTextField!.text != kImpossibleHash {
                VPNKeychainWrapper.setSecret(secretTextField!.text, forVPNID: currentVPN.ID)
            }
            
            VPNDataManager.sharedManager.saveContext()
            
            NSNotificationCenter.defaultCenter().postNotificationName(kLTVPNDidUpdate, object: nil)
        } else {
            let success = VPNDataManager.sharedManager.createVPN(
                titleTextField.text,
                server: serverTextField.text,
                account: accountTextField.text,
                password: passwordTextField.text,
                group: groupTextField.text,
                secret: secretTextField.text,
                alwaysOn: alwaysOnSwitch.on
            )
            
            if success {
                NSNotificationCenter.defaultCenter().postNotificationName(kLTVPNDidCreate, object: self)
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
