//
//  LTTableViewActionCell.swift
//  VPNOn
//
//  Created by Lex Tang on 1/21/15.
//  Copyright (c) 2017 lexrus.com. All rights reserved.
//

import UIKit

class LTTableViewActionCell: UITableViewCell
{
    private var iDisabled = false
    var disabled: Bool {
        get {
            return iDisabled
        }
        set {
            if newValue {
                self.textLabel?.textColor = LTThemeManager.shared.currentTheme!.textColor
            } else {
                self.textLabel?.textColor = LTThemeManager.shared.currentTheme!.tintColor
            }
        }
    }
}
