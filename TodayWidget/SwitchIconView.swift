//
//  SwitchIconView.swift
//  VPNOn
//
//  Created by Lex Tang on 3/24/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit

class SwitchIconView: UIView {
    
    override func didMoveToSuperview() {
        if superview != nil {
            backgroundColor = UIColor.clearColor()
        }
    }
    
    override func drawRect(rect: CGRect) {
        let insetRect = rect.insetBy(dx: 1, dy: 1)
        let color = UIColor.whiteColor()
        
        let radius: CGFloat = insetRect.size.height / 2.0
        let circleWidth: CGFloat = radius * 2 - 2
        let circleX: CGFloat = insetRect.origin.x + 1
        let circleY: CGFloat = insetRect.origin.y + 1
        
        let rectangle2Path = UIBezierPath(roundedRect: insetRect, cornerRadius: radius)
        color.setStroke()
        rectangle2Path.lineWidth = 1
        rectangle2Path.stroke()
        
        let ovalPath = UIBezierPath(ovalInRect:
            CGRect(x: circleX, y: circleY, width: circleWidth, height: circleWidth)
        )
        color.setFill()
        ovalPath.fill()
    }

}
