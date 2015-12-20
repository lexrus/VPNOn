//
//  VPNList+Ping.swift
//  VPNOn
//
//  Created by Lex on 12/20/15.
//  Copyright © 2015 LexTang.com. All rights reserved.
//

import UIKit
import VPNOnKit

extension VPNList {
    
    @IBAction func restartPing(sender: AnyObject) {
        self.restartPingButton.enabled = false
        LTPingQueue.sharedQueue.restartPing()
    }
    
    func pingDidUpdate(notification: NSNotification) {
        self.reloadVPNs()
    }
    
    func pingDidComplete(notification: NSNotification) {
        self.restartPingButton?.enabled = true
    }
    
}
