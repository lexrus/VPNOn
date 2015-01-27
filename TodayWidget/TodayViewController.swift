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

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var VPNSwitch: UISwitch!
    @IBOutlet weak var VPNLabel: UILabel!
    var VPNTitle = ""
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preferredContentSize = CGSizeMake(0, 50)
        
        var tapGesture = UITapGestureRecognizer(target: self, action: Selector("didTapLabel:"))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        VPNLabel.userInteractionEnabled = true
        VPNLabel.addGestureRecognizer(tapGesture)
        
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
        
        if let vpn = VPNDataManager.sharedManager.activatedVPN {
            VPNTitle = vpn.title
            VPNSwitch.enabled = true
            VPNStatusDidChange(nil)
        } else {
            VPNLabel.text = "Please add a VPN."
            VPNSwitch.setOn(false, animated: false)
            VPNSwitch.enabled = false
        }
        
        self.VPNSwitch.setNeedsUpdateConstraints()
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.NewData)
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets
    {
        var edgeInsets = defaultMarginInsets
        edgeInsets.bottom = 0
        edgeInsets.right = 0
        return edgeInsets
    }
    
    @IBAction func toggleVPN(sender: UISwitch) {
        if sender.on {
            if let vpn = VPNDataManager.sharedManager.activatedVPN {
                let passwordRef = VPNKeychainWrapper.passwordForVPNID(vpn.ID)
                let secretRef = VPNKeychainWrapper.secretForVPNID(vpn.ID)
                
                if vpn.ikev2 {
                    VPNManager.sharedManager().connectIKEv2(vpn.title, server: vpn.server, account: vpn.account, group: vpn.group, alwaysOn: vpn.alwaysOn, passwordRef: passwordRef, secretRef: secretRef, certificate: nil)
                } else {
                    VPNManager.sharedManager().connectIPSec(vpn.title, server: vpn.server, account: vpn.account, group: vpn.group, alwaysOn: vpn.alwaysOn, passwordRef: passwordRef, secretRef: secretRef, certificate: nil)
                }
            }
        } else {
            VPNManager.sharedManager().disconnect()
        }
    }
    
    func didTapLabel(label: UILabel) {
        let appURL = NSURL(string: "vpnon://")
        extensionContext!.openURL(appURL!, completionHandler: {
            (complete: Bool) -> Void in
            
        })
    }
    
    func VPNStatusDidChange(notification: NSNotification?) {
        switch VPNManager.sharedManager().status {
        case NEVPNStatus.Connecting:
            VPNLabel.text = "\(VPNTitle) - Connecting..."
            VPNSwitch.enabled = false
            break
        case NEVPNStatus.Connected:
            VPNLabel.text = "\(VPNTitle) - Connected"
            VPNSwitch.setOn(true, animated: false)
            VPNSwitch.enabled = true
            break
        case NEVPNStatus.Disconnecting:
            VPNLabel.text = "\(VPNTitle) - Disconnecting..."
            VPNSwitch.enabled = false
            break
        default:
            VPNSwitch.setOn(false, animated: false)
            VPNSwitch.enabled = true
            VPNLabel.text = "\(VPNTitle) - Not Connected"
        }
    }
}
