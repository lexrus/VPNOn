//
//  VPNList+Status.swift
//  VPNOn
//
//  Created by Lex on 12/20/15.
//  Copyright © 2015 LexTang.com. All rights reserved.
//

import UIKit
import VPNOnKit

extension VPNList {
    
    func VPNDidChangeStatus(notification: NSNotification) {
        switch VPNManager.sharedManager.status {
        case .Connecting:
            self.connectionStatus =
                NSLocalizedString("Connecting...", comment: "")
            self.connectionOn = true
            break
            
        case .Connected:
            self.connectionStatus =
                NSLocalizedString("Connected", comment: "")
            self.connectionOn = true
            break
            
        case .Disconnecting:
            self.connectionStatus =
                NSLocalizedString("Disconnecting...", comment: "")
            self.connectionOn = false
            break
            
        default:
            self.connectionStatus =
                NSLocalizedString("Not Connected", comment: "")
            self.connectionOn = false
        }
        
        if self.vpns?.count > 0 {
            let connectionIndexPath =
                NSIndexPath(forRow: 0, inSection: kVPNConnectionSection)
            self.tableView.reloadRowsAtIndexPaths(
                [connectionIndexPath],
                withRowAnimation: .None
            )
        }
    }
    
}
