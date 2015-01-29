//
//  LTVPNDomainsViewController.swift
//  VPNOn
//
//  Created by Lex Tang on 1/28/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit
import VPNOnKit

@objc protocol LTVPNDomainsViewControllerDelegate {
    optional func didTapSaveDomainsWithText(text: String)
}

class LTVPNDomainsViewController: UITableViewController
{
    weak var delegate: LTVPNDomainsViewControllerDelegate?

    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var textView: UITextView!
    
    @IBAction func save(sender: AnyObject?) {
        VPNManager.sharedManager().onDemandDomains = textView.text
        
        if let d = delegate {
            d.didTapSaveDomainsWithText?(textView.text)
        }
        popDetailViewController()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        textView.text = VPNManager.sharedManager().onDemandDomains
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        delegate = nil
    }

    // MARK: - Navigation
    
    func popDetailViewController() {
        let topNavigationController = splitViewController!.viewControllers.last! as UINavigationController
        topNavigationController.popViewControllerAnimated(true)
    }
}
