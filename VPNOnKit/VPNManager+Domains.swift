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
        var domains = s.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) as [String]
        var wildCardDomains = [String]()
        if domains.count > 1 {
            if domains[domains.count - 1].isEmpty {
                domains.removeAtIndex(domains.count - 1)
            }
            for domain in domains {
                wildCardDomains.append(domain)
                if domain.rangeOfString("*.") == nil {
                    wildCardDomains.append("*.\(domain)")
                }
            }
        }
        
        return uniq(wildCardDomains)
    }
    
    // See: http://stackoverflow.com/questions/25738817/does-there-exist-within-swifts-api-an-easy-way-to-remove-duplicate-elements-fro
    private func uniq<S : SequenceType, T : Hashable where S.Generator.Element == T>(source: S) -> [T] {
        var buffer = Array<T>()
        var addedDict = [T: Bool]()
        for elem in source {
            if addedDict[elem] == nil {
                addedDict[elem] = true
                buffer.append(elem)
            }
        }
        return buffer
    }
}
