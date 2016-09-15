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
    
    override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil || accessoryType != .disclosureIndicator {
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
