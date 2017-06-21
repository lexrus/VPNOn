//
//  VPNManager+ActivatedVPN.swift
//  VPNOn
//
//  Created by Lex Tang on 1/20/15.
//  Copyright (c) 2017 lexrus.com. All rights reserved.
//

import Foundation

private let kActivatedVPNIDKey = "activatedVPNID"

extension VPNManager {

    public var activatedVPNID: String? {
        get {
            return defaults.object(forKey: kActivatedVPNIDKey) as! String?
        }
        set {
            if let newValue = newValue {
                defaults.set(newValue, forKey: kActivatedVPNIDKey)
            } else {
                defaults.removeObject(forKey: kActivatedVPNIDKey)
            }
            defaults.synchronize()
        }
    }
}
