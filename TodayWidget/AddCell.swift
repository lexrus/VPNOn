//
//  AddCell.swift
//  VPNOn
//
//  Created by Lex Tang on 3/6/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit

class AddCell: UICollectionViewCell
{
    var iconView: PlusMarkView {
        get {
            if let effectView = self.contentView.subviews.first as! UIVisualEffectView? {
                if effectView.isKindOfClass(UIVisualEffectView.self) {
                    if effectView.contentView.subviews.count > 0 {
                        return effectView.contentView.subviews.first! as! PlusMarkView
                    }
                }
            }
            
            let effectView = UIVisualEffectView(effect: UIVibrancyEffect.notificationCenterVibrancyEffect())
            let plusMark = PlusMarkView()
            effectView.frame = self.bounds
            effectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            effectView.contentView.addSubview(plusMark)
            addSubview(effectView)
            return plusMark
        }
    }
    
    override func didMoveToSuperview() {
        iconView.frame = CGRectMake((bounds.size.width - 48) / 2, 11, 48, 36)
    }
}
