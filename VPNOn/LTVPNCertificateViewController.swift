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
    @IBOutlet weak var certificateSummaryCell: LTVPNTableViewCell!
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
    
    private var _downloading = false
    var downloading: Bool {
        get {
            return _downloading
        }
        set {
            _downloading = newValue
            self.downloadCell.textLabel!.text = _downloading ? "Downloading..." : "Download"
            self.downloadCell.disabled = _downloading
        }
    }
    
    private var _certificateData: NSData? = nil
    var certificateData: NSData? {
        get {
            return _certificateData
        }
        set {
            _certificateData = newValue
            self.updateCertificateSummary()
            self.updateSaveButton()
        }
    }
    
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
        // TODO: Save certificate data
        
        popDetailViewController()
    }
    
    func updateSaveButton() {
        if certificateData == nil {
            saveButton.enabled = false
        } else {
            saveButton.enabled = true
        }
    }
    
    // MARK: - Download && Scan && Delete
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if cell == deleteCell {
                
            } else if cell == downloadCell {
                downloadURL()
            } else if cell == scanCell {
                
            }
        }
    }
    
    func downloadURL() {
        downloading = true
        if let URL = NSURL(string: certificateURLField.text) {
            LTVPNDownloader().download(URL) {
                response, data, error in
                dispatch_async(dispatch_get_main_queue(), {
                    if let err = error {
                        self.certificateSummaryCell.textLabel!.text = error.localizedDescription
                    } else {
                        self.certificateData = data
                    }
                    self.downloading = false
                })
            }
        }
    }
    
    func updateCertificateSummary() {
        if let data = certificateData {
            let bytesFormatter = NSByteCountFormatter()
            bytesFormatter.countStyle = NSByteCountFormatterCountStyle.File
            let bytesCount = bytesFormatter.stringFromByteCount(Int64(data.length))
            certificateSummaryCell.textLabel!.text = "Certificate downloaded (\(bytesCount))"
        } else {
            certificateSummaryCell.textLabel!.text = "Certificate will be downloaded and stored in Keychain"
        }
    }
    
    // MARK: - TextField delegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        updateCertificateSummary()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        updateCertificateSummary()
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        downloadURL()
        return true
    }
    
    // MARK: - Navigation
    
    func popDetailViewController() {
        let topNavigationController = splitViewController!.viewControllers.last! as UINavigationController
        topNavigationController.popViewControllerAnimated(true)
    }
    
}
