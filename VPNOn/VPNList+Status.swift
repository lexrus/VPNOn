//
//  VPNList+Status.swift
//  VPNOn
//
//  Created by Lex on 12/20/15.
//  Copyright © 2017 lexrus.com. All rights reserved.
//

import UIKit
import VPNOnKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


extension VPNList {
    
    func VPNDidChangeStatus(_ notification: Notification) {
        switch VPNManager.sharedManager.status {
        case .connecting:
            self.connectionStatus =
                NSLocalizedString("Connecting...", comment: "")
            self.connectionOn = true
            break
            
        case .connected:
            self.connectionStatus =
                NSLocalizedString("Connected", comment: "")
            self.connectionOn = true
            break
            
        case .disconnecting:
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
                IndexPath(row: 0, section: kVPNConnectionSection)
            self.tableView.reloadRows(
                at: [connectionIndexPath],
                with: .none
            )
        }
    }
    
}
