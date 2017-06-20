//
//  VPNConnectionCell.swift
//  VPNOn
//
//  Created by Lex Tang on 1/26/15.
//  Copyright (c) 2017 lexrus.com. All rights reserved.
//

import UIKit

class VPNSwitchCell : VPNTableViewCell {
    
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet weak var titleLabel: LTTableViewCellTitle!

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        if superview != nil && isRightToLeft {
            titleLabel.textAlignment = .right
        }
    }
    
}
