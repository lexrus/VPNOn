//
//  VPNRow.swift
//  VPNOn
//
//  Created by Lex Tang on 3/30/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import WatchKit
import Foundation

let kDidTurnOnVPN = "kDidTurnOnVPN"
let kDidTurnOffVPN = "kDidTurnOffVPN"
let kVPNIndexKey = "kVPNIndexKey"

class VPNRow: NSObject {
    
    var index = 0
    @IBOutlet weak var flag: WKInterfaceImage!
    @IBOutlet weak var group: WKInterfaceGroup!
    @IBOutlet weak var VPNSwitch: WKInterfaceSwitch!
    
    var latency: Int = -1 {
        didSet {
            self.VPNSwitch.setAttributedTitle(latencyAttributedString)
        }
    }
    
    var latencyAttributedString: NSAttributedString {
        get {
            var latencyString = "--"
            if latency != -1 {
                latencyString = "\(latency)ms"
            }
            
            let s = NSAttributedString(string: latencyString, attributes: [
                NSFontAttributeName: UIFont.systemFontOfSize(15),
                NSForegroundColorAttributeName: colorOfLatency
                ])
            return s
        }
    }
    
    @IBAction func didTapVPNRow(value: Bool) {
        var userInfo = [kVPNIndexKey: index]
        var notificationName = value ? kDidTurnOnVPN : kDidTurnOffVPN
        NSNotificationCenter.defaultCenter().postNotificationName(notificationName,
            object: nil,
            userInfo: userInfo)
    }
    
    var colorOfLatency: UIColor {
        get {
            var latencyColor = UIColor(red: 0.5, green: 0.8, blue: 0.19, alpha: 1)
            
            if latency > 200 {
                latencyColor = UIColor(red: 0.92, green: 0.82, blue: 0, alpha: 0.8)
            } else if latency > 500 {
                latencyColor = UIColor(red: 1, green: 0.11, blue: 0.34, alpha: 0.6)
            } else if latency == -1 {
                latencyColor = UIColor(white: 1.0, alpha: 0.08)
            }
            
            return latencyColor
        }
    }
}
