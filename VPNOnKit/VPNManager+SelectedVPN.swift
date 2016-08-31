//
//  VPNManager+SelectedVPN.swift
//  VPNOn
//
//  Created by Lex on 10/2/15.
//  Copyright © 2016 lexrus.com. All rights reserved.
//

import Foundation

private let kSelectedIDInToday = "kVPNOnSelectedIDInToday"

extension VPNManager {
    
    public var selectedVPNID: String? {
        get {
            return defaults.object(forKey: kSelectedIDInToday) as! String?
        }
        set {
            if let newID = newValue {
                defaults.set(newID, forKey: kSelectedIDInToday)
            } else {
                defaults.removeObject(forKey: kSelectedIDInToday)
            }
            
        }
    }

}
