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
import RxSwift
import RxCocoa

let kSelectionDidChange = "SelectionDidChange"
private let kVPNIDKey = "VPNID"

let kVPNConnectionSection = 0
let kVPNOnDemandSection = 1
let kVPNListSection = 2
let kVPNAddSection = 3

class VPNList
    : UITableViewController, SimplePingDelegate, VPNDomainsDelegate {
    
    @IBOutlet weak var aboutButton: UIBarButtonItem!
    @IBOutlet weak var restartPingButton: UIBarButtonItem!
    
    var vpns: [VPN]?
    var activatedVPNID: String?
    var connectionStatus =
    NSLocalizedString("Not Connected", comment: "Connection Status")
    var connectionOn = false
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundView = LTViewControllerBackground()
        
        // MARK: - Ping button
        restartPingButton.rx_tap.subscribeNext {
            self.restartPingButton.enabled = false
            LTPingQueue.sharedQueue.restartPing()
            }.addDisposableTo(disposeBag)
        
        // MARK: - About
        aboutButton.rx_tap.subscribeNext { _ in
            let about = R.storyboard.main.about!
            if let nav = self.splitViewController?.viewControllers.last
                as? UINavigationController {
                    nav.pushViewController(about, animated: true)
            }
            }.addDisposableTo(disposeBag)
        
        // MARK: - Notifications
        let NC = NSNotificationCenter.defaultCenter()
        
        [kVPNDidUpdate, kVPNDidCreate, kVPNDidRemove, kVPNDidDuplicate]
            .forEach { NC.rx_notification($0)
                .subscribeNext { [weak self] n in
                    self?.vpns = VPNDataManager.sharedManager.allVPN()
                    self?.tableView.reloadData()
                    guard let vpn = n.object as? VPN else { return }
                    
                    VPNManager.sharedManager.geoInfoOfHost(vpn.server) {
                        [weak self] geoInfo in
                        vpn.countryCode = geoInfo.countryCode
                        vpn.isp = geoInfo.isp
                        vpn.latitude = geoInfo.latitude
                        vpn.longitude = geoInfo.longitude
                        do {
                            try vpn.managedObjectContext!.save()
                        } catch _ {
                        }
                        self?.tableView.reloadData()
                    }
                    
                    if let nav = self?.splitViewController?.viewControllers.last
                        as? UINavigationController {
                            nav.popViewControllerAnimated(true)
                    }
                }
                .addDisposableTo(disposeBag)
        }
        
        NC.rx_notification(kSelectionDidChange).subscribeNext{ [weak self] _ in
            self?.reloadVPNs()
            }.addDisposableTo(disposeBag)
        
        NC.rx_notification(kPingDidUpdate).subscribeNext { [weak self] _ in
            self?.tableView?.reloadData()
            }.addDisposableTo(disposeBag)
        
        NC.rx_notification(kPingDidComplete).subscribeNext { [weak self] _ in
            self?.restartPingButton?.enabled = true
            }.addDisposableTo(disposeBag)
        
        NC.rx_notification(NEVPNStatusDidChangeNotification).subscribeNext {
            [weak self] n in
            
            switch VPNManager.sharedManager.status {
            case .Connecting:
                self?.connectionStatus =
                    NSLocalizedString("Connecting...", comment: "")
                self?.connectionOn = true
                break
                
            case .Connected:
                self?.connectionStatus =
                    NSLocalizedString("Connected", comment: "")
                self?.connectionOn = true
                break
                
            case .Disconnecting:
                self?.connectionStatus =
                    NSLocalizedString("Disconnecting...", comment: "")
                self?.connectionOn = false
                break
                
            default:
                self?.connectionStatus =
                    NSLocalizedString("Not Connected", comment: "")
                self?.connectionOn = false
            }
            
            if self?.vpns?.count > 0 {
                let connectionIndexPath =
                    NSIndexPath(forRow: 0, inSection: kVPNConnectionSection)
                self?.tableView.reloadRowsAtIndexPaths([connectionIndexPath],
                    withRowAnimation: .None)
            }
            }.addDisposableTo(disposeBag)
        
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
                tableView?.reloadData()
            }
        }
    }
    
    @IBAction func toggleVPN(sender: UISwitch) {
        if sender.on {
            guard let vpn = VPNDataManager.sharedManager.activatedVPN else {
                return
            }
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
    
    // MARK: - Update On Demand
    
    @IBAction func didTapOnDemandSwitch(sender: UISwitch?) {
        VPNManager.sharedManager.onDemand = sender!.on
        updateOnDemandCell()
    }
    
    func updateOnDemandCell() {
        let indexSet = NSIndexSet(index: kVPNOnDemandSection)
        tableView.reloadSections(indexSet,
            withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    // MARK: - VPNDomainsDelegate
    
    func didTapSaveDomainsWithText(text: String) {
        updateOnDemandCell()
    }
    
}
