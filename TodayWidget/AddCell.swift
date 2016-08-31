//
//  AddCell.swift
//  VPNOn
//
//  Created by Lex Tang on 3/6/15.
//  Copyright (c) 2016 lexrus.com. All rights reserved.
//

import UIKit

class AddCell : UICollectionViewCell {

    fileprivate var iconView: PlusMarkView {
        if let
            effectView = contentView.subviews.first as? UIVisualEffectView,
            let markView = effectView.contentView.subviews.first as? PlusMarkView {
            return markView
        }
        
        let effectView = UIVisualEffectView(effect:
            UIVibrancyEffect.notificationCenter())
        
        let plusMark = PlusMarkView()
        effectView.frame = bounds
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        effectView.contentView.addSubview(plusMark)
        addSubview(effectView)
        return plusMark
    }
    
    override func didMoveToSuperview() {
        iconView.frame = CGRect(
            x: (bounds.width - 50) / 2,
            y: 14,
            width: 50,
            height: 32
        )
    }
}

private class PlusMarkView : UIView {
    
    fileprivate let lineWidth: CGFloat = 0.5
    
    override func didMoveToSuperview() {
        if superview != nil {
            backgroundColor = UIColor.clear
        }
    }
    
    override func draw(_ rect: CGRect) {
        let color = UIColor.white
        color.setFill()
        color.setStroke()
        
        let borderRect = CGRect(
            x: lineWidth,
            y: lineWidth,
            width: rect.width - lineWidth * 2,
            height: rect.height - lineWidth * 2
        )
        
        let borderPath = UIBezierPath(roundedRect: borderRect, cornerRadius: rect.height / 2)
        borderPath.lineWidth = lineWidth
        borderPath.stroke()
        
        let plusWidth = borderRect.width / 4
        
        let plusLine0Rect = CGRect(
            x: (borderRect.width - plusWidth) / 2,
            y: borderRect.height / 2,
            width: plusWidth,
            height: lineWidth
        )
        UIBezierPath(rect: plusLine0Rect).fill()
        
        let plusLine1Rect = CGRect(
            x: borderRect.width / 2,
            y: (borderRect.height - plusWidth) / 2,
            width: lineWidth,
            height: plusWidth
        )
        UIBezierPath(rect: plusLine1Rect).fill()
    }
}
