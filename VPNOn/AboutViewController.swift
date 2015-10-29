//
//  AboutViewController.swift
//  VPNOn
//
//  Created by Lex Tang on 1/6/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit

class AboutViewController : UIViewController {
    
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String {
            versionLabel.text = version
        }
    }

}
