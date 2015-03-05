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
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(
            self,
            name: NEVPNStatusDidChangeNotification,
            object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        updateContent()
        
        preferredContentSize = collectionView.contentSize
    }
    
    func updateContent() {
        // Note: In order to get the latest data.
        // @see: http://stackoverflow.com/questions/25924223/core-data-ios-8-today-widget-issue
        VPNDataManager.sharedManager.managedObjectContext?.reset()
        
        /*
        if let vpn = VPNDataManager.sharedManager.activatedVPN {
            VPNLabel.text = vpn.title
            typeTag.type = vpn.ikev2 ? .IKEv2 : .IKEv1
            typeTag.hidden = false
            VPNSwitch.enabled = true
            switchArea.userInteractionEnabled = true
            VPNStatusDidChange(nil)
        } else {
            VPNLabel.text = NSLocalizedString("No VPN configured.", comment: "Today Widget - Default text")
            VPNStatusLabel.text = NSLocalizedString("Please add a VPN.", comment: "Today Widget - Add VPN")
            typeTag.hidden = true
            VPNSwitch.setOn(false, animated: false)
            VPNSwitch.enabled = false
            switchArea.userInteractionEnabled = false
        }
*/
        
//        self.VPNSwitch.setNeedsUpdateConstraints()
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
        return vpns.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("vpnCell", forIndexPath: indexPath) as VPNCell
        let vpn = vpns[indexPath.row]
        let selected = Bool(selectedID == vpn.ID)
        cell.configureWithVPN(vpns[indexPath.row], selected: selected)
        if selected {
            cell.status = VPNManager.sharedManager.status
        } else {
            cell.status = .Disconnected
        }
        
        return cell
    }
    
    // MARK: - Collection View Delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        let vpn = vpns[indexPath.row]
        selectedID = vpn.ID
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath)! as VPNCell
        if cell.status != .Connected {
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
        } else {
            VPNManager.sharedManager.disconnect()
        }
    }
    
    /*
    
    func didTapLabel(gesture: UITapGestureRecognizer) {
        let appURL = NSURL(string: "vpnon://")
        extensionContext!.openURL(appURL!, completionHandler: {
            (complete: Bool) -> Void in
            
        })
    }
    
    func didTapSwitch(gesture: UITapGestureRecognizer) {
        VPNSwitch.setOn(!VPNSwitch.on, animated: true)
        toggleVPN()
    }
    
    */
    
    // MARK: - Notification
    
    func coreDataDidSave(notification: NSNotification) {
        VPNDataManager.sharedManager.managedObjectContext?.mergeChangesFromContextDidSaveNotification(notification)
        updateContent()
    }
    
    func VPNStatusDidChange(notification: NSNotification?) {
        collectionView.reloadData()
    }

}
