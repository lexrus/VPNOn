//
//  ModeButton.swift
//  VPNOn
//
//  Created by Lex Tang on 3/24/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit

enum WidgetDisplayMode {
    case SwitchMode, FlagMode
}

class ModeButton : UIView {
    
    var displayMode: WidgetDisplayMode = .FlagMode {
        didSet {
            let displayFlags = (displayMode == .FlagMode)
            
            self.switchIconView.hidden = !displayFlags
        }
    }
    
    var effectView: UIVisualEffectView {
        if let view = subviews.first as! UIVisualEffectView? {
            if view.isKindOfClass(UIVisualEffectView.self) {
                return view
            }
        }
        let view = UIVisualEffectView(effect: UIVibrancyEffect.notificationCenterVibrancyEffect())
        view.frame = CGRectMake(14, 14, 24, self.bounds.height - 14)
        view.autoresizingMask = UIViewAutoresizing.FlexibleHeight
        addSubview(view)
        return view
    }
    
    var expandIconView: UILabel {
        for icon in effectView.contentView.subviews {
            if icon.isKindOfClass(UILabel.self) {
                return icon as! UILabel
            }
        }
        
        let rect = CGRectMake(0, effectView.bounds.height - 33, 24, 33)
        let expandIcon = UILabel(frame: rect)
        expandIcon.textColor = UIColor.whiteColor()
        expandIcon.text = "..."
        expandIcon.textAlignment = NSTextAlignment.Center
        expandIcon.font = UIFont.systemFontOfSize(12)
        expandIcon.autoresizingMask = .FlexibleTopMargin
        effectView.contentView.addSubview(expandIcon)
        return expandIcon
    }
    
    var switchIconView: SwitchIconView {
        for icon in effectView.contentView.subviews {
            if icon.isKindOfClass(SwitchIconView.self) {
                return icon as! SwitchIconView
            }
        }
        
        let switchIcon = SwitchIconView()
        switchIcon.frame = CGRectMake(2, 2, 20, 12)
        effectView.contentView.addSubview(switchIcon)
        return switchIcon
    }
}
