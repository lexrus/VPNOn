//
//  VPNManager+ActivatedVPN.swift
//  VPNOn
//
//  Created by Lex Tang on 1/20/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import Foundation

let kDeprecatedActivatedVPNDictKey = "activatedVPN"
let kActivatedVPNIDKey = "activatedVPNID"

extension VPNManager
{
    public var activatedVPNID: String? {
        get {
            if let deprecatedID = migrateTo0_3AndReturnActivatedVPNID() {
                self.activatedVPNID = deprecatedID
                return deprecatedID
            }
            return defaults.objectForKey(kActivatedVPNIDKey) as! String?
        }
        set {
            if let _ = newValue {
                defaults.setObject(newValue, forKey: kActivatedVPNIDKey)
            } else {
                defaults.removeObjectForKey(kActivatedVPNIDKey)
            }
            defaults.synchronize()
        }
    }

    public var isActivatedVPNIDDeprecated: Bool {
        if let ID = activatedVPNID, _ = NSURL(string: ID) {
            return true
        }
        return false
    }
    
    private func migrateTo0_3AndReturnActivatedVPNID() -> String? {
        if let oldDict = defaults.objectForKey(kDeprecatedActivatedVPNDictKey) as! NSDictionary? {
            if let ID = oldDict.objectForKey("ID") as! String? {
                defaults.removeObjectForKey(kDeprecatedActivatedVPNDictKey)
                defaults.synchronize()
                return ID
            }
        }
        return .None
    }
}
