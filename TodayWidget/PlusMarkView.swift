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
    override func drawRect(rect: CGRect) {
        //// Color Declarations
        let color = UIColor.whiteColor()
        
        //// Rectangle Drawing
        let rectanglePath = UIBezierPath(roundedRect: CGRectMake(1, 1, 48, 36), cornerRadius: 5)
        color.setStroke()
        rectanglePath.lineWidth = 2
        rectanglePath.stroke()
        
        
        //// Rectangle 2 Drawing
        let rectangle2Path = UIBezierPath(roundedRect: CGRectMake(18, 18, 15, 1), cornerRadius: 0.5)
        color.setStroke()
        rectangle2Path.lineWidth = 2
        rectangle2Path.stroke()
        
        
        //// Rectangle 3 Drawing
        let rectangle3Path = UIBezierPath(roundedRect: CGRectMake(25, 11, 1, 15), cornerRadius: 0.5)
        color.setStroke()
        rectangle3Path.lineWidth = 2
        rectangle3Path.stroke()

    }
}
