//
//  LTVPNTableViewCell.swift
//  VPNOn
//
//  Created by Lex on 1/16/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit

class LTVPNTableViewCell: UITableViewCell
{
    override func willMoveToSuperview(newSuperview: UIView?) {
        if newSuperview != nil {
            if accessoryType == .DisclosureIndicator {
                if accessoryView == nil {
                    accessoryView = LTTableViewCellDeclosureIndicator()
                    accessoryView!.frame = CGRectMake(0, 0, 16, 16)
                }
            }
        }
    }
}
