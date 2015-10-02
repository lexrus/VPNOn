//
//  VPNTableViewController+Domains.swift
//  VPNOn
//
//  Created by Lex Tang on 1/29/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit
import VPNOnKit

extension VPNTableViewController {

    @IBAction func didTapOnDemandSwitch(sender: UISwitch?) {
        VPNManager.sharedManager.onDemand = sender!.on
        updateOnDemandCell()
    }
    
    func updateOnDemandCell() {
        let indexSet = NSIndexSet(index: kVPNOnDemandSection)
        tableView.reloadSections(indexSet, withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    // MARK: - VPNDomainsViewControllerDelegate
    
    func didTapSaveDomainsWithText(text: String) {
        updateOnDemandCell()
    }
}
