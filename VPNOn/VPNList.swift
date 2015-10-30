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
import FlagKit

private let kGeoDidUpdate = "GeoDidUpdate"
private let kSelectionDidChange = "SelectionDidChange"
private let kVPNIDKey = "VPNID"

let kVPNConnectionSection = 0
let kVPNOnDemandSection = 1
let kVPNListSection = 2
let kVPNAddSection = 3

class VPNList : UITableViewController, SimplePingDelegate, VPNDomainsDelegate {
    
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadDataAndPopDetail:", name: kVPNDidCreate, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadDataAndPopDetail:", name: kVPNDidUpdate, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadDataAndPopDetail:", name: kVPNDidRemove, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadDataAndPopDetail:", name: kVPNDidDuplicate, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "pingDidUpdate:", name: kPingDidUpdate, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "pingDidComplete:", name: kPingDidComplete, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "geoDidUpdate:", name: kGeoDidUpdate, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "selectionDidChange:", name: kSelectionDidChange, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "VPNStatusDidChange:",
            name: NEVPNStatusDidChangeNotification,
            object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kVPNDidCreate, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kVPNDidUpdate, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kVPNDidRemove, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kVPNDidDuplicate, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kPingDidUpdate, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kPingDidComplete, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kGeoDidUpdate, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kSelectionDidChange, object: nil)
        
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
    
    // MARK: - Notifications
    
    func reloadDataAndPopDetail(notification: NSNotification) {
        vpns = VPNDataManager.sharedManager.allVPN()
        tableView.reloadData()
        if let vpn = notification.object as! VPN? {
            NSNotificationCenter.defaultCenter().postNotificationName(kGeoDidUpdate, object: vpn)
        }
        popDetailViewController()
    }
    
    func selectionDidChange(notification: NSNotification) {
        reloadVPNs()
    }
    
    // MARK: - Navigation
    
    func popDetailViewController() {
        let topNavigationController = splitViewController!.viewControllers.last! as! UINavigationController
        topNavigationController.popViewControllerAnimated(true)
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
            guard let vpn = VPNDataManager.sharedManager.activatedVPN else { return }
            let passwordRef = VPNKeychainWrapper.passwordForVPNID(vpn.ID)
            let secretRef = VPNKeychainWrapper.secretForVPNID(vpn.ID)
            
            if vpn.ikev2 {
                VPNManager.sharedManager.connectIKEv2(
                    vpn.title,
                    server: vpn.server,
                    account: vpn.account,
                    group: vpn.group,
                    alwaysOn: vpn.alwaysOn,
                    passwordRef: passwordRef,
                    secretRef: secretRef)
            } else {
                VPNManager.sharedManager.connectIPSec(
                    vpn.title,
                    server: vpn.server,
                    account: vpn.account,
                    group: vpn.group,
                    alwaysOn: vpn.alwaysOn,
                    passwordRef: passwordRef,
                    secretRef: secretRef)
            }
        } else {
            VPNManager.sharedManager.disconnect()
        }
    }
    
    // MARK: - Info
    
    @IBAction func presentAbout(sender: UIBarButtonItem) {
        let about = R.storyboard.main.aboutViewController!
        if let detailNavigationController = splitViewController!.viewControllers.last as? UINavigationController {
            detailNavigationController.pushViewController(about, animated: true)
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
