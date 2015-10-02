//
//  VPNTypeTag.swift
//  VPNOn
//
//  Created by Lex Tang on 1/28/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit

enum VPNType {
    case IKEv1, IKEv2
    
    func simpleDescription() -> String {
        switch self {
        case IKEv2:
            return "IKEv2"
        default:
            return "IKEv1"
        }
    }
}

class VPNTypeTag : UIVisualEffectView {
    
    var type: VPNType = .IKEv1
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        backgroundColor = UIColor.clearColor()
    }
    
    override func drawRect(rect: CGRect) {
        drawIKEv2Tag(
            radius: 3,
            rect: CGRectInset(rect, 1, 1),
            tagText: type.simpleDescription(),
            color: UIColor.whiteColor())
    }
    
    func drawIKEv2Tag(radius radius: CGFloat, rect: CGRect, tagText: String, color: UIColor) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()
        
        //// Variable Declarations
        let height: CGFloat = rect.size.height / 1.20
        
        //// Rectangle Drawing
        let rectanglePath = UIBezierPath(roundedRect: rect, cornerRadius: radius)
        color.setStroke()
        rectanglePath.lineWidth = 1
        rectanglePath.stroke()
        
        //// Text Drawing
        let textRect = CGRectMake(rect.minX, rect.minY, rect.width, rect.height)
        let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        textStyle.alignment = NSTextAlignment.Center
        
        let textFontAttributes = [
            NSFontAttributeName: UIFont.systemFontOfSize(height - 1),
            NSForegroundColorAttributeName: color,
            NSParagraphStyleAttributeName: textStyle
        ]
        
        let textSize = CGSizeMake(CGRectGetWidth(textRect), CGFloat.infinity)
        let textTextHeight: CGFloat = {
            let properRect = NSString(string: tagText)
                .boundingRectWithSize(
                    textSize,
                    options: .UsesLineFragmentOrigin,
                    attributes: textFontAttributes,
                    context: nil)
            return properRect.size.height
        }()
        
        CGContextSaveGState(context)
        CGContextClipToRect(context, textRect);
        
        let drawringRect = CGRectMake(
            textRect.minX,
            textRect.minY + (textRect.height - textTextHeight) / 2,
            textRect.width,
            textTextHeight
        )
        NSString(string: tagText).drawInRect(drawringRect, withAttributes: textFontAttributes)
        CGContextRestoreGState(context)
    }
}
