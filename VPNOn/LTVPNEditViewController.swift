//
//  LTVPNEditViewController.swift
//  VPN On
//
//  Created by Lex Tang on 12/4/14.
//  Copyright (c) 2014 LexTang.com. All rights reserved.
//

import UIKit
import CoreData
import VPNOnKit

let kSaveButtonEnabledColor = UIColor(red:0, green:0.48, blue:1, alpha:1)
let kImpossibleHash = "~!@#$%^+_)(*&"

class LTVPNEditViewController: LTVPNCreateViewController {
    
    var VPNObjectID = NSManagedObjectID()
    lazy var vpn: VPN? = {
        if let result = VPNDataManager.sharedManager.VPNByID(self.VPNObjectID) {
            let vpn = result
            return vpn
        } else {
            return Optional.None
        }
    }()
    
    @IBOutlet weak var saveCell: UITableViewCell!
    @IBOutlet weak var deleteCell: UITableViewCell!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        saveCell.textLabel?.textColor = UIColor.lightGrayColor()
        
        if let currentVPN = vpn {
            titleTextField!.text = currentVPN.title
            serverTextField!.text = currentVPN.server
            accountTextField!.text = currentVPN.account
            groupTextField!.text = currentVPN.group
            
            if let passwordRef = VPNKeychainWrapper.passwordForVPNID(currentVPN.ID) {
                passwordTextField!.text = kImpossibleHash
            }
            
            if let secretRef = VPNKeychainWrapper.secretForVPNID(currentVPN.ID) {
                secretTextField!.text = kImpossibleHash
            }
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath)!
        if selectedCell == saveCell && selectedCell.textLabel?.textColor == kSaveButtonEnabledColor {
            if let currentVPN = vpn {
                currentVPN.title = titleTextField!.text
                currentVPN.server = serverTextField!.text
                currentVPN.account = accountTextField!.text
                currentVPN.group = groupTextField!.text
                
                if passwordTextField!.text != kImpossibleHash {
                    VPNKeychainWrapper.setPassword(passwordTextField!.text, forVPNID: currentVPN.ID)
                }
                
                if secretTextField!.text != kImpossibleHash {
                    VPNKeychainWrapper.setSecret(secretTextField!.text, forVPNID: currentVPN.ID)
                }
                
                VPNDataManager.sharedManager.saveContext()
                
                saveCell.userInteractionEnabled = false
                saveCell.textLabel?.textColor = UIColor.lightGrayColor()
            }
        } else if selectedCell == deleteCell {
            if let currentVPN = vpn {
                var alert = UIAlertController(title: "Delete VPN?", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                var deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Default, handler: {
                    (action: UIAlertAction!) -> Void in
                    let deletedVPNID = currentVPN.ID
                    currentVPN.destroy()
                    
                    if let activatedVPNDict = VPNManager.sharedManager().activatedVPNDict as NSDictionary? {
                        if activatedVPNDict.objectForKey("ID") as String == deletedVPNID {
                            let vpns = VPNDataManager.sharedManager.allVPN()
                            if vpns.count >= 1 {
                                VPNManager.sharedManager().activatedVPNDict = vpns.first!.toDictionary()
                            } else {
                                VPNManager.sharedManager().activatedVPNDict = .None
                            }
                        }
                    }
                    VPNKeychainWrapper.destoryKeyForVPNID(currentVPN.ID)
                    
                    self.navigationController!.popViewControllerAnimated(true)
                })
                var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
                alert.addAction(deleteAction)
                alert.addAction(cancelAction)
                presentViewController(alert, animated: true, completion: nil)
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func textDidChange(notification: NSNotification) {
        if self.titleTextField.text.isEmpty
            || self.accountTextField.text.isEmpty
            || self.serverTextField.text.isEmpty {
                self.saveCell.textLabel?.textColor = UIColor.lightGrayColor()
                self.saveCell.userInteractionEnabled = false
        } else {
            self.saveCell.textLabel?.textColor = kSaveButtonEnabledColor
            self.saveCell.userInteractionEnabled = true
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
