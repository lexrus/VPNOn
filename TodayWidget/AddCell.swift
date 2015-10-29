//
//  AddCell.swift
//  VPNOn
//
//  Created by Lex Tang on 3/6/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit

class AddCell : UICollectionViewCell {

    private var iconView: PlusMarkView {
        if let
            effectView = contentView.subviews.first as? UIVisualEffectView,
            markView = effectView.contentView.subviews.first as? PlusMarkView {
            return markView
        }
        
        let effectView = UIVisualEffectView(effect:
            UIVibrancyEffect.notificationCenterVibrancyEffect())
        
        let plusMark = PlusMarkView()
        effectView.frame = bounds
        effectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        effectView.contentView.addSubview(plusMark)
        addSubview(effectView)
        return plusMark
    }
    
    override func didMoveToSuperview() {
        iconView.frame = CGRectMake((CGRectGetWidth(bounds) - 50) / 2, 14, 50, 32)
    }
}

private class PlusMarkView : UIView {
    
    private let lineWidth: CGFloat = 0.5
    
    override func didMoveToSuperview() {
        if superview != nil {
            backgroundColor = UIColor.clearColor()
        }
    }
    
    override func drawRect(rect: CGRect) {
        let color = UIColor.whiteColor()
        color.setFill()
        color.setStroke()
        
        let borderRect = CGRectMake(
            lineWidth, lineWidth,
            rect.width - lineWidth * 2, rect.height - lineWidth * 2)
        
        let borderPath = UIBezierPath(roundedRect: borderRect, cornerRadius: rect.height / 2)
        borderPath.lineWidth = lineWidth
        borderPath.stroke()
        
        let plusWidth = borderRect.width / 4
        
        let plusLine0Rect = CGRectMake(
            (borderRect.width - plusWidth) / 2,
            borderRect.height / 2,
            plusWidth,
            lineWidth)
        UIBezierPath(rect: plusLine0Rect).fill()
        
        let plusLine1Rect = CGRectMake(
            borderRect.width / 2,
            (borderRect.height - plusWidth) / 2,
            lineWidth,
            plusWidth)
        UIBezierPath(rect: plusLine1Rect).fill()
    }
}
