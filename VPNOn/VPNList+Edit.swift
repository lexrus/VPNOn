//
//  VPNList+Edit.swift
//  VPNOn
//
//  Created by Lex on 12/20/15.
//  Copyright © 2017 lexrus.com. All rights reserved.
//

import UIKit
import VPNOnKit

extension VPNList {

    @objc
    func didEditVPN(_ notification: Notification) {
        self.vpns = VPNDataManager.shared.allVPN()
        self.tableView.reloadData()
        if let vpn = notification.object as? VPN {
            VPNManager.shared.countryOfHost(vpn.server) { [weak self] country in
                guard let country = country else { return }
                vpn.countryCode = country.isoCode
                do {
                    try vpn.managedObjectContext!.save()
                } catch { }
                self?.tableView.reloadData()
            }
        }
        
        if let nav = self.splitViewController?.viewControllers.last
            as? UINavigationController {
                nav.popViewController(animated: true)
        }

        if let vpns = self.vpns {
            if vpns.count == 0 {
                VPNManager.shared.removeProfile()
            }
        }
    }
    
}
