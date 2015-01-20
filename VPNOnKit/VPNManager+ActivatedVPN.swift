//
//  VPNManager+ActivatedVPN.swift
//  VPNOn
//
//  Created by Lex Tang on 1/20/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit

let kDeprecatedActivatedVPNDictKey = "activatedVPN"
let kActivatedVPNIDKey = "activatedVPNID"

extension VPNManager
{
    var activatedVPNID: String? {
        get {
            if let deprecatedID = migrateTo0_3AndReturnActivatedVPNID() {
                self.activatedVPNID = deprecatedID
                return deprecatedID
            }
            return self._defaults.objectForKey(kActivatedVPNIDKey) as String?
        }
        set {
            if let newID = newValue {
                _defaults.setObject(newValue, forKey: kActivatedVPNIDKey)
            } else {
                _defaults.removeObjectForKey(kActivatedVPNIDKey)
            }
            _defaults.synchronize()
        }
    }
    
    func migrateTo0_3AndReturnActivatedVPNID() -> String? {
        if let oldDict = self._defaults.objectForKey(kDeprecatedActivatedVPNDictKey) as NSDictionary? {
            if let ID = oldDict.objectForKey("ID") as String? {
                _defaults.removeObjectForKey(kDeprecatedActivatedVPNDictKey)
                return ID
            }
        }
        return .None
    }
}
