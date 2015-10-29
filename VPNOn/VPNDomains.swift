//
//  VPNDomains.swift
//  VPNOn
//
//  Created by Lex Tang on 1/28/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit
import VPNOnKit

protocol VPNDomainsDelegate : NSObjectProtocol {
    func didTapSaveDomainsWithText(text: String)
}

class VPNDomains : UITableViewController {
    
    weak var delegate: VPNDomainsDelegate?

    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var textView: UITextView!
    
    @IBAction func save(sender: AnyObject?) {
        VPNManager.sharedManager.onDemandDomains = textView.text
        
        delegate?.didTapSaveDomainsWithText(textView.text)
        popDetailViewController()
    }
    
    override func loadView() {
        super.loadView()
        
        let backgroundView = LTViewControllerBackground()
        tableView.backgroundView = backgroundView
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        textView.text = VPNManager.sharedManager.onDemandDomains
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        delegate = nil
    }

    // MARK: - Navigation
    
    func popDetailViewController() {
        let topNavigationController = splitViewController!.viewControllers.last! as! UINavigationController
        topNavigationController.popViewControllerAnimated(true)
    }
}
