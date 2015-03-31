//
//  VPNManager+Wormhole.swift
//  VPNOn
//
//  Created by Lex Tang on 3/31/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit

let kVPNWormholeGreetings = "Greetings"

extension VPNManager
{
    public func seeYaInAnothaLifeBrotha() {
        self.wormhole.passMessageObject("Hello", identifier: kVPNWormholeGreetings)
    }
}
