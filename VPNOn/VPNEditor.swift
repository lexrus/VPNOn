//
//  VPNEditor.swift
//  VPN On
//
//  Created by Lex Tang on 12/4/14.
//  Copyright (c) 2017 lexrus.com. All rights reserved.
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
    @IBOutlet weak var remoteIDTextField: UITextField!
    @IBOutlet weak var secretTextField: UITextField!
    @IBOutlet weak var alwaysOnSwitch: UISwitch!
    
    @IBOutlet weak var secretCell: UITableViewCell!
    @IBOutlet weak var groupCell: UITableViewCell!
    @IBOutlet weak var remoteIDCell: UITableViewCell!

    @IBOutlet weak var deleteCell: UITableViewCell!
    @IBOutlet weak var duplicateCell: UITableViewCell!
    
    @IBAction func didChangeAlwaysOn(_ sender: AnyObject) {
        toggleSaveButtonByStatus()
    }
    
    lazy var vpn: VPN? = {
        if let ID = VPNDataManager.shared.selectedVPNID {
            return VPNDataManager.shared.VPNByID(ID)
        }
        return nil
    }()
    
    override func loadView() {
        super.loadView()
        
        let backgroundView = LTViewControllerBackground()
        tableView.backgroundView = backgroundView
        
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidUpdate), name: .ThemeDidUpdate, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        saveButton.isEnabled = false
        deleteCell.isHidden = true
        duplicateCell.isHidden = true
        
        if let info = initializedVPNInfo {
            if info.title != "" {
                titleTextField.text = info.title
                serverTextField.text = info.server
                accountTextField.text = info.account
                passwordTextField.text = info.password
                groupTextField.text = info.group
                remoteIDTextField.text = info.remoteID
                secretTextField.text = info.secret
                alwaysOnSwitch.isOn = info.alwaysOn
                typeSegment.selectedSegmentIndex = info.ikev2 ? 1 : 0
            }
        } else if let currentVPN = vpn {
            titleTextField.text = currentVPN.title
            serverTextField.text = currentVPN.server
            accountTextField.text = currentVPN.account
            groupTextField.text = currentVPN.group
            remoteIDTextField.text = currentVPN.remoteID
            alwaysOnSwitch.isOn = currentVPN.alwaysOn
            typeSegment.selectedSegmentIndex = currentVPN.ikev2 ? 1 : 0
            passwordTextField.text =
                KeychainWrapper.passwordStringForVPNID(currentVPN.ID)
            secretTextField.text =
                KeychainWrapper.secretStringForVPNID(currentVPN.ID)
            deleteCell.isHidden = false
            duplicateCell.isHidden = false
        }
        
        toggleSaveButtonByStatus()
        
        if #available(iOS 13.0, *) {
            typeSegment.selectedSegmentTintColor = LTThemeManager.shared.currentTheme?.tintColor
        }
        LTThemeManager.shared.currentTheme.map {
            typeSegment.setTitleTextAttributes([
                NSAttributedString.Key.foregroundColor : $0.defaultBackgroundColor
            ], for: .selected)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        initializedVPNInfo = nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func themeDidUpdate() {
        guard #available(iOS 13.0, *) else {
            return
        }
            
        guard let theme = LTThemeManager.shared.currentTheme else {
            return
        }
        
        let selectedTextColor: UIColor
        let selectedSgementTintColor: UIColor
        
        switch theme {
        case is LTDarkTheme:
            selectedSgementTintColor = LTDarkTheme().tintColor
            selectedTextColor = LTDarkTheme().defaultBackgroundColor
        case is LTDarkGreenTheme:
            selectedSgementTintColor = LTDarkGreenTheme().tintColor
            selectedTextColor = LTDarkGreenTheme().defaultBackgroundColor
        case is LTDarkPurpleTheme:
            selectedSgementTintColor = LTDarkPurpleTheme().tintColor
            selectedTextColor = LTDarkPurpleTheme().defaultBackgroundColor
        default:
            selectedTextColor = .black
            selectedSgementTintColor = .white
        }
        typeSegment.selectedSegmentTintColor = selectedSgementTintColor
        typeSegment.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor : selectedTextColor
        ], for: .selected)
    }

}
