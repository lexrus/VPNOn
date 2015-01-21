//
//  LTVPNConfigViewController+Delete.swift
//  VPNOn
//
//  Created by Lex Tang on 1/20/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit
import VPNOnKit

extension LTVPNConfigViewController
{
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath)!
        if selectedCell == deleteCell {
            if let currentVPN = vpn {
                var alert = UIAlertController(title: "Delete VPN?", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                var deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive, handler: {
                    (action: UIAlertAction!) -> Void in
                    let deletedVPNID = currentVPN.ID
                    currentVPN.destroy()
                    
                    if let activatedVPNID = VPNManager.sharedManager().activatedVPNID {
                        if activatedVPNID == deletedVPNID {
                            let vpns = VPNDataManager.sharedManager.allVPN()
                            if vpns.count >= 1 {
                                VPNManager.sharedManager().activatedVPNID = vpns.first!.ID
                            } else {
                                VPNManager.sharedManager().activatedVPNID = .None
                            }
                        }
                    }
                    
                    VPNKeychainWrapper.destoryKeyForVPNID(currentVPN.ID)
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(kLTVPNDidRemove, object: nil)
                })
                var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
                alert.addAction(deleteAction)
                alert.addAction(cancelAction)
                presentViewController(alert, animated: true, completion: nil)
            }
        } else if selectedCell == duplicateCell {
            if let currentVPN = vpn {
                if let newVPN = VPNDataManager.sharedManager.duplicate(currentVPN) {
                    NSNotificationCenter.defaultCenter().postNotificationName(kLTVPNDidDuplicate, object: nil)
                }
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
}
