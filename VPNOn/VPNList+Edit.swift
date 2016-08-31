//
//  VPNList+Edit.swift
//  VPNOn
//
//  Created by Lex on 12/20/15.
//  Copyright © 2016 lexrus.com. All rights reserved.
//

import UIKit
import VPNOnKit

extension VPNList {
    
    func didEditVPN(_ notification: Notification) {
        self.vpns = VPNDataManager.sharedManager.allVPN()
        self.tableView.reloadData()
        if let vpn = notification.object as? VPN {
            VPNManager.sharedManager.countryOfHost(vpn.server) {
                [weak self] country in
                guard let country = country else {
                    return
                }
                vpn.countryCode = country.isoCode
                do {
                    try vpn.managedObjectContext!.save()
                } catch _ {
                }
                self?.tableView.reloadData()
            }
        }
        
        if let nav = self.splitViewController?.viewControllers.last
            as? UINavigationController {
                nav.popViewController(animated: true)
        }

        if let vpns = self.vpns {
            if vpns.count == 0 {
                VPNManager.sharedManager.removeProfile()
            }
        }
    }
    
}
