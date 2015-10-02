//
//  VPNManager+SelectedVPN.swift
//  VPNOn
//
//  Created by Lex on 10/2/15.
//  Copyright © 2015 LexTang.com. All rights reserved.
//

import Foundation

private let kSelectedIDInToday = "kVPNOnSelectedIDInToday"

extension VPNManager {
    
    public var selectedVPNID: String? {
        get {
            return defaults.objectForKey(kSelectedIDInToday) as! String?
        }
        set {
            if let newID = newValue {
                defaults.setObject(newID, forKey: kSelectedIDInToday)
            } else {
                defaults.removeObjectForKey(kSelectedIDInToday)
            }
            
        }
    }
}