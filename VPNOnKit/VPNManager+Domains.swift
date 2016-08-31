//
//  VPNManager+Domains.swift
//  VPNOn
//
//  Created by Lex Tang on 1/29/15.
//  Copyright (c) 2016 lexrus.com. All rights reserved.
//

import Foundation

private let kOnDemandKey = "onDemand"
private let kOnDemandDomainsKey = "onDemandDomains"

extension VPNManager {

    public var onDemand: Bool {
        get {
            if let onDemandObject = defaults.object(forKey: kOnDemandKey) as! NSNumber? {
                if onDemandObject.isKind(of: NSNumber.self) {
                    return onDemandObject.boolValue
                }
            }
            return false
        }
        set {
            defaults.set(NSNumber(value: newValue), forKey: kOnDemandKey)
            defaults.synchronize()
        }
    }
    
    public var onDemandDomains: String? {
        get {
            if let domainsObject = defaults.string(forKey: kOnDemandDomainsKey) {
                return domainsObject
            }
            return nil
        }
        set {
            if newValue == nil {
                defaults.removeObject(forKey: kOnDemandDomainsKey)
            } else {
                defaults.set(newValue, forKey: kOnDemandDomainsKey)
            }
            defaults.synchronize()
        }
    }
    
    public var onDemandDomainsArray: [String] {
        return domainsInString(onDemandDomains ?? "")
    }
    
    public func domainsInString(_ string: String) -> [String] {
        let seperator = CharacterSet.whitespacesAndNewlines
        let s = string.trimmingCharacters(in: seperator)
        if s.isEmpty {
            return [String]()
        }
        var domains = s.components(separatedBy: seperator) as [String]
        var wildCardDomains = [String]()
        if domains.count > 1 {
            if domains[domains.count - 1].isEmpty {
                domains.remove(at: domains.count - 1)
            }
        } else {
            let ns = s as NSString
            let range = ns.rangeOfCharacter(from: seperator)
            if range.location == NSNotFound {
                domains = [String]()
                domains.append(s)
            }
        }
        domains.forEach {
            wildCardDomains.append($0)
            if $0.range(of: "*.") == nil {
                wildCardDomains.append("*.\($0)")
            }
        }
        
        return uniq(wildCardDomains)
    }
    
    // See: http://stackoverflow.com/questions/25738817/does-there-exist-within-swifts-api-an-easy-way-to-remove-duplicate-elements-fro
    fileprivate func uniq<S : Sequence, T : Hashable>(_ source: S) -> [T] where S.Iterator.Element == T {
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
