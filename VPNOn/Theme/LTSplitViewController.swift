//
//  LTSplitViewController.swift
//  VPNOn
//
//  Created by Lex on 1/18/15.
//  Copyright (c) 2017 lexrus.com. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let ThemeDidUpdate = Notification.Name("ThemeDidUpdate")
}

class LTSplitViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if LTThemeManager.shared.currentTheme?.name.range(of: "Light") != nil {
            return UIStatusBarStyle.default
        } else {
            return UIStatusBarStyle.lightContent
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if event?.subtype == UIEvent.EventSubtype.motionShake {
            LTThemeManager.shared.activateNextTheme()
            self.setNeedsStatusBarAppearanceUpdate()
            NotificationCenter.default.post(name: .ThemeDidUpdate, object: nil)
        }
    }

}
