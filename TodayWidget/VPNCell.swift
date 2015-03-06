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
    
    var latency: Int = -1 {
        didSet {
            latencyLabel.textColor = colorOfLatency
            setNeedsDisplay()
        }
    }
    
    var colorOfLatency: UIColor {
        get {
            var latencyColor = UIColor(red:0.39, green:0.68, blue:0.19, alpha:1)
            
            if latency > 200 {
                latencyColor = UIColor(red:0.8, green:0.54, blue:0.21, alpha:1)
            } else if latency > 500 {
                latencyColor = UIColor(red:1 , green:0.11, blue:0.34, alpha:1)
            } else if latency == -1 {
                latencyColor = UIColor(white: 1.0, alpha: 0.5)
            }
            
            return latencyColor
        }
    }
    
    var status: NEVPNStatus = .Disconnected {
        didSet {
            flagImageView.transform = CGAffineTransformIdentity
            switch status {
            case .Connected:
                titleLabel.textColor = UIColor(red:0, green:0.75, blue:1, alpha:1)
                break
            case .Connecting:
                titleLabel.textColor = UIColor.yellowColor()
                break
            default:
                titleLabel.textColor = UIColor(white: 1.0, alpha: 0.5)
            }
            
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
        
        var lineRect = flagImageView.frame
        lineRect.origin.y = lineRect.origin.y - 6
        lineRect.size.height = 2
        let dotSpacing: CGFloat = 3
        let dotWidth = (lineRect.size.width - dotSpacing * 4) / 3
        lineRect.origin.x += dotSpacing
        lineRect.size.width = dotWidth
        
        var rectanglePath = UIBezierPath(roundedRect: lineRect, cornerRadius: 2)
        
        colorOfLatency.setFill()
        
        if latency <= 200 {
            rectanglePath.fill()
            lineRect.origin.x += dotWidth + dotSpacing
            rectanglePath = UIBezierPath(roundedRect: lineRect, cornerRadius: 2)
            rectanglePath.fill()
            lineRect.origin.x += dotWidth + dotSpacing
            rectanglePath = UIBezierPath(roundedRect: lineRect, cornerRadius: 2)
            rectanglePath.fill()
        } else if latency <= 500 {
            rectanglePath.fill()
            lineRect.origin.x += dotWidth + dotSpacing
            rectanglePath = UIBezierPath(roundedRect: lineRect, cornerRadius: 2)
        }

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
        
        // TODO: Display a more vivid selection mark
        if selected && VPNManager.sharedManager.status == .Connected {
            flagImageView.alpha = 1.0
        } else {
            flagImageView.alpha = 0.6
        }
        
        latencyLabel.text = ""
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
