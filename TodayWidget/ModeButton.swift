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

class ModeButton: UIView
{
    var displayMode: WidgetDisplayMode = .FlagMode {
        didSet {
            let displayFlags = (displayMode == .FlagMode)
            
            self.switchIconView.hidden = !displayFlags
        }
    }
    
    var effectView: UIVisualEffectView {
        get {
            if let _effectView = self.subviews.first as UIVisualEffectView? {
                if _effectView.isKindOfClass(UIVisualEffectView.self) {
                    return _effectView
                }
            }
            let _effectView = UIVisualEffectView(effect: UIVibrancyEffect.notificationCenterVibrancyEffect())
            _effectView.frame = CGRectMake(14, 14, 24, self.bounds.size.height - 14)
            _effectView.autoresizingMask = UIViewAutoresizing.FlexibleHeight
            addSubview(_effectView)
            return _effectView
        }
    }
    
    var expandIconView: UILabel {
        get {
            for icon in self.effectView.contentView.subviews {
                if icon.isKindOfClass(UILabel.self) {
                    return icon as UILabel
                }
            }
            
            let rect = CGRectMake(0, self.effectView.bounds.size.height - 33, 24, 33)
            let expandIcon = UILabel(frame: rect)
            expandIcon.textColor = UIColor.whiteColor()
            expandIcon.text = "..."
            expandIcon.textAlignment = NSTextAlignment.Center
            expandIcon.font = UIFont.systemFontOfSize(12)
            expandIcon.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin
            self.effectView.contentView.addSubview(expandIcon)
            return expandIcon
        }
    }
    
    var switchIconView: SwitchIconView {
        get {
            for icon in self.effectView.contentView.subviews {
                if icon.isKindOfClass(SwitchIconView.self) {
                    return icon as SwitchIconView
                }
            }
            
            let switchIcon = SwitchIconView()
            switchIcon.frame = CGRectMake(2, 2, 20, 12)
            self.effectView.contentView.addSubview(switchIcon)
            return switchIcon
        }
    }
}
