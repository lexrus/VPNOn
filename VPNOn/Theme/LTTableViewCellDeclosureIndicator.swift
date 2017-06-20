//
//  LTTableViewCellDeclosureIndicator.swift
//  VPNOn
//
//  Created by Lex Tang on 1/23/15.
//  Copyright (c) 2017 lexrus.com. All rights reserved.
//

import UIKit

private let lineWidth: CGFloat = 1.5

class LTTableViewCellDeclosureIndicator : UIView {

    override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview != nil {
            backgroundColor = UIColor.clear
        }
    }

    override func draw(_ rect: CGRect) {
        let delta = CGFloat(5)
        let centerX = rect.width / 2
        let middleY = rect.height / 2

        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        if isRightToLeft {
            context.move(to: CGPoint(x: centerX + delta / 2, y: middleY - delta))
            context.addLine(to: CGPoint(x: centerX - delta / 2, y: middleY))
            context.addLine(to: CGPoint(x: centerX + delta / 2, y: middleY + delta))
        } else {
            context.move(to: CGPoint(x: centerX - delta / 2, y: middleY - delta))
            context.addLine(to: CGPoint(x: centerX + delta / 2, y: middleY))
            context.addLine(to: CGPoint(x: centerX - delta / 2, y: middleY + delta))
        }

        context.setLineWidth(lineWidth)
        context.setLineJoin(.miter)
        context.setLineCap(.square)

        if let textColor = LTThemeManager.sharedManager.currentTheme?.textColor {
            context.setStrokeColor(textColor.cgColor)
        }

        context.strokePath()
    }
    
}
