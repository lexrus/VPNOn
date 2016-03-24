//
//  LTSplitViewController.swift
//  VPNOn
//
//  Created by Lex on 1/18/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit

class LTSplitViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        if LTThemeManager.sharedManager.currentTheme?.name.rangeOfString("Light") != nil {
            return UIStatusBarStyle.Default
        } else {
            return UIStatusBarStyle.LightContent
        }
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if event?.subtype == UIEventSubtype.MotionShake {
            LTThemeManager.sharedManager.activateNextTheme()
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }

}
