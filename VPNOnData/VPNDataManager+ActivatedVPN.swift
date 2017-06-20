//
//  VPNDataManager+ActivatedVPN.swift
//  VPNOn
//
//  Created by Lex Tang on 1/20/15.
//  Copyright (c) 2017 lexrus.com. All rights reserved.
//

import UIKit
import VPNOnKit

extension VPNDataManager {
    
    var activatedVPN: VPN? {
        if let activatedVPNID = VPNManager.sharedManager.activatedVPNID {
            return VPNByIDString(activatedVPNID)
        }
        return nil
    }
}
