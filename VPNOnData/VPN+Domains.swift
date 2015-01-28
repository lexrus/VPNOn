//
//  VPN+Domains.swift
//  VPNOn
//
//  Created by Lex Tang on 1/28/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit

extension VPN
{
    func domainsArray() -> [String] {
        return VPN.domainsInString(domains ?? "")
    }
    
    class func domainsInString(string: String) -> [String] {
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
