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

final class ModeButton: UIView {
    
    var displayMode: WidgetDisplayMode = .FlagMode {
        didSet {
            let displayFlags = (displayMode == .FlagMode)
            
            self.switchIconView.hidden = !displayFlags
        }
    }
    
    private var effectView: UIVisualEffectView {
        if let view = (subviews
            .filter { $0.isKindOfClass(UIVisualEffectView.self) })
            .first as? UIVisualEffectView {
                return view
        }

        let view = UIVisualEffectView(
            effect: UIVibrancyEffect.notificationCenterVibrancyEffect()
        )

        addSubview(view)
        return view
    }
    
    private var switchIconView: SwitchIconView {
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
        switchIcon.frame = CGRect(x: 2, y: 2, width: 20, height: 12)
        effectView.contentView.addSubview(switchIcon)
        return switchIcon
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let x = CGRectGetWidth(self.bounds) - 24 - 10
        self.effectView.frame = CGRect(x: x, y: 14, width: 24, height: 16)
    }
}
