//
//  About.swift
//  VPNOn
//
//  Created by Lex Tang on 1/6/15.
//  Copyright (c) 2017 lexrus.com. All rights reserved.
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
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
        ) -> Int {
            if MFMailComposeViewController.canSendMail() {
                return 3
            } else {
                return 2
            }
    }
    
    override func tableView(
        _ tableView: UITableView,
        titleForFooterInSection section: Int
        ) -> String? {
        return appVersion()
    }
    
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
        ) {
        switch (indexPath as NSIndexPath).row {
        case kReviewCellIndex:
            presentAppStore()

        case kFeedbackCellIndex:
            presentFeedback()

        default:
            ()
        }
    }
    
    fileprivate func appVersion() -> String {
        if let version = Bundle.main
            .object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
                return version
        }
        return ""
    }
    
    // MARK: - Feedback
    
    fileprivate func osVersion() -> String {
        return ProcessInfo().operatingSystemVersionString
    }
    
    fileprivate func device() -> String {
        var sysinfo = utsname()
        _ = uname(&sysinfo)
        return NSString(bytes: &sysinfo.machine, length: Int(_SYS_NAMELEN), encoding: String.Encoding.ascii.rawValue)! as String
    }
    
    func presentFeedback() {
        let mailComposeViewController = configuredMailComposeViewController()
        present(
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

        let osVersion = ProcessInfo().operatingSystemVersion
        let osVersionString = "\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
        
        let deviceInfo = "<small style='color:#999'>iOS \(osVersionString)"
            + " | Model: \(device())</small><br/>"
            + "<small style='color:green'>Please feel free to comment or advise if you have anything to say.</small> 🤓<br/><br/>"
        mailComposerVC.setMessageBody(deviceInfo, isHTML: true)
        
        return mailComposerVC
    }
    
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?) {
            controller.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Review
    
    func presentAppStore() {
        let appStoreURL =
            URL(string: "https://itunes.apple.com/app/vpn-on/id951344279")!
        UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
    }

}
