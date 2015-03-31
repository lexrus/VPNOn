//
//  VPNRowWithSwitch.swift
//  VPNOn
//
//  Created by Lex Tang on 3/31/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import WatchKit
import Foundation

class VPNRowWithSwitch: VPNRow
{
    @IBOutlet weak var VPNSwitch: WKInterfaceSwitch!
    
    @IBAction func didTapVPNRow(value: Bool) {
        var userInfo = [kVPNIndexKey: index]
        var notificationName = value ? kDidTurnOnVPN : kDidTurnOffVPN
        NSNotificationCenter.defaultCenter().postNotificationName(notificationName,
            object: nil,
            userInfo: userInfo)
    }
    
    override var latency: Int {
        didSet {
            if let switchButton = self.VPNSwitch {
                switchButton.setAttributedTitle(latencyAttributedString)
            }
        }
    }
    
    override init() {
        super.init()
        latency = -1
    }
}
