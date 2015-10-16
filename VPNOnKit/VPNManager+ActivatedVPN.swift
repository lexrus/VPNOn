//
//  VPNManager+ActivatedVPN.swift
//  VPNOn
//
//  Created by Lex Tang on 1/20/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import Foundation

private let kActivatedVPNIDKey = "activatedVPNID"

extension VPNManager {

    public var activatedVPNID: String? {
        get {
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
}
