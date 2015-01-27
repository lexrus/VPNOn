//
//  LTTableViewCellDeclosureIndicator.swift
//  VPNOn
//
//  Created by Lex Tang on 1/23/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit

class LTTableViewCellDeclosureIndicator: UIView
{
    override func willMoveToSuperview(newSuperview: UIView?) {
        if newSuperview != nil {
            backgroundColor = UIColor.clearColor()
        }
    }
    
    override func drawRect(rect: CGRect) {
        let x = CGRectGetMaxX(self.bounds) - 2
        let y = CGRectGetMidY(self.bounds)
        let r = CGFloat(4.5)
        
        let context = UIGraphicsGetCurrentContext()
        
        CGContextMoveToPoint(context, x - r, y - r)
        CGContextAddLineToPoint(context, x, y)
        CGContextAddLineToPoint(context, x - r, y + r)
        
        CGContextSetLineWidth(context, 2)
        CGContextSetLineJoin(context, kCGLineJoinMiter)
        CGContextSetLineCap(context, kCGLineCapSquare)
        
        CGContextSetStrokeColorWithColor(context, LTThemeManager.sharedManager.currentTheme!.textColor.CGColor)
        
        CGContextStrokePath(context)
    }

}
