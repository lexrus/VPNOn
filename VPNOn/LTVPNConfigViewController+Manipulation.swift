//
//  LTVPNConfigViewController+Manipulation.swift
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
                let title = NSLocalizedString("Delete VPN?", comment: "VPN Config - Delete alert title")
                let deleteButtonTitle = NSLocalizedString("Delete", comment: "VPN Config - Delete alert - Delete button")
                var alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                var deleteAction = UIAlertAction(title: deleteButtonTitle, style: UIAlertActionStyle.Destructive, handler: {
                    (action: UIAlertAction!) -> Void in
                    let deletedVPNID = currentVPN.ID
                    
                    VPNDataManager.sharedManager.deleteVPN(currentVPN)
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(kLTVPNDidRemove, object: nil)
                })
                let cancelButtonTitle = NSLocalizedString("Cancel", comment: "VPN Config - Delete alert - Cancel button")
                var cancelAction = UIAlertAction(title: cancelButtonTitle, style: UIAlertActionStyle.Cancel, handler: nil)
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
