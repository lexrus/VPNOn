//
//  LTVPNTableViewController.swift
//  VPN On
//
//  Created by Lex Tang on 12/4/14.
//  Copyright (c) 2014 LexTang.com. All rights reserved.
//

import UIKit
import CoreData
import NetworkExtension
import VPNOnKit

let kLTVPNIDKey = "VPNID"
let kVPNConnectionSection = 0
let kVPNListSectionIndex = 1
let kVPNAddSection = 2
let kConnectionCellID = "ConnectionCell"
let kAddCellID = "AddCell"
let kVPNCellID = "VPNCell"

class LTVPNTableViewController: UITableViewController, SimplePingDelegate
{
    var vpns = [VPN]()
    var activatedVPNID: NSString? = nil
    var connectionStatus = "Not Connected"
    var connectionOn = false
    
    @IBOutlet weak var restartPingButton: UIBarButtonItem!
    
    override func loadView() {
        super.loadView()
        
        let backgroundView = LTViewControllerBackground()
        tableView.backgroundView = backgroundView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("reloadDataAndPopDetail:"), name: kLTVPNDidCreate, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("reloadDataAndPopDetail:"), name: kLTVPNDidUpdate, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("reloadDataAndPopDetail:"), name: kLTVPNDidRemove, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("reloadDataAndPopDetail:"), name: kLTVPNDidDuplicate, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("pingDidUpdate:"), name: "kLTPingDidUpdate", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("pingDidComplete:"), name: "kLTPingDidComplete", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("VPNStatusDidChange:"),
            name: NEVPNStatusDidChangeNotification,
            object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kLTVPNDidCreate, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kLTVPNDidUpdate, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kLTVPNDidRemove, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kLTVPNDidDuplicate, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "kLTPingDidUpdate", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "kLTPingDidComplete", object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(
            self,
            name: NEVPNStatusDidChangeNotification,
            object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        vpns = VPNDataManager.sharedManager.allVPN()
        
        if let activatedVPN = VPNDataManager.sharedManager.activatedVPN {
            activatedVPNID = activatedVPN.ID
        }
        
        tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        vpns = [VPN]()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if vpns.count > 0 {
            return 3
        }
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if vpns.count > 0 {
            switch section {
            case kVPNConnectionSection, kVPNAddSection:
                return 1
            default:
                return vpns.count
            }
        }
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if 0 == vpns.count {
            return tableView.dequeueReusableCellWithIdentifier(kAddCellID, forIndexPath: indexPath) as UITableViewCell
        }
        
        switch indexPath.section {
        case kVPNConnectionSection:
            let cell = tableView.dequeueReusableCellWithIdentifier(kConnectionCellID, forIndexPath: indexPath) as LTVPNConnectionCell
            cell.connectionLabel!.text = connectionStatus
            cell.connectionSwitch.on = connectionOn
            return cell
        case kVPNAddSection:
            return tableView.dequeueReusableCellWithIdentifier(kAddCellID, forIndexPath: indexPath) as UITableViewCell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier(kVPNCellID, forIndexPath: indexPath) as UITableViewCell
            
            cell.textLabel?.attributedText = cellTitleForIndexPath(indexPath)
            cell.detailTextLabel?.text = vpns[indexPath.row].server
            
            if activatedVPNID == vpns[indexPath.row].ID {
                cell.imageView!.image = UIImage(named: "CheckMark")
            } else {
                cell.imageView!.image = UIImage(named: "CheckMarkUnchecked")
            }
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if vpns.count == 0 || indexPath.section == kVPNAddSection {
            // Add cell selected
            VPNDataManager.sharedManager.selectedVPNID = nil
            let detailNavigationController = splitViewController!.viewControllers.last! as UINavigationController
            detailNavigationController.popToRootViewControllerAnimated(false)
            splitViewController!.viewControllers.last!.performSegueWithIdentifier("config", sender: nil)
        } else if indexPath.section == kVPNListSectionIndex {
            activatedVPNID = vpns[indexPath.row].ID
            VPNManager.sharedManager().activatedVPNID = activatedVPNID
            tableView.reloadData()
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
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
            return "VPN CONFIGURATIONS"
        }
        
        return .None
    }
    
    // MARK: - Notifications
    
    func reloadDataAndPopDetail(notifiation: NSNotification) {
        vpns = VPNDataManager.sharedManager.allVPN()
        tableView.reloadData()
        popDetailViewController()
    }
    
    // MARK: - Navigation
    
    func popDetailViewController() {
        let topNavigationController = splitViewController!.viewControllers.last! as UINavigationController
        topNavigationController.popViewControllerAnimated(true)
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        if indexPath.section == kVPNListSectionIndex {
            let VPNID = vpns[indexPath.row].objectID
            VPNDataManager.sharedManager.selectedVPNID = VPNID
            
            let detailNavigationController = splitViewController!.viewControllers.last! as UINavigationController
            detailNavigationController.popToRootViewControllerAnimated(false)
            detailNavigationController.performSegueWithIdentifier("config", sender: self)
        }
    }
    
    // MARK: - Cell title
    
    func cellTitleForIndexPath(indexPath: NSIndexPath) -> NSAttributedString {
        let vpn = vpns[indexPath.row]
        let latency = LTPingQueue.sharedQueue().latencyForHostname(vpn.server)
        
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
        LTPingQueue.sharedQueue().restartPing()
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
                
                if vpn.ikev2 {
                    VPNManager.sharedManager().connectIKEv2(vpn.title, server: vpn.server, account: vpn.account, group: vpn.group, alwaysOn: vpn.alwaysOn, passwordRef: passwordRef, secretRef: secretRef, certificate: "")
                } else {
                    VPNManager.sharedManager().connectIPSec(vpn.title, server: vpn.server, account: vpn.account, group: vpn.group, alwaysOn: vpn.alwaysOn, passwordRef: passwordRef, secretRef: secretRef, certificate: "")
                }
            }
        } else {
            VPNManager.sharedManager().disconnect()
        }
    }
    
    func VPNStatusDidChange(notification: NSNotification?) {
        switch VPNManager.sharedManager().status {
        case NEVPNStatus.Connecting:
            connectionStatus = "Connecting..."
            connectionOn = true
            break
        case NEVPNStatus.Connected:
            connectionStatus = "Connected"
            connectionOn = true
            break
        case NEVPNStatus.Disconnecting:
            connectionStatus = "Disconnecting..."
            connectionOn = false
            break
        default:
            connectionStatus = "Not Connected"
            connectionOn = false
        }
        
        if vpns.count > 0 {
            let connectionIndexPath = NSIndexPath(forRow: 0, inSection: kVPNConnectionSection)
            tableView.reloadRowsAtIndexPaths([connectionIndexPath], withRowAnimation: .None)
        }
    }

}
