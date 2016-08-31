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

private let ConnectedColor = UIColor(red: 0, green: 0.75, blue: 1, alpha: 1)

final class VPNCell: UICollectionViewCell {
    
    @IBOutlet weak var switchIndicator: UIActivityIndicatorView!
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var latencyLabel: UILabel!
    
    override func didMoveToSuperview() {
        switchButton.onTintColor = ConnectedColor
        switchButton.tintColor = UIColor(white: 1.0, alpha: 0.2)
        switchButton.thumbTintColor = UIColor.white
        latencyLabel.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 11)
        titleLabel.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 11)
    }
    
    var current: Bool = false
    
    var latency: Int = -1 {
        didSet {
            if latency == -1 {
                latencyLabel.text = ""
            } else {
                latencyLabel.text = "\(latency)"
            }
            switchButton.tintColor = colorOfLatency
            latencyLabel.textColor = colorOfLatency

            if status == .connected {
                titleLabel.textColor = ConnectedColor
            } else {
                titleLabel.textColor = colorOfLatency
            }
        }
    }
    
    var colorOfLatency: UIColor {
        var latencyColor = UIColor(red: 0.5, green: 0.8, blue: 0.19, alpha: 1)
        
        if latency > 600 {
            latencyColor = UIColor(red: 1, green: 0.11, blue: 0.34, alpha: 1)
        } else if latency > 300 {
            latencyColor = UIColor(red: 0.8184, green: 0.5066, blue: 0.0, alpha: 1)
        } else if latency == -1 {
            latencyColor = UIColor(white: 0.8, alpha: 0.4)
        }
        
        return latencyColor
    }
    
    var status: NEVPNStatus = .disconnected {
        didSet {
            animateFlagAndSwitchByStatus()
        }
    }
    
    func configureWithVPN(_ vpn: VPN,  selected: Bool = false) {
        current = selected
        titleLabel.text = vpn.title
        switchIndicator.stopAnimating()
        
        if let countryCode = vpn.countryCode {
            flagImageView.image = UIImage(
                flagImageWithCountryCode: countryCode.uppercased()
            )
        } else {
            flagImageView.image = UIImage(flagImageForSpecialFlag: .World)
        }

        if VPNManager.sharedManager.status == .connected
            || VPNManager.sharedManager.status == .connecting
        {
            flagImageView.alpha = current ? 1.0 : 0.4
        } else {
            flagImageView.alpha = 1.0
        }
    }
    
    func animateFlagAndSwitchByStatus() {
        flagImageView.layer.removeAllAnimations()
        latencyLabel.alpha = 1.0
        
        if !current {
            switchButton.setOn(false, animated: false)
        } else if status == .connecting {
            latencyLabel.alpha = 0
            switchIndicator.isHidden = false
            switchIndicator.startAnimating()
            switchButton.setOn(true, animated: true)
        } else {
            switchIndicator.stopAnimating()
            switchIndicator.isHidden = true
            if status == .connected {
                latencyLabel.alpha = 0
                switchButton.setOn(true, animated: false)
            } else {
                latencyLabel.alpha = 1
                switchButton.setOn(false, animated: false)
            }
        }
    }
}
