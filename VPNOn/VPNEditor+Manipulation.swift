//
//  VPNEditor+Manipulation.swift
//  VPNOn
//
//  Created by Lex Tang on 1/20/15.
//  Copyright (c) 2017 lexrus.com. All rights reserved.
//

import UIKit
import VPNOnKit

extension VPNEditor {

    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
        ) {
            switch tableView.cellForRow(at: indexPath) {
            case deleteCell?:
                confirmDelete()
                break
            case duplicateCell?:
                duplicate()
                break
            default:
                ()
            }
            
            tableView.deselectRow(at: indexPath, animated: false)
    }
    
    fileprivate func confirmDelete() {
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
            preferredStyle: .alert
        )
        let deleteAction = UIAlertAction(
            title:
            deleteButtonTitle,
            style: .destructive
            ) { _ in
                guard let vpn = self.vpn else {
                    return
                }
                VPNDataManager.shared.deleteVPN(vpn)
                NotificationCenter.default
                    .post(name: Notification.Name(rawValue: kVPNDidRemove), object: nil)
        }
        let cancelButtonTitle = NSLocalizedString(
            "Cancel",
            comment: "VPN Config - Delete alert - Cancel button"
        )
        let cancelAction = UIAlertAction(
            title: cancelButtonTitle,
            style: .cancel,
            handler: nil
        )
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func duplicate() {
        guard let vpn = self.vpn else {
            return
        }
        
        if let newVPN = VPNDataManager.shared.duplicate(vpn) {
            NotificationCenter.default
                .post(name: Notification.Name(rawValue: kVPNDidDuplicate), object: newVPN)
        }
    }

}
