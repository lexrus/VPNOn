//
//  VPNEditor.swift
//  VPN On
//
//  Created by Lex Tang on 12/4/14.
//  Copyright (c) 2014 LexTang.com. All rights reserved.
//

import UIKit
import VPNOnKit
import CoreData

let kVPNDidCreate = "kVPNDidCreate"
let kVPNDidUpdate = "kVPNDidUpdate"
let kVPNDidRemove = "kVPNDidRemove"
let kVPNDidDuplicate = "kVPNDidDuplicate"

class VPNEditor : UITableViewController, UITextFieldDelegate {

    var initializedVPNInfo: VPNInfo?
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var typeSegment: UISegmentedControl!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var serverTextField: UITextField!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var groupTextField: UITextField!
    @IBOutlet weak var secretTextField: UITextField!
    @IBOutlet weak var alwaysOnSwitch: UISwitch!
    
    @IBOutlet weak var secretCell: UITableViewCell!
    @IBOutlet weak var groupCell: UITableViewCell!

    @IBOutlet weak var deleteCell: UITableViewCell!
    @IBOutlet weak var duplicateCell: UITableViewCell!
    
    @IBAction func didChangeAlwaysOn(sender: AnyObject) {
        toggleSaveButtonByStatus()
    }
    
    lazy var vpn: VPN? = {
        if let ID = VPNDataManager.sharedManager.selectedVPNID {
            return VPNDataManager.sharedManager.VPNByID(ID)
        }
        return nil
    }()
    
    override func loadView() {
        super.loadView()
        
        let backgroundView = LTViewControllerBackground()
        tableView.backgroundView = backgroundView
    }
    
    override func viewWillAppear(animated: Bool) {
        saveButton?.enabled = false
        
        if let info = initializedVPNInfo {
            if info.title != "" {
                titleTextField.text = info.title
                serverTextField.text = info.server
                accountTextField.text = info.account
                passwordTextField.text = info.password
                groupTextField.text = info.group
                secretTextField.text = info.secret
                alwaysOnSwitch.on = info.alwaysOn
                typeSegment.selectedSegmentIndex = info.ikev2 ? 1 : 0
            }
            
            deleteCell.hidden = true
            duplicateCell.hidden = true
        } else if let currentVPN = vpn {
            titleTextField.text = currentVPN.title
            serverTextField.text = currentVPN.server
            accountTextField.text = currentVPN.account
            groupTextField.text = currentVPN.group
            alwaysOnSwitch.on = currentVPN.alwaysOn
            typeSegment.selectedSegmentIndex = currentVPN.ikev2 ? 1 : 0
            passwordTextField.text = VPNKeychainWrapper.passwordStringForVPNID(currentVPN.ID)
            secretTextField.text = VPNKeychainWrapper.secretStringForVPNID(currentVPN.ID)
            deleteCell.hidden = false
            duplicateCell.hidden = false
        }
        
        toggleSaveButtonByStatus()
    }
    
    override func viewWillDisappear(animated: Bool) {
        initializedVPNInfo = nil
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}
