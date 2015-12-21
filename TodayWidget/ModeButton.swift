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

class ModeButton: UIView {
    
    var displayMode: WidgetDisplayMode = .FlagMode {
        didSet {
            let displayFlags = (displayMode == .FlagMode)
            
            self.switchIconView.hidden = !displayFlags
        }
    }
    
    var effectView: UIVisualEffectView {
        if let view = (subviews
            .filter { $0.isKindOfClass(UIVisualEffectView.self) })
            .first as? UIVisualEffectView {
                return view
        }

        let view = UIVisualEffectView(
            effect: UIVibrancyEffect.notificationCenterVibrancyEffect()
        )

        view.autoresizingMask = UIViewAutoresizing.FlexibleHeight
        addSubview(view)
        return view
    }
    
    var switchIconView: SwitchIconView {
        if let view = (effectView.contentView.subviews
            .filter { $0.isKindOfClass(SwitchIconView.self) })
            .first as? SwitchIconView {
                return view
        }
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

    override func layoutSubviews() {
        super.layoutSubviews()
        let x = CGRectGetWidth(self.bounds) - 24 - 10
        self.effectView.frame = CGRectMake(x, 14, 24, 16)
    }
}
