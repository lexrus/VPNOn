//
//  VPNCell.swift
//  VPNOn
//
//  Created by Lex Tang on 3/5/15.
//  Copyright (c) 2016 lexrus.com. All rights reserved.
//

import UIKit
import VPNOnKit
import NetworkExtension
import QuartzCore
import FlagKit

private let ConnectedColor = UIColor(red: 0, green: 0.7, blue: 1, alpha: 1)

final class VPNCell: UICollectionViewCell {
    
    @IBOutlet weak var switchIndicator: UIActivityIndicatorView!
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func didMoveToSuperview() {
        switchButton.onTintColor = ConnectedColor
        switchButton.tintColor = UIColor(white: 1, alpha: 0.2)
        switchButton.thumbTintColor = UIColor.white
    }
    
    var current: Bool = false
    
    var latency: Int = -1 {
        didSet {
            switchButton.tintColor = colorOfLatency
            if status == .connected {
                titleLabel.textColor = ConnectedColor
            } else {
                titleLabel.textColor = textColor
            }
        }
    }
    
    var colorOfLatency: UIColor {
        var latencyColor = UIColor(red: 0.2, green: 0.7, blue: 0, alpha: 1)
        
        if latency > 600 {
            latencyColor = UIColor(red: 1, green: 0.1, blue: 0.3, alpha: 1)
        } else if latency > 300 {
            latencyColor = UIColor(red: 0.8, green: 0.5, blue: 0, alpha: 1)
        } else if latency == -1 {
            latencyColor = UIColor(white: 0.6, alpha: 1)
        }
        
        return latencyColor
    }
    
    private var textColor: UIColor {
        if ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 10 {
            return UIColor.black
        } else {
            return UIColor.white
        }
    }
    
    var status: NEVPNStatus = .disconnected {
        didSet {
            animateFlagAndSwitchByStatus()
        }
    }
    
    func configureWithVPN(_ vpn: VPN, selected: Bool = false) {
        current = selected
        titleLabel.text = vpn.title
        switchIndicator.stopAnimating()
        
        if let countryCode = vpn.countryCode {
            flagImageView.image = UIImage(flagImageWith: countryCode.uppercased())
        } else {
            flagImageView.image = UIImage(flagImageFor: .world)
        }

        if VPNManager.sharedManager.status == .connected
            || VPNManager.sharedManager.status == .connecting
        {
            flagImageView.alpha = current ? 1 : 0.4
        } else {
            flagImageView.alpha = 1
        }
    }
    
    private func animateFlagAndSwitchByStatus() {
        flagImageView.layer.removeAllAnimations()
        
        if !current {
            switchButton.setOn(false, animated: false)
        } else if status == .connecting {
            switchIndicator.isHidden = false
            switchIndicator.startAnimating()
            if !switchButton.isOn {
                switchButton.setOn(true, animated: true)
            }
        } else {
            switchIndicator.stopAnimating()
            switchIndicator.isHidden = true
            if status == .connected {
                if !switchButton.isOn {
                    switchButton.setOn(true, animated: false)
                }
            } else {
                switchButton.setOn(false, animated: false)
            }
        }
    }
}
