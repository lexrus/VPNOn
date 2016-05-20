//
//  LTTableViewCellDeclosureIndicator.swift
//  VPNOn
//
//  Created by Lex Tang on 1/23/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit

private let lineWidth: CGFloat = 1.5

class LTTableViewCellDeclosureIndicator : UIView {

    override func willMoveToSuperview(newSuperview: UIView?) {
        if newSuperview != nil {
            backgroundColor = UIColor.clearColor()
        }
    }

    override func drawRect(rect: CGRect) {
        let delta = CGFloat(6)
        let centerX = rect.width / 2
        let middleY = rect.height / 2

        let context = UIGraphicsGetCurrentContext()

        if isRightToLeft {
            CGContextMoveToPoint(context, centerX + delta / 2, middleY - delta)
            CGContextAddLineToPoint(context, centerX - delta / 2, middleY)
            CGContextAddLineToPoint(context, centerX + delta / 2, middleY + delta)
        } else {
            CGContextMoveToPoint(context, centerX - delta / 2, middleY - delta)
            CGContextAddLineToPoint(context, centerX + delta / 2, middleY)
            CGContextAddLineToPoint(context, centerX - delta / 2, middleY + delta)
        }

        CGContextSetLineWidth(context, lineWidth)
        CGContextSetLineJoin(context, .Miter)
        CGContextSetLineCap(context, .Square)

        CGContextSetStrokeColorWithColor(context, LTThemeManager.sharedManager.currentTheme!.textColor.CGColor)

        CGContextStrokePath(context)
    }
    
}
