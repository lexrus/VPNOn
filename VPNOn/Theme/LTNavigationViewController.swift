//
//  LTNavigationViewController.swift
//  VPNOn
//
//  Created by Lex on 2020/3/15.
//  Copyright © 2020 lexrus.com. All rights reserved.
//

import UIKit

class LTNavigationViewController : UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modalPresentationCapturesStatusBarAppearance = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            if LTThemeManager.shared.currentTheme?.name.range(of: "Light") != nil {
                return .darkContent
            } else {
                return .lightContent
            }
        } else {
            return .lightContent
        }
    }
    
}
