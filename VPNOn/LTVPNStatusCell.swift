//
//  LTVPNStatusCell.swift
//  VPNOn
//
//  Created by Lex Tang on 12/12/14.
//  Copyright (c) 2014 LexTang.com. All rights reserved.
//

import UIKit
import NetworkExtension

let kLTVPNStatusCellID = "StatusCell"

class LTVPNStatusCell : UITableViewCell {
    
    @IBOutlet weak var statusLabel: LTMorphingLabel!
    @IBOutlet weak var VPNSwitch: UISwitch!
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func configureCellWithStatus(status: NEVPNStatus) {
        switch status {
        case NEVPNStatus.Connecting:
            statusLabel.text = "Connecting..."
            VPNSwitch.enabled = false
            break
        case NEVPNStatus.Connected:
            statusLabel.text = "Connected"
            VPNSwitch.setOn(true, animated: true)
            VPNSwitch.enabled = true
            break
        case NEVPNStatus.Disconnecting:
            statusLabel.text = "Disconnecting..."
            VPNSwitch.enabled = false
            break
        default:
            VPNSwitch.setOn(false, animated: true)
            VPNSwitch.enabled = true
            statusLabel.text = "Not Connected"
        }
    }
}
