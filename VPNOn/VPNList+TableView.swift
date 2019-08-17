//
//  VPNList+TableView.swift
//  VPNOn
//
//  Created by Lex on 10/30/15.
//  Copyright © 2017 lexrus.com. All rights reserved.
//

import UIKit
import VPNOnKit
import FlagKit

private func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

private func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

extension VPNList {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
        ) -> Int {
            switch section {
            case kVPNOnDemandSection:
                if VPNManager.shared.onDemand {
                    return 2
                }
                return 1
                
            case kVPNListSection:
                return vpns?.count ?? 0
                
            default:
                return 1
            }
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
        ) -> UITableViewCell {
            switch (indexPath as NSIndexPath).section {
            case kVPNConnectionSection:
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "ConnectionCell", for: indexPath) as! VPNSwitchCell
                cell.titleLabel!.text = connectionStatus
                cell.switchButton.isOn = connectionOn
                cell.switchButton.isEnabled = vpns != nil && vpns!.count > 0
                return cell
                
            case kVPNOnDemandSection:
                if (indexPath as NSIndexPath).row == 0 {
                    let switchCell = tableView
                        .dequeueReusableCell(withIdentifier: "OnDemandCell") as! VPNSwitchCell
                    switchCell.switchButton.isOn =
                        VPNManager.shared.onDemand
                    return switchCell
                } else {
                    let domainsCell = tableView
                        .dequeueReusableCell(withIdentifier: "DomainsCell")!
                    let domainsCount = VPNManager.shared
                        .onDemandDomainsArray
                        .filter { !$0.contains("*.") }
                        .count
                    let domainsCountFormat = NSLocalizedString(
                        "%d Domains",
                        comment: "VPN Table - Domains count"
                    )
                    domainsCell.detailTextLabel?.text =
                        String(format: domainsCountFormat, domainsCount)
                    return domainsCell
                }
                
            case kVPNListSection:
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "VPNCell",
                    for: indexPath
                    ) as! VPNTableViewCell
                guard let vpn = vpns?[(indexPath as NSIndexPath).row] else {
                    return cell
                }
                
                cell.textLabel?.attributedText =
                    cellTitleForIndexPath(indexPath)
                cell.detailTextLabel?.text = vpn.server
                cell.IKEv2 = vpn.ikev2
                
                cell.imageView?.image = nil
                
                if let countryCode = vpn.countryCode?.uppercased(), let flag = Flag(countryCode: countryCode) {
                    let flagStyle = FlagStyle.roundedRect
                    cell.imageView?.image = flag.image(style: flagStyle).resize(newSize: CGSize(width: 31, height: 22))
                    cell.imageView?.contentMode = .scaleAspectFit
                }
                
                cell.current = Bool(activatedVPNID == vpn.ID)
                
                return cell
                
            default:
                let addCell = tableView.dequeueReusableCell(
                    withIdentifier: "AddCell",
                    for: indexPath
                )
                if addCell.isRightToLeft {
                    addCell.textLabel?.textAlignment = .right
                }
                return addCell
            }
    }
    
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
        ) {
            switch (indexPath as NSIndexPath).section {
            case kVPNAddSection:
                VPNDataManager.shared.selectedVPNID = nil
                
            case kVPNListSection:
                activatedVPNID = vpns?[(indexPath as NSIndexPath).row].ID
                VPNManager.shared.activatedVPNID = activatedVPNID
                tableView.reloadData()
                
            default:
                ()
            }
    }
    
    override func tableView(
        _ tableView: UITableView,
        accessoryButtonTappedForRowWith indexPath: IndexPath
        ) {
            if (indexPath as NSIndexPath).section == kVPNListSection {
                let VPNID = vpns?[(indexPath as NSIndexPath).row].objectID
                VPNDataManager.shared.selectedVPNID = VPNID
            }
    }
    
    override func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
        ) -> CGFloat {
            switch (indexPath as NSIndexPath).section {
            case kVPNListSection:
                return 60
                
            default:
                return 44
            }
    }
    
    override func tableView(
        _ tableView: UITableView,
        heightForFooterInSection section: Int
        ) -> CGFloat {
            if section == kVPNListSection {
                return 20
            }
            return 0
    }
    
    override func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
        ) -> String? {
            if section == kVPNListSection && vpns?.count > 0 {
                return NSLocalizedString(
                    "VPN CONFIGURATIONS",
                    comment: "VPN Table - List Section Header"
                )
            }
            
            return .none
    }
    
    // MARK: - Cell title
    
    func cellTitleForIndexPath(_ indexPath: IndexPath) -> NSAttributedString {
        guard let vpn = vpns?[(indexPath as NSIndexPath).row] else {
            return NSAttributedString(string: "")
        }
        
        let latency = LTPingQueue.sharedQueue.latencyForHostname(vpn.server)
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        ]
        
        let attributedTitle = NSMutableAttributedString(
            string: vpn.title,
            attributes: titleAttributes
        )
        
        if latency != -1 {
            var latencyColor = UIColor(red:0.39, green:0.68, blue:0.19, alpha:1)
            if latency > 300 {
                latencyColor = UIColor(red:0.73, green:0.54, blue:0.21, alpha:1)
            } else if latency > 600 {
                latencyColor = UIColor(red:0.9 , green:0.11, blue:0.34, alpha:1)
            }
            
            let latencyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.footnote),
                .foregroundColor: latencyColor
            ]
            let attributedLatency = NSMutableAttributedString(
                string: " \(latency)ms",
                attributes: latencyAttributes
            )
            attributedTitle.append(attributedLatency)
        }
        
        return attributedTitle
    }
    
}
