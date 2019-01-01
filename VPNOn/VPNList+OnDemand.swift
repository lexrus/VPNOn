//
//  VPNList+OnDemand.swift
//  VPNOn
//
//  Created by Lex on 12/20/15.
//  Copyright © 2017 lexrus.com. All rights reserved.
//

import UIKit
import VPNOnKit

extension VPNList {
    
    @IBAction func didTapOnDemandSwitch(_ sender: UISwitch?) {
        VPNManager.shared.onDemand = sender!.isOn
        
        // NOTE: Update profile to activate On Demand feature
        if let VPN = VPNDataManager.shared.activatedVPN {
            VPNManager.shared.save(VPN.toAccount()) {}
        }
        
        updateOnDemandCell()
    }
    
    func updateOnDemandCell() {
        let indexSet = IndexSet(integer: kVPNOnDemandSection)
        tableView.reloadSections(indexSet,
            with: UITableView.RowAnimation.automatic)
    }
    
}
