//
//  LTVPNTableViewController+Geo.swift
//  VPNOn
//
//  Created by Lex on 3/3/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit
import VPNOnKit

extension LTVPNTableViewController
{
    
    func geoDidUpdate(notification: NSNotification) {
        if let vpn = notification.object as! VPN? {
            
            VPNManager.sharedManager.geoInfoOfHost(vpn.server) {
                geoInfo in
                
                vpn.countryCode = geoInfo.countryCode
                vpn.isp = geoInfo.isp
                vpn.latitude = geoInfo.latitude
                vpn.longitude = geoInfo.longitude
                vpn.managedObjectContext!.save(nil)
                
                self.tableView.reloadData()
            }
        }
    }

}
