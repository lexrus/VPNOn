//
//  VPNTableViewController.swift
//  VPN On
//
//  Created by Lex Tang on 12/4/14.
//  Copyright (c) 2014 LexTang.com. All rights reserved.
//

import UIKit
import CoreData
import NetworkExtension
import VPNOnKit

let kVPNIDKey = "VPNID"
let kVPNConnectionSection = 0
let kVPNOnDemandSection = 1
let kVPNListSectionIndex = 2
let kVPNAddSection = 3
let kConnectionCellID = "ConnectionCell"
let kAddCellID = "AddCell"
let kVPNCellID = "VPNCell"
let kOnDemandCellID = "OnDemandCell"
let kDomainsCellID = "DomainsCell"

class VPNTableViewController: UITableViewController, SimplePingDelegate, VPNDomainsViewControllerDelegate
{
    var vpns = [VPN]()
    var activatedVPNID: String? = nil
    var connectionStatus = NSLocalizedString("Not Connected", comment: "VPN Table - Connection Status")
    var connectionOn = false
    
    @IBOutlet weak var restartPingButton: UIBarButtonItem!
    
    override func loadView() {
        super.loadView()
        
        let backgroundView = LTViewControllerBackground()
        tableView.backgroundView = backgroundView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("reloadDataAndPopDetail:"), name: kVPNDidCreate, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("reloadDataAndPopDetail:"), name: kVPNDidUpdate, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("reloadDataAndPopDetail:"), name: kVPNDidRemove, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("reloadDataAndPopDetail:"), name: kVPNDidDuplicate, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("pingDidUpdate:"), name: "kPingDidUpdate", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("pingDidComplete:"), name: "kPingDidComplete", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("geoDidUpdate:"), name: "kGeoDidUpdate", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("selectionDidChange:"), name: "kSelectionDidChange", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("VPNStatusDidChange:"),
            name: NEVPNStatusDidChangeNotification,
            object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kVPNDidCreate, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kVPNDidUpdate, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kVPNDidRemove, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kVPNDidDuplicate, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "kPingDidUpdate", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "kPingDidComplete", object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "kGeoDidUpdate", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "kSelectionDidChange", object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(
            self,
            name: NEVPNStatusDidChangeNotification,
            object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadVPNs()
    }
    
    func reloadVPNs() {
        vpns = VPNDataManager.sharedManager.allVPN()
        
        if let selectedID = VPNDataManager.sharedManager.selectedVPNID {
            if selectedID != activatedVPNID {
                activatedVPNID = selectedID.URIRepresentation().absoluteString
                tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

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
            
        case kVPNListSectionIndex:
            return vpns.count
            
        default:
            return 1
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section
        {
        case kVPNConnectionSection:
            let cell = tableView.dequeueReusableCellWithIdentifier(kConnectionCellID, forIndexPath: indexPath) as! VPNSwitchCell
            cell.titleLabel!.text = connectionStatus
            cell.switchButton.on = connectionOn
            cell.switchButton.enabled = vpns.count != 0
            return cell
            
        case kVPNOnDemandSection:
            if indexPath.row == 0 {
                let switchCell = tableView.dequeueReusableCellWithIdentifier(kOnDemandCellID) as! VPNSwitchCell
                switchCell.switchButton.on = VPNManager.sharedManager.onDemand
                return switchCell
            } else {
                let domainsCell = tableView.dequeueReusableCellWithIdentifier(kDomainsCellID) as! VPNTableViewCell
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
            
        case kVPNListSectionIndex:
            let cell = tableView.dequeueReusableCellWithIdentifier(kVPNCellID, forIndexPath: indexPath) as! VPNTableViewCell
            let vpn = vpns[indexPath.row]
            cell.textLabel?.attributedText = cellTitleForIndexPath(indexPath)
            cell.detailTextLabel?.text = vpn.server
            cell.IKEv2 = vpn.ikev2
            
            cell.imageView!.image = nil
            
            if let cc = vpn.countryCode {
                if let image = UIImage(named: cc) {
                    cell.imageView!.image = image
                }
            }
            
            cell.current = Bool(activatedVPNID == vpns[indexPath.row].ID)
            
            return cell
            
        default:
            return tableView.dequeueReusableCellWithIdentifier(kAddCellID, forIndexPath: indexPath) as! UITableViewCell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section
        {
        case kVPNAddSection:
            VPNDataManager.sharedManager.selectedVPNID = nil
            let detailNavigationController = splitViewController!.viewControllers.last! as! UINavigationController
            detailNavigationController.popToRootViewControllerAnimated(false)
            splitViewController!.viewControllers.last!.performSegueWithIdentifier("config", sender: nil)
            break
            
        case kVPNOnDemandSection:
            if indexPath.row == 1 {
                let detailNavigationController = splitViewController!.viewControllers.last! as! UINavigationController
                detailNavigationController.popToRootViewControllerAnimated(false)
                splitViewController!.viewControllers.last!.performSegueWithIdentifier("domains", sender: nil)
            }
            break
            
        case kVPNListSectionIndex:
            activatedVPNID = vpns[indexPath.row].ID
            VPNManager.sharedManager.activatedVPNID = activatedVPNID
            tableView.reloadData()
            break
            
        default:
            ()
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section
        {
        case kVPNListSectionIndex:
            return 60
            
        default:
            return 44
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == kVPNListSectionIndex {
            return 20
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == kVPNListSectionIndex && vpns.count > 0 {
            return NSLocalizedString("VPN CONFIGURATIONS", comment: "VPN Table - List Section Header")
        }
        
        return .None
    }
    
    // MARK: - Notifications
    
    func reloadDataAndPopDetail(notification: NSNotification) {
        vpns = VPNDataManager.sharedManager.allVPN()
        tableView.reloadData()
        if let vpn = notification.object as! VPN? {
            NSNotificationCenter.defaultCenter().postNotificationName("kGeoDidUpdate", object: vpn)
        }
        popDetailViewController()
        
        VPNManager.sharedManager.seeYaInAnothaLifeBrotha()
    }
    
    func selectionDidChange(notification: NSNotification) {
        reloadVPNs()
    }
    
    // MARK: - Navigation
    
    func popDetailViewController() {
        let topNavigationController = splitViewController!.viewControllers.last! as! UINavigationController
        topNavigationController.popViewControllerAnimated(true)
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        if indexPath.section == kVPNListSectionIndex {
            let VPNID = vpns[indexPath.row].objectID
            VPNDataManager.sharedManager.selectedVPNID = VPNID
            
            let detailNavigationController = splitViewController!.viewControllers.last! as! UINavigationController
            detailNavigationController.popToRootViewControllerAnimated(false)
            detailNavigationController.performSegueWithIdentifier("config", sender: self)
        }
    }
    
    // MARK: - Cell title
    
    func cellTitleForIndexPath(indexPath: NSIndexPath) -> NSAttributedString {
        let vpn = vpns[indexPath.row]
        let latency = LTPingQueue.sharedQueue.latencyForHostname(vpn.server)
        
        let titleAttributes = [
            NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        ]

        var attributedTitle = NSMutableAttributedString(string: vpn.title, attributes: titleAttributes)
        
        
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
            var attributedLatency = NSMutableAttributedString(string: " \(latency)ms", attributes: latencyAttributes)
            attributedTitle.appendAttributedString(attributedLatency)
        }
        
        return attributedTitle
    }
    
    // MARK: - Ping
    
    @IBAction func pingServers() {
        restartPingButton.enabled = false
        LTPingQueue.sharedQueue.restartPing()
    }
    
    func pingDidUpdate(notification: NSNotification) {
        tableView.reloadData()
    }
    
    func pingDidComplete(notification: NSNotification) {
        restartPingButton.enabled = true
    }
    
    // MARK: - Connection
    
    @IBAction func toggleVPN(sender: UISwitch) {
        if sender.on {
            if let vpn = VPNDataManager.sharedManager.activatedVPN {
                let passwordRef = VPNKeychainWrapper.passwordForVPNID(vpn.ID)
                let secretRef = VPNKeychainWrapper.secretForVPNID(vpn.ID)
                let certificate = VPNKeychainWrapper.certificateForVPNID(vpn.ID)
                
                if vpn.ikev2 {
                    VPNManager.sharedManager.connectIKEv2(vpn.title, server: vpn.server, account: vpn.account, group: vpn.group, alwaysOn: vpn.alwaysOn, passwordRef: passwordRef, secretRef: secretRef, certificate: certificate)
                } else {
                    VPNManager.sharedManager.connectIPSec(vpn.title, server: vpn.server, account: vpn.account, group: vpn.group, alwaysOn: vpn.alwaysOn, passwordRef: passwordRef, secretRef: secretRef, certificate: certificate)
                }
            }
        } else {
            VPNManager.sharedManager.disconnect()
        }
    }
    
    func VPNStatusDidChange(notification: NSNotification?) {
        switch VPNManager.sharedManager.status
        {
        case NEVPNStatus.Connecting:
            connectionStatus = NSLocalizedString("Connecting...", comment: "VPN Table - Connection Status")
            connectionOn = true
            break
            
        case NEVPNStatus.Connected:
            connectionStatus = NSLocalizedString("Connected", comment: "VPN Table - Connection Status")
            connectionOn = true
            break
            
        case NEVPNStatus.Disconnecting:
            connectionStatus = NSLocalizedString("Disconnecting...", comment: "VPN Table - Connection Status")
            connectionOn = false
            break
            
        default:
            connectionStatus = NSLocalizedString("Not Connected", comment: "VPN Table - Connection Status")
            connectionOn = false
        }
        
        if vpns.count > 0 {
            let connectionIndexPath = NSIndexPath(forRow: 0, inSection: kVPNConnectionSection)
            tableView.reloadRowsAtIndexPaths([connectionIndexPath], withRowAnimation: .None)
        }
    }

}
