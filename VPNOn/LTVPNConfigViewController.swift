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
let kLTVPNDidDuplicate = "kLTVPNDidDuplicate"

class LTVPNConfigViewController: UITableViewController, UITextFieldDelegate,
LTVPNCertificateViewControllerDelegate, LTVPNDomainsViewControllerDelegate
{
    var initializedVPNInfo: VPNInfo? = nil
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var typeSegment: UISegmentedControl!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var serverTextField: UITextField!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var groupTextField: UITextField!
    @IBOutlet weak var secretTextField: UITextField!
    @IBOutlet weak var alwaysOnSwitch: UISwitch!
    
    @IBOutlet weak var certificateSwitch: UISwitch!
    
    @IBOutlet weak var secretCell: UITableViewCell!
    @IBOutlet weak var groupCell: UITableViewCell!
    @IBOutlet weak var certificateCell: UITableViewCell!
    
    @IBOutlet weak var onDemandCell: UITableViewCell!
    @IBOutlet weak var domainsCell: LTVPNTableViewCell!
    @IBOutlet weak var onDemandSwitch: UISwitch!

    @IBOutlet weak var deleteCell: UITableViewCell!
    @IBOutlet weak var duplicateCell: UITableViewCell!
    
    @IBAction func didChangeAlwaysOn(sender: AnyObject) {
        toggleSaveButtonByStatus()
    }
    
    lazy var vpn: VPN? = {
        if let ID = VPNDataManager.sharedManager.selectedVPNID {
            if let result = VPNDataManager.sharedManager.VPNByID(ID) {
                let vpn = result
                return vpn
            }
        }
        return Optional.None
        }()
    
    var certificateURL: String?
    
    var temporaryCertificateData: NSData? {
        didSet {
            if let d = self.temporaryCertificateData {
                let bytesFormatter = NSByteCountFormatter()
                bytesFormatter.countStyle = .File
                let bytesString = bytesFormatter.stringFromByteCount(Int64(d.length))
                
                if let certCell = certificateCell {
                    certCell.detailTextLabel?.text = bytesString
                }
            } else {
                if let certCell = certificateCell {
                    certCell.detailTextLabel?.text = " "
                }
            }
        }
    }
    
    var temporaryDomains: String?
    
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
            typeSegment.selectedSegmentIndex = currentVPN.ikev2 ? 1 : 0
            certificateURL = currentVPN.certificateURL
            passwordTextField.text = VPNKeychainWrapper.passwordStringForVPNID(currentVPN.ID)
            secretTextField.text = VPNKeychainWrapper.secretStringForVPNID(currentVPN.ID)
            deleteCell.hidden = false
            duplicateCell.hidden = false
            temporaryCertificateData = VPNKeychainWrapper.certificateForVPNID(currentVPN.ID)
            if temporaryCertificateData != nil {
                certificateSwitch.on = true
            }
            onDemandSwitch.on = currentVPN.onDemand
            updateDomainsCell()
        } else if let info = initializedVPNInfo {
            if info.title != "" {
                titleTextField.text = info.title
                serverTextField.text = info.server
                accountTextField.text = info.account
                passwordTextField.text = info.password
                groupTextField.text = info.group
                secretTextField.text = info.secret
                alwaysOnSwitch.on = info.alwaysOn
                typeSegment.selectedSegmentIndex = info.ikev2 ? 1 : 0
                certificateURL = info.certificateURL
                if certificateURL != nil {
                    certificateSwitch.on = true
                }
            }
            
            deleteCell.hidden = true
            duplicateCell.hidden = true
        }
        
        toggleSaveButtonByStatus()
        updateCertificateOptions()
    }
    
    override func viewWillDisappear(animated: Bool) {
        initializedVPNInfo = nil
    }
    
    deinit {
        temporaryCertificateData = nil
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "certificate" {
            if let targetVC = segue.destinationViewController as? LTVPNCertificateViewController {
                targetVC.delegate = self
                targetVC.temporaryCertificateURL = certificateURL
                targetVC.temporaryCertificateData = temporaryCertificateData
            }
        } else if segue.identifier == "domains" {
            if let targetVC = segue.destinationViewController as? LTVPNDomainsViewController {
                targetVC.delegate = self
                targetVC.domains = temporaryDomains
            }
        }
    }
}
