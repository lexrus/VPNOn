//
//  VPNFlagAnimatable.swift
//  VPNOn
//
//  Created by Lex on 08/10/2016.
//  Copyright © 2017 lexrus.com. All rights reserved.
//

import UIKit

protocol VPNFlagAnimatable {
    
    var flagImageView: UIImageView { get }
    
    var titleLabel: UILabel { get }
    
    var connected: Bool { get set }
    
    func startAnimating()
    
    func stopAnimating()
    
    func startBreathing()
    
    func stopBreathing()
    
}

extension VPNFlagAnimatable {
    
    private var textColor: UIColor {
        if ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 10 {
            return UIColor.black
        } else {
            return UIColor.white
        }
    }
    
    var connected: Bool {
        get {
            return self.flagImageView.alpha == 1
        }
        set {
            self.flagImageView.alpha = newValue ? 1 : 0.8
            self.titleLabel.textColor = newValue ? connectedColor : textColor
        }
    }
    
    func startAnimating() {
        flagImageView.layer.removeAllAnimations()
        
        let bounce = CABasicAnimation(keyPath: "position.y")
        bounce.duration = 0.3
        bounce.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        bounce.repeatCount = .infinity
        bounce.autoreverses = true
        bounce.fromValue = flagImageView.layer.position.y
        bounce.toValue = flagImageView.layer.position.y - 6
        flagImageView.layer.add(bounce, forKey: "bounce")
    }
    
    func stopAnimating() {
        flagImageView.layer.removeAllAnimations()
    }
    
    func startBreathing() {
        flagImageView.layer.removeAllAnimations()
        
        let breathing = CABasicAnimation(keyPath: "borderColor")
        breathing.fromValue = connectedColor.withAlphaComponent(0.4).cgColor
        breathing.toValue = connectedColor.cgColor
        breathing.repeatCount = .infinity
        breathing.autoreverses = true
        breathing.duration = 1
        flagImageView.layer.add(breathing, forKey: "breathing")
    }
    
    func stopBreathing() {
        flagImageView.layer.removeAllAnimations()
        flagImageView.transform = .identity
        
        let borderWidth: CGFloat = connected ? 2 : 0
        flagImageView.layer.borderWidth = borderWidth
    }
    
}

private let connectedColor = UIColor(red: 0, green: 0.5, blue: 1, alpha: 1)
