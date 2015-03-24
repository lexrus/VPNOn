//
//  PlusMarkView.swift
//  VPNOn
//
//  Created by Lex Tang on 3/6/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit

class PlusMarkView: UIView
{
    let lineWidth: CGFloat = 0.5
    
    override func didMoveToSuperview() {
        if superview != nil {
            backgroundColor = UIColor.clearColor()
        }
    }
    
    override func drawRect(rect: CGRect) {
        let color = UIColor.whiteColor()
        color.setFill()
        color.setStroke()
        
        let flagRect = CGRectMake(lineWidth, lineWidth, rect.size.width - lineWidth * 2, rect.size.height - lineWidth * 2)
        
        let rectanglePath = UIBezierPath(roundedRect: flagRect, cornerRadius: 5)
        rectanglePath.lineWidth = lineWidth
        rectanglePath.stroke()
        
        let plusWidth = flagRect.size.width / 3
        
        let rectangle2Path = UIBezierPath(rect: CGRectMake((flagRect.size.width - plusWidth) / 2, flagRect.size.height / 2, plusWidth, lineWidth))
        rectangle2Path.fill()
        
        let rectangle3Path = UIBezierPath(rect: CGRectMake(flagRect.size.width / 2, (flagRect.size.height - plusWidth) / 2, lineWidth, plusWidth))
        color.setFill()
        rectangle3Path.fill()
    }
}
