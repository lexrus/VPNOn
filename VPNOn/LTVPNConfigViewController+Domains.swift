//
//  LTVPNConfigViewController+Domains.swift
//  VPNOn
//
//  Created by Lex Tang on 1/28/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit

extension LTVPNConfigViewController
{
    @IBAction func didTapOnDemandSwitch(sender: UISwitch?) {

    }
    
    func didTapSaveDomainsWithText(text: String) {
        temporaryDomains = text
    }
    
    func updateDomainsCell() {
        if temporaryDomains != nil {
            let count = VPN.domainsInString(temporaryDomains!).count
            domainsCell.detailTextLabel!.text = "\(count) domains"
        } else if let currentVPN = vpn {
            temporaryDomains = currentVPN.domains
            domainsCell.detailTextLabel!.text = "\(currentVPN.domainsArray().count) domains"
        }
    }
}
