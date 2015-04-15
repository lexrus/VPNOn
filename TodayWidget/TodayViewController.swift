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
let kVPNOnExpanedInToday = "kVPNOnExpanedInToday"
let kVPNOnWidgetNormalHeight: CGFloat = 148

class TodayViewController: UIViewController, NCWidgetProviding, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var leftMarginView: ModeButton!
    @IBOutlet weak var collectionView: UICollectionView!
    var hasSignaled = false
    private var _complitionHandler: (NCUpdateResult -> Void)? = nil
    
    var vpns: [VPN] {
        get {
            return VPNDataManager.sharedManager.allVPN()
        }
    }
    
    var selectedID: String? {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey(kVPNOnSelectedIDInToday) as! String?
        }
        set {
            if let newID = newValue {
                NSUserDefaults.standardUserDefaults().setObject(newID, forKey: kVPNOnSelectedIDInToday)
            } else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey(kVPNOnSelectedIDInToday)
            }
            
        }
    }
    
    var expanded: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(kVPNOnExpanedInToday) as Bool
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: kVPNOnExpanedInToday)
            if newValue {
                self.preferredContentSize = self.collectionView.contentSize
            } else {
                self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, kVPNOnWidgetNormalHeight)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        preferredContentSize = CGSizeMake(0, 82)
        
        let tapGasture = UITapGestureRecognizer(target: self, action: Selector("didTapLeftMargin:"))
        tapGasture.numberOfTapsRequired = 1
        tapGasture.numberOfTouchesRequired = 1
        leftMarginView.userInteractionEnabled = true
        leftMarginView.addGestureRecognizer(tapGasture)
        leftMarginView.backgroundColor = UIColor(white: 1.0, alpha: 0.005)
        leftMarginView.displayMode = VPNManager.sharedManager.displayFlags ? .FlagMode : .SwitchMode
        
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
            name: "kPingDidUpdate",
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
            name: "kPingDidUpdate",
            object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        LTPingQueue.sharedQueue.restartPing()
        collectionView.dataSource = nil
        updateContent()
        collectionView.dataSource = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if collectionView.visibleCells().count > vpns.count {
            leftMarginView.expandIconView.hidden = true
            self.expanded = false
        } else {
            leftMarginView.expandIconView.hidden = false
        }
        
        if self.expanded {
            preferredContentSize = collectionView.contentSize
        } else {
            preferredContentSize = CGSizeMake(collectionView.contentSize.width, min(kVPNOnWidgetNormalHeight, collectionView.contentSize.height))
        }
    }
    
    // Note: A workaround to ensure the widget is interactable.
    // @see: http://stackoverflow.com/questions/25961513/ios-8-today-widget-stops-working-after-a-while
    func singalComplete(updateResult: NCUpdateResult) {
        hasSignaled = true
        if let handler = _complitionHandler {
            handler(updateResult)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if !hasSignaled {
            singalComplete(NCUpdateResult.Failed)
        }
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
        
        _complitionHandler = completionHandler
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
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("addCell", forIndexPath: indexPath) as! AddCell
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("vpnCell", forIndexPath: indexPath) as! VPNCell
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
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath)! as! VPNCell
        
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
        if indexPath.row == vpns.count {
            return true
        }
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! VPNCell
        switch VPNManager.sharedManager.status {
        case .Connected, .Connecting:
            VPNManager.sharedManager.disconnect()
        default: ()
        }
        return true
    }
    
    // MARK: - Left margin
    
    func didTapLeftMargin(gesture: UITapGestureRecognizer) {
        var tappedBottom = Bool(gesture.locationInView(leftMarginView).y > leftMarginView.frame.size.height / 3 * 2)
        
        if !self.expanded && collectionView.contentSize.height == preferredContentSize.height {
            tappedBottom = false
        }
        
        if tappedBottom {
            self.expanded = !self.expanded
        } else {
            LTPingQueue.sharedQueue.restartPing()
            VPNManager.sharedManager.displayFlags = !VPNManager.sharedManager.displayFlags
            collectionView.reloadData()
            
            leftMarginView.displayMode = VPNManager.sharedManager.displayFlags ? .FlagMode : .SwitchMode
        }
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
