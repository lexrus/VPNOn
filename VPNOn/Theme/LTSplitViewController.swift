//
//  LTSplitViewController.swift
//  VPNOn
//
//  Created by Lex on 1/18/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit

class LTSplitViewController: UISplitViewController
{

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

}
