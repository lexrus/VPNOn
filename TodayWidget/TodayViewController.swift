//
//  TodayViewController.swift
//  TodayWidget
//
//  Created by Lex Tang on 12/10/14.
//  Copyright (c) 2014 LexTang.com. All rights reserved.
//

import UIKit
import NotificationCenter
import NetworkExtension
import VPNOnKit
import CoreData

let kVPNOnSelectedIDInToday = "kVPNOnSelectedIDInToday"

class TodayViewController: UIViewController, NCWidgetProviding, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var leftMarginView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var vpns: [VPN] {
        get {
            return VPNDataManager.sharedManager.allVPN()
        }
    }
    
    var selectedID: String? {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey(kVPNOnSelectedIDInToday) as String?
        }
        set {
            if let newID = newValue {
                NSUserDefaults.standardUserDefaults().setObject(newID, forKey: kVPNOnSelectedIDInToday)
            } else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey(kVPNOnSelectedIDInToday)
            }
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        preferredContentSize = CGSizeMake(0, 80)
        
        let tapGasture = UITapGestureRecognizer(target: self, action: Selector("didTapLeftMargin:"))
        tapGasture.numberOfTapsRequired = 1
        tapGasture.numberOfTouchesRequired = 1
        leftMarginView.userInteractionEnabled = true
        leftMarginView.addGestureRecognizer(tapGasture)
        leftMarginView.backgroundColor = UIColor(white: 1.0, alpha: 0.005)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("coreDataDidSave:"),
            name: NSManagedObjectContextDidSaveNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("VPNStatusDidChange:"),
            name: NEVPNStatusDidChangeNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("pingDidUpdate:"),
            name: "kLTPingDidUpdate",
            object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(
            self,
            name: NSManagedObjectContextDidSaveNotification,
            object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(
            self,
            name: NEVPNStatusDidChangeNotification,
            object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(
            self,
            name: "kLTPingDidUpdate",
            object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        LTPingQueue.sharedQueue.restartPing()
        updateContent()
        
        preferredContentSize = collectionView.contentSize
    }
    
    func updateContent() {
        // Note: In order to get the latest data.
        // @see: http://stackoverflow.com/questions/25924223/core-data-ios-8-today-widget-issue
        VPNDataManager.sharedManager.managedObjectContext?.reset()
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.NewData)
    }
    
    // MARK: - Layout
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets
    {
        return UIEdgeInsetsZero
    }
    
    // MARK: - Collection View Data source
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return vpns.count + 1
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        if indexPath.row == vpns.count {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("addCell", forIndexPath: indexPath) as AddCell
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("vpnCell", forIndexPath: indexPath) as VPNCell
            let vpn = vpns[indexPath.row]
            let selected = Bool(selectedID == vpn.ID)
            cell.configureWithVPN(vpns[indexPath.row], selected: selected)
            if selected {
                cell.status = VPNManager.sharedManager.status
            } else {
                cell.status = .Disconnected
            }
            
            cell.latency = LTPingQueue.sharedQueue.latencyForHostname(vpn.server)
            
            return cell
        }
    }
    
    // MARK: - Collection View Delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        if indexPath.row == vpns.count {
            didTapAdd()
            
            return
        }
        
        let vpn = vpns[indexPath.row]
        
        if VPNManager.sharedManager.status == .Connected {
            if selectedID == vpn.ID {
                // Do not connect it again if tap the same one
                return
            }
        }
        
        selectedID = vpn.ID
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath)! as VPNCell
        
        let passwordRef = VPNKeychainWrapper.passwordForVPNID(vpn.ID)
        let secretRef = VPNKeychainWrapper.secretForVPNID(vpn.ID)
        let certificate = VPNKeychainWrapper.certificateForVPNID(vpn.ID)
        let titleWithSubfix = "Widget - \(vpn.title)"
        
        if vpn.ikev2 {
            VPNManager.sharedManager.connectIKEv2(titleWithSubfix,
                server: vpn.server,
                account: vpn.account,
                group: vpn.group,
                alwaysOn: vpn.alwaysOn,
                passwordRef: passwordRef,
                secretRef: secretRef,
                certificate: certificate)
        } else {
            VPNManager.sharedManager.connectIPSec(titleWithSubfix,
                server: vpn.server,
                account: vpn.account,
                group: vpn.group,
                alwaysOn: vpn.alwaysOn,
                passwordRef: passwordRef,
                secretRef: secretRef,
                certificate: certificate)
        }
    }
    
    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as VPNCell
        switch VPNManager.sharedManager.status {
        case .Connected, .Connecting:
            VPNManager.sharedManager.disconnect()
        default: ()
        }
        return true
    }
    
    // MARK: - Left margin
    
    func didTapLeftMargin(gesture: UITapGestureRecognizer) {
        LTPingQueue.sharedQueue.restartPing()
        VPNManager.sharedManager.displayFlags = !VPNManager.sharedManager.displayFlags
        collectionView.reloadData()
    }
    
    // MARK: - Open App
    
    func didTapAdd() {
        let appURL = NSURL(string: "vpnon://")
        extensionContext!.openURL(appURL!, completionHandler: {
            (complete: Bool) -> Void in
            
        })
    }
    
    // MARK: - Notification
    
    func pingDidUpdate(notification: NSNotification) {
        collectionView.reloadData()
    }
    
    func coreDataDidSave(notification: NSNotification) {
        VPNDataManager.sharedManager.managedObjectContext?.mergeChangesFromContextDidSaveNotification(notification)
        updateContent()
    }
    
    func VPNStatusDidChange(notification: NSNotification?) {
        collectionView.reloadData()
        if VPNManager.sharedManager.status == .Disconnected {
            LTPingQueue.sharedQueue.restartPing()
        }
    }

}
