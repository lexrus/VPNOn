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
        let f = font ?? UIFont.systemFontOfSize(12)
        
        let attributes: [String : AnyObject] = [
            NSForegroundColorAttributeName: LTThemeManager.sharedManager.currentTheme!.placeholderColor,
            NSFontAttributeName: f
        ]
        
        let middleRect = fixedMiddlePlaceholderRect(rect)
        
        self.placeholder?.drawInRect(middleRect, withAttributes: attributes)
    }
    
    private func fixedMiddlePlaceholderRect(rect: CGRect) -> CGRect {
        let fontSize = font?.pointSize ?? 12
        return CGRect(
            x: rect.minX,
            y: (rect.height - fontSize) / 2 - 2,
            width: rect.width,
            height: fontSize * 1.3
        )
    }

}
