//
//  LTVPNCertificateViewController.swift
//  VPNOn
//
//  Created by Lex on 1/23/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit
import VPNOnKit

class LTVPNCertificateViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var certificateURLField: UITextField!
    @IBOutlet weak var deleteCell: UITableViewCell!
    @IBOutlet weak var downloadCell: LTTableViewActionCell!
    @IBOutlet weak var scanCell: LTTableViewActionCell!
    
    lazy var vpn: VPN? = {
        if let ID = VPNDataManager.sharedManager.selectedVPNID {
            if let result = VPNDataManager.sharedManager.VPNByID(ID) {
                let vpn = result
                return vpn
            }
        }
        return Optional.None
        }()
    
    private var downloading = false
    private var certificateData: NSData? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let vpnObject = vpn {
            if let certificate = VPNKeychainWrapper.certificateForVPNID(vpnObject.ID) {
                certificateData = certificate
            }
        }
        
        updateSaveButton()
    }
    
    // MARK: - Save
    
    @IBAction func save(sender: AnyObject) {
        popDetailViewController()
    }
    
    func updateSaveButton() {
        saveButton.enabled = !certificateURLField.text!.isEmpty
    }
    
    // MARK: - Download && Scan && Delete
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if cell == deleteCell {
                
            } else if cell == downloadCell {
                
            } else if cell == scanCell {
                
            }
        }
    }
    
    // MARK: - TextField delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        // TODO: Download URL
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        updateSaveButton()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        updateSaveButton()
        return true
    }
    
    // MARK: - Navigation
    
    func popDetailViewController() {
        let topNavigationController = splitViewController!.viewControllers.last! as UINavigationController
        topNavigationController.popViewControllerAnimated(true)
    }
    
}
