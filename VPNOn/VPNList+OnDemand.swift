//
//  VPNList+OnDemand.swift
//  VPNOn
//
//  Created by Lex on 12/20/15.
//  Copyright © 2015 LexTang.com. All rights reserved.
//

import UIKit
import VPNOnKit

extension VPNList {
    
    @IBAction func didTapOnDemandSwitch(sender: UISwitch?) {
        VPNManager.sharedManager.onDemand = sender!.on
        
        // NOTE: Update profile to activate On Demand feature
        if let VPN = VPNDataManager.sharedManager.activatedVPN {
            VPNManager.sharedManager.save(VPN.toAccount()) {}
        }
        
        updateOnDemandCell()
    }
    
    func updateOnDemandCell() {
        let indexSet = NSIndexSet(index: kVPNOnDemandSection)
        tableView.reloadSections(indexSet,
            withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
}