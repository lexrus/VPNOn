//
//  VPNCell.swift
//  VPNOn
//
//  Created by Lex Tang on 3/5/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit
import VPNOnKit
import NetworkExtension
import QuartzCore

class VPNCell: UICollectionViewCell {
    
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var latencyLabel: UILabel!

    override func didMoveToSuperview() {
        flagImageView.layer.masksToBounds = true
        flagImageView.layer.cornerRadius = 5
        titleLabel.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 12)
        latencyLabel.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 16)
    }
    
    var current: Bool = false
    
    var latency: Int = -1 {
        didSet {
            latencyLabel.hidden = !flagImageView.hidden
            if latency == -1 {
                latencyLabel.text = "--"
            } else {
                latencyLabel.text = "\(latency)ms"
            }
            latencyLabel.textColor = colorOfLatency
            setNeedsDisplay()
        }
    }
    
    var colorOfLatency: UIColor {
        get {
            var latencyColor = UIColor(red: 0.5, green: 0.8, blue: 0.19, alpha: 1)
            
            if latency > 200 {
                latencyColor = UIColor(red: 0.7, green: 0.5, blue: 0.0, alpha: 1)
            } else if latency > 500 {
                latencyColor = UIColor(red: 1, green: 0.11, blue: 0.34, alpha: 1)
            } else if latency == -1 {
                latencyColor = UIColor(white: 0.4, alpha: 1)
            }
            
            return latencyColor
        }
    }
    
    var status: NEVPNStatus = .Disconnected {
        didSet {
            updateTitleColor()
            animateFlagByStatus()
        }
    }
    
    override func drawRect(rect: CGRect) {
        if VPNManager.sharedManager.status == .Connected {
            return
        }
        
        if latency == -1 {
            return
        }
        
        if flagImageView.hidden {
            return
        }
        
        var lineRect = flagImageView.frame
        lineRect.origin.y = lineRect.origin.y - 6
        lineRect.size.height = 2
        let dotSpacing: CGFloat = 3
        lineRect.origin.x += dotSpacing
        lineRect.size.width -= dotSpacing * 2
        
        var rectanglePath = UIBezierPath(roundedRect: lineRect, cornerRadius: 2)
        
        colorOfLatency.setFill()
        rectanglePath.fill()
    }
    
    func configureWithVPN(vpn: VPN, selected: Bool = false) {
        titleLabel.text = vpn.title
        
        if let countryCode = vpn.countryCode {
            flagImageView.image = UIImage(named: countryCode)
            flagImageView.hidden = false
        } else {
            flagImageView.image = nil
            flagImageView.hidden = true
        }

        current = selected
        if selected && VPNManager.sharedManager.status == .Connected {
            flagImageView.alpha = 1.0
        } else {
            flagImageView.alpha = 0.5
        }
        
        updateTitleColor()
    }
    
    func updateTitleColor() {
        var statusColor = UIColor(white: 1, alpha: 0.5)
        
        switch status {
        case .Connected:
            statusColor = UIColor(red: 0, green: 0.75, blue: 1, alpha: 1)
            break
        case .Connecting:
            statusColor = UIColor.yellowColor()
            break
        default:
            ()
        }
        
        titleLabel.textColor = statusColor
    }
    
    func animateFlagByStatus() {
        flagImageView.layer.removeAllAnimations()
        
        if status == .Connecting {
            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.duration = 0.4
            scaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            scaleAnimation.repeatCount = HUGE
            scaleAnimation.autoreverses = true
            scaleAnimation.fromValue = 1.0
            scaleAnimation.toValue = 1.1
            flagImageView.layer.addAnimation(scaleAnimation, forKey: "scale")
        }
    }
}
