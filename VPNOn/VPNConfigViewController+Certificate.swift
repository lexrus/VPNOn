//
//  VPNConfigViewController+Certificate.swift
//  VPNOn
//
//  Created by Lex Tang on 1/23/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit

extension VPNConfigViewController
{
    func updateCertificateOptions() {
        groupCell.hidden = certificateSwitch.on
        secretCell.hidden = certificateSwitch.on
        certificateCell.hidden = !certificateSwitch.on
        
        passwordTextField.returnKeyType = certificateSwitch.on ? .Done : .Next
        
        tableView.reloadData()
    }
    
    @IBAction func didChangeCertificateSwitch(sender: AnyObject) {
        updateCertificateOptions()
    }
    
    // MARK: - TableView data source
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let height = super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        
        if indexPath.section == 1 {
            if indexPath.row == 5 && certificateSwitch.on {
                return 0
            } else if indexPath.row == 6 && certificateSwitch.on {
                return 0
            } else if indexPath.row == 7 && !certificateSwitch.on {
                return 0
            }
        }
        return height
    }
    
    // MARK: - Certificate

    func didTapSaveCertificateWithData(data: NSData?, URLString: String) {
        certificateURL = URLString
        if let d = data {
            temporaryCertificateData = d.copy() as? NSData
        }
        toggleSaveButtonByStatus()
    }
}