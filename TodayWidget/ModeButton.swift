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
            _effectView.frame = CGRectMake(14, 14, 24, 16)
            addSubview(_effectView)
            return _effectView
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
