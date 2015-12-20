//
//  VPN+Account.swift
//  VPNOn
//
//  Created by Lex on 12/20/15.
//  Copyright © 2015 LexTang.com. All rights reserved.
//

import Foundation
import VPNOnKit

extension VPN {
    
    func toAccount() -> VPNAccount {
        var a = VPNAccount()
        a.ID = self.ID
        a.title = self.title
        a.server = self.server
        a.account = self.account
        a.group = self.group
        a.alwaysOn = self.alwaysOn
        a.type = self.ikev2 ? .IKEv2 : .IPSec
        return a
    }
    
}