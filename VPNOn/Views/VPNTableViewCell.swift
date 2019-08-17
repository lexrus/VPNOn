//
//  VPNTableViewCell.swift
//  VPNOn
//
//  Created by Lex on 1/16/15.
//  Copyright (c) 2017 lexrus.com. All rights reserved.
//

import UIKit

private let kAccessoryWidth: CGFloat = 16
private let kRightMargin: CGFloat = 36

class VPNTableViewCell : NormalTableViewCell {

    var IKEv2: Bool = false {
        didSet { setNeedsDisplay() }
    }

    var current: Bool = false {
        didSet { setNeedsDisplay() }
    }

    override func draw(_ rect: CGRect) {
        if IKEv2 {
            let tagWidth: CGFloat = 34
            let tagHeight: CGFloat = 14
            let tagX: CGFloat

            if isRightToLeft {
                tagX = (accessoryView?.frame.maxX ?? 0) + kRightMargin + kAccessoryWidth
            } else {
                tagX = bounds.width
                     - tagWidth
                     - kAccessoryWidth
                     - kRightMargin
            }

            let tagY = (bounds.height - tagHeight) / 2
            let tagRect = CGRect(x: tagX, y: tagY, width: tagWidth, height: tagHeight)
            drawIKEv2Tag(radius: 2, rect: tagRect, tagText: "IKEv2", color: tintColor)
        }
        if current {
            let currentIndicatorRect = CGRect(
                x: 0,
                y: 0,
                width: 3,
                height: rect.height
            )
            let rectanglePath = UIBezierPath(rect: currentIndicatorRect)
            LTThemeManager.shared.currentTheme!.tintColor.setFill()
            rectanglePath.fill()
        }
    }

    func drawIKEv2Tag(radius: CGFloat, rect: CGRect, tagText: String, color: UIColor) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        let height: CGFloat = rect.size.height / 1.20

        let rectanglePath = UIBezierPath(roundedRect: rect, cornerRadius: radius)
        color.setStroke()
        rectanglePath.lineWidth = 1
        rectanglePath.stroke()

        //// Text Drawing
        let textRect = rect
        let textStyle = NSMutableParagraphStyle.default
            .mutableCopy() as! NSMutableParagraphStyle
        textStyle.alignment = NSTextAlignment.center

        let textFontAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: height - 1),
            .foregroundColor: color,
            .paragraphStyle: textStyle
        ]

        let textTextHeight: CGFloat = NSString(string: tagText)
            .boundingRect(
                with: CGSize(width: textRect.width, height: CGFloat.infinity),
                options: NSStringDrawingOptions.usesLineFragmentOrigin,
                attributes: textFontAttributes,
                context: nil
            ).size.height
        context.saveGState()
        context.clip(to: textRect)
        NSString(string: tagText).draw(
            in: CGRect(
                x: textRect.minX,
                y: textRect.minY + (textRect.height - textTextHeight) / 2,
                width: textRect.width,
                height: textTextHeight
            ),
            withAttributes: textFontAttributes
        )
        context.restoreGState()
    }

}
