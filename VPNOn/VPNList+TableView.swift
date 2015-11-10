//
//  VPNList+TableView.swift
//  VPNOn
//
//  Created by Lex on 10/30/15.
//  Copyright © 2015 LexTang.com. All rights reserved.
//

import UIKit
import VPNOnKit

extension VPNList {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section
        {
        case kVPNOnDemandSection:
            if VPNManager.sharedManager.onDemand {
                return 2
            }
            return 1
            
        case kVPNListSection:
            return vpns.count
            
        default:
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section
        {
        case kVPNConnectionSection:
            let cell = tableView.dequeueReusableCellWithIdentifier(
                R.reuseIdentifier.connectionCell, forIndexPath: indexPath)!
            cell.titleLabel!.text = connectionStatus
            cell.switchButton.on = connectionOn
            cell.switchButton.enabled = vpns.count != 0
            return cell
            
        case kVPNOnDemandSection:
            if indexPath.row == 0 {
                let switchCell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.onDemandCell)!
                switchCell.switchButton.on = VPNManager.sharedManager.onDemand
                return switchCell
            } else {
                let domainsCell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.domainsCell)!
                var domainsCount = 0
                for domain in VPNManager.sharedManager.onDemandDomainsArray as [String] {
                    if domain.rangeOfString("*.") == nil {
                        domainsCount++
                    }
                }
                let domainsCountFormat = NSLocalizedString("%d Domains", comment: "VPN Table - Domains count")
                domainsCell.detailTextLabel!.text = String(format: domainsCountFormat, domainsCount)
                return domainsCell
            }
            
        case kVPNListSection:
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.vPNCell, forIndexPath: indexPath)!
            let vpn = vpns[indexPath.row]
            cell.textLabel?.attributedText = cellTitleForIndexPath(indexPath)
            cell.detailTextLabel?.text = vpn.server
            cell.IKEv2 = vpn.ikev2
            
            cell.imageView?.image = nil
            
            if let countryCode = vpn.countryCode {
                cell.imageView?.image = UIImage(flagImageWithCountryCode: countryCode.uppercaseString)
            }
            
            cell.current = Bool(activatedVPNID == vpns[indexPath.row].ID)
            
            return cell
            
        default:
            return tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.addCell, forIndexPath: indexPath)!
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section
        {
        case kVPNAddSection:
            VPNDataManager.sharedManager.selectedVPNID = nil
            let detailNavigationController = splitViewController!.viewControllers.last! as! UINavigationController
            detailNavigationController.popToRootViewControllerAnimated(false)
            splitViewController!.viewControllers.last!.performSegueWithIdentifier(R.segue.config, sender: nil)
            break
            
        case kVPNOnDemandSection:
            if indexPath.row == 1 {
                let detailNavigationController = splitViewController!.viewControllers.last! as! UINavigationController
                detailNavigationController.popToRootViewControllerAnimated(false)
                splitViewController!.viewControllers.last!.performSegueWithIdentifier(R.segue.domains, sender: nil)
            }
            break
            
        case kVPNListSection:
            activatedVPNID = vpns[indexPath.row].ID
            VPNManager.sharedManager.activatedVPNID = activatedVPNID
            tableView.reloadData()
            break
            
        default:
            ()
        }
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        if indexPath.section == kVPNListSection {
            let VPNID = vpns[indexPath.row].objectID
            VPNDataManager.sharedManager.selectedVPNID = VPNID
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section
        {
        case kVPNListSection:
            return 60
            
        default:
            return 44
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == kVPNListSection {
            return 20
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == kVPNListSection && vpns.count > 0 {
            return NSLocalizedString("VPN CONFIGURATIONS", comment: "VPN Table - List Section Header")
        }
        
        return .None
    }
    
    // MARK: - Cell title
    
    func cellTitleForIndexPath(indexPath: NSIndexPath) -> NSAttributedString {
        let vpn = vpns[indexPath.row]
        let latency = LTPingQueue.sharedQueue.latencyForHostname(vpn.server)
        
        let titleAttributes = [
            NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        ]
        
        let attributedTitle = NSMutableAttributedString(string: vpn.title, attributes: titleAttributes)
        
        if latency != -1 {
            var latencyColor = UIColor(red:0.39, green:0.68, blue:0.19, alpha:1)
            if latency > 200 {
                latencyColor = UIColor(red:0.73, green:0.54, blue:0.21, alpha:1)
            } else if latency > 500 {
                latencyColor = UIColor(red:0.9 , green:0.11, blue:0.34, alpha:1)
            }
            
            let latencyAttributes = [
                NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote),
                NSForegroundColorAttributeName: latencyColor
            ]
            let attributedLatency = NSMutableAttributedString(string: " \(latency)ms", attributes: latencyAttributes)
            attributedTitle.appendAttributedString(attributedLatency)
        }
        
        return attributedTitle
    }
    
}
