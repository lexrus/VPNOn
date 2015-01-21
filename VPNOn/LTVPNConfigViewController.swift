//
//  LTVPNConfigViewController.swift
//  VPN On
//
//  Created by Lex Tang on 12/4/14.
//  Copyright (c) 2014 LexTang.com. All rights reserved.
//

import UIKit
import VPNOnKit
import CoreData

let kLTVPNDidCreate = "kLTVPNDidCreate"
let kLTVPNDidUpdate = "kLTVPNDidUpdate"
let kLTVPNDidRemove = "kLTVPNDidRemove"
let kImpossibleHash = "~!@#$%^+_)(*&"

class LTVPNConfigViewController: UITableViewController, UITextFieldDelegate
{
    
    var initializedVPNInfo : VPNInfo? = VPNInfo()
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var serverTextField: UITextField!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var groupTextField: UITextField!
    @IBOutlet weak var secretTextField: UITextField!
    @IBOutlet weak var alwaysOnSwitch: UISwitch!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var deleteCell: UITableViewCell!
    @IBOutlet weak var duplicateCell: UITableViewCell!
    
    lazy var vpn: VPN? = {
        if let ID = VPNDataManager.sharedManager.selectedVPNID {
            if let result = VPNDataManager.sharedManager.VPNByID(ID) {
                let vpn = result
                return vpn
            }
        }
        return Optional.None
        }()
    
    @IBAction func didChangeAlwaysOn(sender: AnyObject) {
        toggleSaveButtonByStatus()
    }
    
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
    
    override func loadView() {
        super.loadView()
        
        let backgroundView = LTViewControllerBackground()
        tableView.backgroundView = backgroundView
    }
    
    override func viewWillAppear(animated: Bool) {
        saveButton?.enabled = false
        
        if let currentVPN = vpn {
            titleTextField.text = currentVPN.title
            serverTextField.text = currentVPN.server
            accountTextField.text = currentVPN.account
            groupTextField.text = currentVPN.group
            alwaysOnSwitch.on = currentVPN.alwaysOn
            
            if let passwordRef = VPNKeychainWrapper.passwordForVPNID(currentVPN.ID) {
                passwordTextField!.text = kImpossibleHash
            }
            
            if let secretRef = VPNKeychainWrapper.secretForVPNID(currentVPN.ID) {
                secretTextField!.text = kImpossibleHash
            }
            
            deleteCell.hidden = false
            duplicateCell.hidden = false
        } else if let info = initializedVPNInfo {
            if info.title != "" {
                titleTextField.text = info.title
                serverTextField.text = info.server
                accountTextField.text = info.account
                passwordTextField.text = info.password
                groupTextField.text = info.group
                secretTextField.text = info.secret
                alwaysOnSwitch.on = info.alwaysOn
                toggleSaveButtonByStatus()
            }
            
            deleteCell.hidden = true
            duplicateCell.hidden = true
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        initializedVPNInfo = nil
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
