//
//  LTTextField.swift
//  VPNOn
//
//  Created by Lex Tang on 1/21/15.
//  Copyright (c) 2017 lexrus.com. All rights reserved.
//

import UIKit

class LTTextField: UITextField {
    
    override func drawPlaceholder(in rect: CGRect) {
        LTDarkTheme().placeholderColor.setFill()
        let f = font ?? UIFont.systemFont(ofSize: 12)
        
        let attributes: [NSAttributedStringKey : AnyObject] = [
            .foregroundColor: LTThemeManager.shared.currentTheme!.placeholderColor,
            .font: f
        ]
        
        let middleRect = fixedMiddlePlaceholderRect(rect)
        
        self.placeholder?.draw(in: middleRect, withAttributes: attributes)
    }
    
    fileprivate func fixedMiddlePlaceholderRect(_ rect: CGRect) -> CGRect {
        let fontSize = font?.pointSize ?? 12
        return CGRect(
            x: rect.minX,
            y: (rect.height - fontSize) / 2 - 2,
            width: rect.width,
            height: fontSize * 1.3
        )
    }

}
