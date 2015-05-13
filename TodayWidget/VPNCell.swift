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
    
    @IBOutlet weak var switchIndicator: UIActivityIndicatorView!
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var latencyLabel: UILabel!
    
    override func didMoveToSuperview() {
        switchButton.onTintColor = UIColor(red: 0, green: 0.75, blue: 1, alpha: 1)
        switchButton.tintColor = UIColor(white: 1.0, alpha: 0.05)
        flagImageView.layer.masksToBounds = true
        flagImageView.layer.cornerRadius = 5
        titleLabel.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 12)
        latencyLabel.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 10)
    }
    
    var current: Bool = false
    
    var latency: Int = -1 {
        didSet {
            latencyLabel.hidden = !flagImageView.hidden
            if latency == -1 {
                latencyLabel.text = "--"
                switchButton.thumbTintColor = UIColor(white: 0.35, alpha: 1.0)
                switchButton.tintColor = UIColor(white: 1.0, alpha: 0.05)
                flagImageView.alpha = 0.2
            } else {
                switchButton.thumbTintColor = UIColor(white: 1.0, alpha: 1.0)
                latencyLabel.text = "\(latency)"
                switchButton.tintColor = colorOfLatency
                flagImageView.alpha = 1.0
            }
            latencyLabel.textColor = colorOfLatency
            setNeedsDisplay()
        }
    }
    
    var colorOfLatency: UIColor {
        get {
            var latencyColor = UIColor(red: 0.5, green: 0.8, blue: 0.19, alpha: 1)
            
            if latency > 200 {
                latencyColor = UIColor(red: 0.92, green: 0.82, blue: 0, alpha: 0.8)
            } else if latency > 500 {
                latencyColor = UIColor(red: 1, green: 0.11, blue: 0.34, alpha: 0.6)
            } else if latency == -1 {
                latencyColor = UIColor(white: 1.0, alpha: 0.08)
            }
            
            return latencyColor
        }
    }
    
    var status: NEVPNStatus = .Disconnected {
        didSet {
            updateTitleColor()
            animateFlagAndSwitchByStatus()
        }
    }
    
    override func drawRect(rect: CGRect) {
        switch VPNManager.sharedManager.status {
        case .Connected, .Connecting:
            return
        default: ()
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
        switchIndicator.stopAnimating()
        switchIndicator.hidden = true
        flagImageView.image = nil

        current = selected
        
        if VPNManager.sharedManager.status == .Connected {
            if selected {
                flagImageView.alpha = 1.0
            } else {
                flagImageView.alpha = 0.4
            }
        } else {
            flagImageView.alpha = 1.0
        }
        
        if VPNManager.sharedManager.displayFlags {
            switchButton.hidden = true
            if let countryCode = vpn.countryCode {
                flagImageView.image = UIImage(named: countryCode)
            } else {
                flagImageView.image = UIImage(named: "unknow")
            }
            flagImageView.hidden = false
        } else {
            switchButton.hidden = false
        }
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
    
    func animateFlagAndSwitchByStatus() {
        flagImageView.layer.removeAllAnimations()
        
        if !current {
            switchButton.setOn(false, animated: false)
        } else if status == .Connecting {
            let bounce = CABasicAnimation(keyPath: "position")
            let endPoint = CGPointMake(flagImageView.layer.position.x, flagImageView.layer.position.y - 6)
            let currentPoint = flagImageView.layer.position
            bounce.duration = 0.3
            bounce.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            bounce.repeatCount = HUGE
            bounce.autoreverses = true
            bounce.fromValue = NSValue(CGPoint: currentPoint)
            bounce.toValue = NSValue(CGPoint: endPoint)
            flagImageView.layer.addAnimation(bounce, forKey: "bounce")
            if !switchButton.hidden {
                switchIndicator.hidden = false
                switchIndicator.startAnimating()
                switchButton.setOn(true, animated: true)
            }
        } else {
            switchIndicator.stopAnimating()
            switchIndicator.hidden = true
            if status == .Connected {
                switchButton.setOn(true, animated: true)
            } else {
                switchButton.setOn(false, animated: true)
            }
        }
    }
}
