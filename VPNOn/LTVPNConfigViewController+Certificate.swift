//
//  LTVPNConfigViewController+Certificate.swift
//  VPNOn
//
//  Created by Lex Tang on 1/23/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit

extension LTVPNConfigViewController
{
    func toggleCertificateOptions() {
        groupCell.hidden = certificateSwitch.on
        secretCell.hidden = certificateSwitch.on
        certficateCell.hidden = !certificateSwitch.on
        
        passwordTextField.returnKeyType = certificateSwitch.on ? .Done : .Next
        
        tableView.reloadData()
    }
    
    @IBAction func didChangeCertificateSwitch(sender: AnyObject) {
        toggleCertificateOptions()
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
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let targetVC = segue.destinationViewController as? UIViewController {
//            println("\(targetVC)")
        }
    }
}