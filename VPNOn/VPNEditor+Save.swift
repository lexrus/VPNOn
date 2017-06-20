//
//  VPNEditor+Save.swift
//  VPNOn
//
//  Created by Lex on 1/23/15.
//  Copyright (c) 2017 lexrus.com. All rights reserved.
//

import UIKit
import VPNOnKit

extension VPNEditor {

    @IBAction func saveVPN(_ sender: AnyObject) {
        if let currentVPN = vpn {
            currentVPN.title = titleTextField.text
            currentVPN.server = serverTextField.text
            currentVPN.account = accountTextField.text
            currentVPN.group = groupTextField.text
            currentVPN.remoteID = remoteIDTextField.text
            currentVPN.alwaysOn = alwaysOnSwitch.isOn
            currentVPN.ikev2 = typeSegment.selectedSegmentIndex == 1
            
            KeychainWrapper.setPassword(
                passwordTextField.text ?? "",
                forVPNID: currentVPN.ID
            )
            
            KeychainWrapper.setSecret(
                secretTextField.text ?? "",
                forVPNID: currentVPN.ID
            )
            
            VPNDataManager.sharedManager.saveContext()
            
            NotificationCenter.default
                .post(name: Notification.Name(rawValue: kVPNDidUpdate), object: currentVPN)
        } else {
            if let lastVPN = VPNDataManager.sharedManager.createVPN(
                titleTextField.text ?? "",
                server: serverTextField.text ?? "",
                account: accountTextField.text ?? "",
                password: passwordTextField.text ?? "",
                group: groupTextField.text ?? "",
                secret: secretTextField.text ?? "",
                alwaysOn: alwaysOnSwitch.isOn,
                ikev2: typeSegment.selectedSegmentIndex == 1,
                remoteID: remoteIDTextField.text
                ) {
                    NotificationCenter.default
                        .post(name: Notification.Name(rawValue: kVPNDidCreate), object: lastVPN)
            }
        }
    }
    
    func toggleSaveButtonByStatus() {
        saveButton?.isEnabled = false
        if let title = titleTextField.text,
            let account = accountTextField.text,
            let server = serverTextField.text {
                if !title.isEmpty && !account.isEmpty && !server.isEmpty {
                    saveButton?.isEnabled = true
                }
        }
    }

}
