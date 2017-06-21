//
//  VPNDomains.swift
//  VPNOn
//
//  Created by Lex Tang on 1/28/15.
//  Copyright (c) 2017 lexrus.com. All rights reserved.
//

import UIKit
import VPNOnKit

protocol VPNDomainsDelegate : NSObjectProtocol {
    func didTapSaveDomainsWithText(_ text: String)
}

class VPNDomains : UITableViewController {
    
    weak var delegate: VPNDomainsDelegate?

    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var textView: UITextView!
    
    @IBAction func save(_ sender: AnyObject?) {
        VPNManager.shared.onDemandDomains = textView.text
        
        delegate?.didTapSaveDomainsWithText(textView.text)
        popDetailViewController()
    }
    
    override func loadView() {
        super.loadView()
        
        let backgroundView = LTViewControllerBackground()
        tableView.backgroundView = backgroundView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textView.text = VPNManager.shared.onDemandDomains
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate = nil
    }

    // MARK: - Navigation
    
    func popDetailViewController() {
        if let topNC = splitViewController?.viewControllers.last
            as? UINavigationController {
                topNC.popViewController(animated: true)
        }
    }
}
