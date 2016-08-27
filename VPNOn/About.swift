//
//  About.swift
//  VPNOn
//
//  Created by Lex Tang on 1/6/15.
//  Copyright (c) 2016 lexrus.com. All rights reserved.
//

import UIKit
import MessageUI

private let kReviewCellIndex = 1
private let kFeedbackCellIndex = 2

class About : UITableViewController, MFMailComposeViewControllerDelegate {
    
    override func loadView() {
        super.loadView()
        tableView.backgroundView = LTViewControllerBackground()
    }
    
    override func tableView(
        tableView: UITableView,
        numberOfRowsInSection section: Int
        ) -> Int {
            if MFMailComposeViewController.canSendMail() {
                return 3
            } else {
                return 2
            }
    }
    
    override func tableView(
        tableView: UITableView,
        titleForFooterInSection section: Int
        ) -> String? {
        return appVersion()
    }
    
    override func tableView(
        tableView: UITableView,
        didSelectRowAtIndexPath indexPath: NSIndexPath
        ) {
        switch indexPath.row {
        case kReviewCellIndex:
            presentAppStore()
            break
        case kFeedbackCellIndex:
            presentFeedback()
            break
        default:
            ()
        }
    }
    
    private func appVersion() -> String {
        if let version = NSBundle.mainBundle()
            .objectForInfoDictionaryKey("CFBundleShortVersionString") as? String {
                return version
        }
        return ""
    }
    
    // MARK: - Feedback
    
    private func osVersion() -> String {
        return NSProcessInfo().operatingSystemVersionString
    }
    
    private func device() -> String {
        var sysInfo: [CChar] = Array(count: sizeof(utsname), repeatedValue: 0)
        let machine = sysInfo.withUnsafeMutableBufferPointer {
            (inout ptr: UnsafeMutableBufferPointer<CChar>) -> String in
            uname(UnsafeMutablePointer<utsname>(ptr.baseAddress))
            let machinePtr = ptr.baseAddress.advancedBy(Int(_SYS_NAMELEN * 4))
            return String.fromCString(machinePtr)!
        }
        return machine
    }
    
    func presentFeedback() {
        let mailComposeViewController = configuredMailComposeViewController()
        presentViewController(
            mailComposeViewController,
            animated: true,
            completion: nil
        )
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["lexrus@gmail.com"])
        mailComposerVC.setSubject("[VPN On] Feedback \(appVersion())")

        let osVersion = NSProcessInfo().operatingSystemVersion
        let osVersionString = "\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
        
        let deviceInfo = "<small style='color:#999'>iOS \(osVersionString)"
            + " | Model: \(device())</small><br/>"
            + "<small style='color:green'>Please feel free to comment or advise if you have anything to say.</small> 🤓<br/><br/>"
        mailComposerVC.setMessageBody(deviceInfo, isHTML: true)
        
        return mailComposerVC
    }
    
    func mailComposeController(
        controller: MFMailComposeViewController,
        didFinishWithResult result: MFMailComposeResult,
        error: NSError?) {
            controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Review
    
    func presentAppStore() {
        let appStoreURL =
            NSURL(string: "https://itunes.apple.com/app/vpn-on/id951344279")!
        UIApplication.sharedApplication().openURL(appStoreURL)
    }

}
