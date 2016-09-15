//
//  VPNTableViewController.swift
//  VPN On
//
//  Created by Lex Tang on 12/4/14.
//  Copyright (c) 2014 lexrus.com. All rights reserved.
//

import UIKit
import CoreData
import NetworkExtension
import VPNOnKit

let kSelectionDidChange = "SelectionDidChange"
private let kVPNIDKey = "VPNID"

let kVPNConnectionSection = 0
let kVPNOnDemandSection = 1
let kVPNListSection = 2
let kVPNAddSection = 3

final class VPNList: UITableViewController, SimplePingDelegate, VPNDomainsDelegate {
    
    @IBOutlet weak var aboutButton: UIBarButtonItem!
    @IBOutlet weak var restartPingButton: UIBarButtonItem!
    
    var vpns: [VPN]?
    var activatedVPNID: String?
    var connectionStatus = NSLocalizedString(
        "Not Connected",
        comment: "Connection Status"
    )
    var connectionOn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundView = LTViewControllerBackground()
        
        // MARK: - Notifications
        let NC = NotificationCenter.default
        
        [
            kVPNDidUpdate,
            kVPNDidCreate,
            kVPNDidRemove,
            kVPNDidDuplicate
            ].forEach {
                NC.addObserver(
                    self,
                    selector: #selector(VPNList.didEditVPN(_:)),
                    name: NSNotification.Name(rawValue: $0),
                    object: nil)
        }
        
        NC.addObserver(
            self,
            selector: #selector(LTPingQueue.pingDidUpdate(_:)),
            name: NSNotification.Name(rawValue: kPingDidUpdate),
            object: nil)
        
        NC.addObserver(
            self,
            selector: #selector(VPNList.pingDidComplete(_:)),
            name: NSNotification.Name(rawValue: kPingDidComplete),
            object: nil)
        
        NC.addObserver(
            self,
            selector: #selector(VPNList.VPNDidChangeStatus(_:)),
            name: NSNotification.Name.NEVPNStatusDidChange,
            object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadVPNs()
    }
    
    func reloadVPNs() {
        vpns = VPNDataManager.sharedManager.allVPN()
        
        if let selectedID = VPNDataManager.sharedManager.selectedVPNID {
            if selectedID.uriRepresentation().lastPathComponent != activatedVPNID {
                activatedVPNID = selectedID.uriRepresentation().absoluteString
                tableView?.reloadData()
            }
        }
    }
    
    // MARK: - VPNDomainsDelegate
    
    func didTapSaveDomainsWithText(_ text: String) {
        updateOnDemandCell()
    }
    
}
