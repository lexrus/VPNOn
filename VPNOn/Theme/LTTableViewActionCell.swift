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
    var _disabled = false
    var disabled: Bool {
        get {
            return _disabled
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
