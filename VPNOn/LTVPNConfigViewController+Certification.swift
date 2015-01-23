//
//  LTVPNConfigViewController+Certification.swift
//  VPNOn
//
//  Created by Lex Tang on 1/23/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit

extension LTVPNConfigViewController
{
    func toggleCertificationOptions() {
        groupCell.hidden = certificationSwitch.on
        secretCell.hidden = certificationSwitch.on
        certficationCell.hidden = !certificationSwitch.on
        
        passwordTextField.returnKeyType = certificationSwitch.on ? .Done : .Next
        
        tableView.reloadData()
    }
    
    @IBAction func didChangeCertificationSwitch(sender: AnyObject) {
        toggleCertificationOptions()
    }
    
    // MARK: - TableView data source
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let height = super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        
        if indexPath.section == 1 {
            if indexPath.row == 5 && certificationSwitch.on {
                return 0
            } else if indexPath.row == 6 && certificationSwitch.on {
                return 0
            } else if indexPath.row == 7 && !certificationSwitch.on {
                return 0
            }
        }
        return height
    }
}