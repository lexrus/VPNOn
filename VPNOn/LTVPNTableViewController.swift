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
let kVPNListSectionIndex = 0
let kVPNAddSection = 1
let kAddCellID = "AddCell"
let kVPNCellID = "VPNCell"

class LTVPNTableViewController: UITableViewController, SimplePingDelegate
{
    var vpns = [VPN]()
    var activatedVPNID: NSString? = nil
    @IBOutlet weak var restartPingButton: UIBarButtonItem!
    
    override func loadView() {
        super.loadView()
        
        let backgroundView = LTViewControllerBackground()
        tableView.backgroundView = backgroundView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        vpns = VPNDataManager.sharedManager.allVPN()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("VPNDidCreate:"), name: kLTVPNDidCreate, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("VPNDidUpdate:"), name: kLTVPNDidUpdate, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("VPNDidRemove:"), name: kLTVPNDidRemove, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("VPNDidDuplicate:"), name: kLTVPNDidDuplicate, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("pingDidUpdate:"), name: "kLTPingDidUpdate", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("pingDidComplete:"), name: "kLTPingDidComplete", object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kLTVPNDidCreate, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kLTVPNDidUpdate, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kLTVPNDidRemove, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kLTVPNDidDuplicate, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "kLTPingDidUpdate", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "kLTPingDidComplete", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let activatedVPN = VPNDataManager.sharedManager.activatedVPN {
            activatedVPNID = activatedVPN.ID
        }
        
        tableView.reloadData()
        
        let ping = SimplePing(hostName: "baidu.com")
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case kVPNAddSection:
            return 1
        default:
            return vpns.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == kVPNAddSection {
            return tableView.dequeueReusableCellWithIdentifier(kAddCellID, forIndexPath: indexPath) as UITableViewCell
        } else {
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
        if indexPath.section == kVPNListSectionIndex {
            activatedVPNID = vpns[indexPath.row].ID
            VPNManager.sharedManager().activatedVPNID = activatedVPNID
            tableView.reloadData()
        } else {
            // Add cell selected
            VPNDataManager.sharedManager.selectedVPNID = nil
            let detailNavigationController = splitViewController!.viewControllers.last! as UINavigationController
            detailNavigationController.popToRootViewControllerAnimated(false)
            splitViewController!.viewControllers.last!.performSegueWithIdentifier("config", sender: nil)
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
        if section == kVPNListSectionIndex {
            return "VPN CONFIGURATIONS"
        }
        
        return .None
    }
    
    // MARK: - Notifications
    
    func VPNDidCreate(notification: NSNotification) {
        vpns = VPNDataManager.sharedManager.allVPN()
        tableView.reloadData()
        popDetailViewController()
    }
    
    func VPNDidUpdate(notification: NSNotification) {
        vpns = VPNDataManager.sharedManager.allVPN()
        tableView.reloadData()
        
        // NOTE: Update activated VPN dict for widget
        for vpn in vpns {
            if vpn.ID == activatedVPNID {
                VPNManager.sharedManager().activatedVPNID = vpn.ID
                break
            }
        }
        popDetailViewController()
    }
    
    func VPNDidRemove(notification: NSNotification) {
        vpns = VPNDataManager.sharedManager.allVPN()
        tableView.reloadData()
        popDetailViewController()
    }
    
    func VPNDidDuplicate(notification: NSNotification) {
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

}
