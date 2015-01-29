//
//  VPNManager+Domains.swift
//  VPNOn
//
//  Created by Lex Tang on 1/29/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit

let kOnDemandKey = "onDemand"
let kOnDemandDomainsKey = "onDemandDomains"

extension VPNManager
{
    var onDemand: Bool {
        get {
            if let onDemandObject = _defaults.objectForKey(kOnDemandKey) as NSNumber? {
                if onDemandObject.isKindOfClass(NSNumber.self) {
                    return onDemandObject.boolValue
                }
            }
            return false
        }
        set {
            _defaults.setObject(NSNumber(bool: newValue), forKey: kOnDemandKey)
            _defaults.synchronize()
        }
    }
    
    var onDemandDomains: String? {
        get {
            if let domainsObject = _defaults.stringForKey(kOnDemandDomainsKey) {
                return domainsObject
            }
            return .None
        }
        set {
            if newValue == nil {
                _defaults.removeObjectForKey(kOnDemandDomainsKey)
            } else {
                _defaults.setObject(newValue, forKey: kOnDemandDomainsKey)
            }
            _defaults.synchronize()
        }
    }
    
    var onDemandDomainsArray: [String] {
        get {
            return self.domainsInString(onDemandDomains ?? "")
        }
    }
    
    func domainsInString(string: String) -> [String] {
        let s = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if s.isEmpty {
            return [String]()
        }
        var a = s.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if a.count > 1 {
            if a[a.count - 1].isEmpty {
                a.removeAtIndex(a.count - 1)
            }
        }
        return a
    }
}
