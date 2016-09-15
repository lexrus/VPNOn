//
//  VPNList+Ping.swift
//  VPNOn
//
//  Created by Lex on 12/20/15.
//  Copyright © 2016 lexrus.com. All rights reserved.
//

import UIKit
import VPNOnKit

extension VPNList {
    
    @IBAction func restartPing(_ sender: AnyObject) {
        self.restartPingButton.isEnabled = false
        LTPingQueue.sharedQueue.restartPing()
    }
    
    func pingDidUpdate(_ notification: Notification) {
        self.reloadVPNs()
    }
    
    func pingDidComplete(_ notification: Notification) {
        self.restartPingButton?.isEnabled = true
    }
    
}
