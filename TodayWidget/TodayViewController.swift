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

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var VPNSwitch: UISwitch!
    @IBOutlet weak var VPNLabel: UILabel!
    @IBOutlet weak var VPNStatusLabel: UILabel!
    @IBOutlet weak var tagLabel: UIView!
    
    @IBOutlet weak var contentArea: UIView!
    @IBOutlet weak var switchArea: UIView!
    
    var typeTag: VPNTypeTag {
        get {
            if tagLabel.subviews.first == nil {
                let effect = UIVibrancyEffect()
                let tagEffectView = UIVisualEffectView(effect: UIVibrancyEffect.notificationCenterVibrancyEffect())
                tagEffectView.frame = tagLabel.bounds
                let tagView = VPNTypeTag(frame: tagEffectView.bounds)
                tagLabel.addSubview(tagEffectView)
                tagEffectView.contentView.addSubview(tagView)
            }
            return tagLabel.subviews.first!.contentView.subviews.first! as VPNTypeTag
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preferredContentSize = CGSizeMake(0, 60)
        
        var labelTapGesture = UITapGestureRecognizer(target: self, action: Selector("didTapLabel:"))
        labelTapGesture.numberOfTapsRequired = 1
        labelTapGesture.numberOfTouchesRequired = 1
        contentArea.userInteractionEnabled = true
        contentArea.addGestureRecognizer(labelTapGesture)
        
        var switchTapGesture = UITapGestureRecognizer(target: self, action: Selector("didTapSwitch:"))
        switchTapGesture.numberOfTapsRequired = 1
        switchTapGesture.numberOfTouchesRequired = 1
        switchArea.userInteractionEnabled = true
        switchArea.addGestureRecognizer(switchTapGesture)
        
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
    }
    
    func updateContent() {
        // Note: In order to get the latest data.
        // @see: http://stackoverflow.com/questions/25924223/core-data-ios-8-today-widget-issue
        VPNDataManager.sharedManager.managedObjectContext?.reset()
        
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
        var edgeInsets = defaultMarginInsets
        edgeInsets.bottom = 0
        edgeInsets.right = 0
        return edgeInsets
    }
    
    // MARK: - User actions
    
    func toggleVPN() {
        if VPNSwitch.on {
            if let vpn = VPNDataManager.sharedManager.activatedVPN {
                let passwordRef = VPNKeychainWrapper.passwordForVPNID(vpn.ID)
                let secretRef = VPNKeychainWrapper.secretForVPNID(vpn.ID)
                let certificate = VPNKeychainWrapper.certificateForVPNID(vpn.ID)
                
                if vpn.ikev2 {
                    VPNManager.sharedManager().connectIKEv2(vpn.title,
                        server: vpn.server,
                        account: vpn.account,
                        group: vpn.group,
                        alwaysOn: vpn.alwaysOn,
                        passwordRef: passwordRef,
                        secretRef: secretRef,
                        certificate: certificate)
                } else {
                    VPNManager.sharedManager().connectIPSec(vpn.title,
                        server: vpn.server,
                        account: vpn.account,
                        group: vpn.group,
                        alwaysOn: vpn.alwaysOn,
                        passwordRef: passwordRef,
                        secretRef: secretRef,
                        certificate: certificate)
                }
            }
        } else {
            VPNManager.sharedManager().disconnect()
        }
    }
    
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
    
    // MARK: - Notification
    
    func coreDataDidSave(notification: NSNotification) {
        VPNDataManager.sharedManager.managedObjectContext?.mergeChangesFromContextDidSaveNotification(notification)
        updateContent()
    }
    
    func VPNStatusDidChange(notification: NSNotification?) {
        switch VPNManager.sharedManager().status
        {
        case NEVPNStatus.Connecting:
            VPNStatusLabel.text = NSLocalizedString("Connecting...", comment: "Today Widget - Status")
            VPNStatusLabel.textColor = UIColor.lightGrayColor()
            VPNLabel.textColor = UIColor.lightGrayColor()
            break
            
        case NEVPNStatus.Connected:
            VPNStatusLabel.text = NSLocalizedString("Connected", comment: "Today Widget - Status")
            VPNSwitch.setOn(true, animated: false)
            VPNStatusLabel.textColor = UIColor.whiteColor()
            VPNLabel.textColor = UIColor.whiteColor()
            break
            
        case NEVPNStatus.Disconnecting:
            VPNStatusLabel.text = NSLocalizedString("Disconnecting...", comment: "Today Widget - Status")
            VPNStatusLabel.textColor = UIColor.whiteColor()
            VPNLabel.textColor = UIColor.whiteColor()
            break
            
        default:
            VPNSwitch.setOn(false, animated: false)
            VPNStatusLabel.textColor = UIColor.lightGrayColor()
            VPNLabel.textColor = UIColor.lightGrayColor()
            VPNStatusLabel.text = NSLocalizedString("Not Connected", comment: "Today Widget - Status")
        }
    }
}
