//
//  NormalTableViewCell.swift
//  VPNOn
//
//  Created by Lex on 10/31/15.
//  Copyright © 2016 lexrus.com. All rights reserved.
//

import UIKit

private let kAccessoryWidth: CGFloat = 20

class NormalTableViewCell : UITableViewCell {
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        if newSuperview == nil || accessoryType != .DisclosureIndicator {
            return
        }
        if accessoryView == nil {
            accessoryView = LTTableViewCellDeclosureIndicator()
            accessoryView!.frame = CGRect(
                x: 0,
                y: 0,
                width: kAccessoryWidth,
                height: kAccessoryWidth
            )
        }
    }
    
}
