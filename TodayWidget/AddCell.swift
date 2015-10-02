//
//  AddCell.swift
//  VPNOn
//
//  Created by Lex Tang on 3/6/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit

class AddCell : UICollectionViewCell {

    var iconView: PlusMarkView {
        if let
            effectView = contentView.subviews.first as? UIVisualEffectView,
            markView = effectView.contentView.subviews.first as? PlusMarkView {
            return markView
        }
        
        let effectView = UIVisualEffectView(effect: UIVibrancyEffect.notificationCenterVibrancyEffect())
        let plusMark = PlusMarkView()
        effectView.frame = bounds
        effectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        effectView.contentView.addSubview(plusMark)
        addSubview(effectView)
        return plusMark
    }
    
    override func didMoveToSuperview() {
        iconView.frame = CGRectMake((CGRectGetWidth(bounds) - 48) / 2, 11, 48, 36)
    }
}
