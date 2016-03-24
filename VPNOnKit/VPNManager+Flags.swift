//
//  VPNManager+Flags.swift
//  VPNOn
//
//  Created by Lex on 10/2/15.
//  Copyright © 2015 LexTang.com. All rights reserved.
//

import Foundation

private let kVPNOnDisplayFlags = "displayFlags"

extension VPNManager {
    
    public var displayFlags: Bool {
        get {
            if let value = defaults.objectForKey(kVPNOnDisplayFlags) as! Int? {
                return Bool(value)
            }
            return true
        }
        set {
            defaults.setObject(Int(newValue), forKey: kVPNOnDisplayFlags)
            defaults.synchronize()
        }
    }

}
