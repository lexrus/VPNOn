//
//  VPNEditor+Manipulation.swift
//  VPNOn
//
//  Created by Lex Tang on 1/20/15.
//  Copyright (c) 2016 lexrus.com. All rights reserved.
//

import UIKit
import VPNOnKit

extension VPNEditor {

    override func tableView(
        tableView: UITableView,
        didSelectRowAtIndexPath indexPath: NSIndexPath
        ) {
            switch tableView.cellForRowAtIndexPath(indexPath) {
            case deleteCell?:
                confirmDelete()
                break
            case duplicateCell?:
                duplicate()
                break
            default:
                ()
            }
            
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    private func confirmDelete() {
        let title = NSLocalizedString(
            "Delete VPN?",
            comment: "VPN Config - Delete alert title"
        )
        let deleteButtonTitle = NSLocalizedString(
            "Delete",
            comment: "VPN Config - Delete alert - Delete button"
        )
        let alert = UIAlertController(
            title: title,
            message: nil,
            preferredStyle: .Alert
        )
        let deleteAction = UIAlertAction(
            title:
            deleteButtonTitle,
            style: .Destructive
            ) { _ in
                guard let vpn = self.vpn else {
                    return
                }
                VPNDataManager.sharedManager.deleteVPN(vpn)
                NSNotificationCenter.defaultCenter()
                    .postNotificationName(kVPNDidRemove, object: nil)
        }
        let cancelButtonTitle = NSLocalizedString(
            "Cancel",
            comment: "VPN Config - Delete alert - Cancel button"
        )
        let cancelAction = UIAlertAction(
            title: cancelButtonTitle,
            style: .Cancel,
            handler: nil
        )
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private func duplicate() {
        guard let vpn = self.vpn else {
            return
        }
        
        if let newVPN = VPNDataManager.sharedManager.duplicate(vpn) {
            NSNotificationCenter.defaultCenter()
                .postNotificationName(kVPNDidDuplicate, object: newVPN)
        }
    }

}
