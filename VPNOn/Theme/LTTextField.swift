//
//  LTTextField.swift
//  VPNOn
//
//  Created by Lex Tang on 1/21/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit

class LTTextField: UITextField {
    
    override func drawPlaceholderInRect(rect: CGRect) {
        LTDarkTheme().placeholderColor.setFill()
        
        let attributes: [NSObject: AnyObject] = [
            NSForegroundColorAttributeName: LTThemeManager.sharedManager.currentTheme!.placeholderColor,
            NSFontAttributeName: font
        ]
        
        let middleRect = fixedMiddlePlaceholderRect(rect)
        
        println("\(middleRect)")
        
        self.placeholder?.drawInRect(middleRect, withAttributes: attributes)
    }
    
    private func fixedMiddlePlaceholderRect(rect: CGRect) -> CGRect {
        return CGRectMake(bounds.origin.x, bounds.origin.y + (rect.size.height - font.pointSize) / 2 - 2, rect.size.width, font.pointSize)
    }

}
