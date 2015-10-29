//
//  VPNList+Geo.swift
//  VPNOn
//
//  Created by Lex on 3/3/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit
import VPNOnKit

extension VPNList {
    
    func geoDidUpdate(notification: NSNotification) {
        guard let VPN = notification.object as? VPN else {
            return
        }
        
        VPNManager.sharedManager.geoInfoOfHost(VPN.server) {
            [weak self]
            geoInfo in
            
            VPN.countryCode = geoInfo.countryCode
            VPN.isp = geoInfo.isp
            VPN.latitude = geoInfo.latitude
            VPN.longitude = geoInfo.longitude
            do {
                try VPN.managedObjectContext!.save()
            } catch _ {
            }
            
            self?.tableView.reloadData()
        }
    }

}
