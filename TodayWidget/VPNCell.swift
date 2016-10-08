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

final class VPNCell: UICollectionViewCell, VPNFlagAnimatable {

    lazy var flagImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 2
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .clear
        self.addSubview(imageView)
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        self.addSubview(label)
        return label
    }()
    
    var current: Bool = false
    
    var latency: Int = -1 {
        didSet {
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let flagSize = CGSize(width: 46, height: 34)
        flagImageView.frame.size = flagSize
        flagImageView.frame.origin.x = (bounds.width - flagSize.width) / 2
        flagImageView.frame.origin.y = 25
        
        titleLabel.frame = bounds
        titleLabel.frame.size.height = 13
        titleLabel.frame.origin.y = flagImageView.frame.maxY + 6
    }
    
    func configureWithVPN(_ vpn: VPN, selected: Bool = false) {
        current = selected
        titleLabel.text = vpn.title
        
        if let countryCode = vpn.countryCode {
            flagImageView.image = UIImage(flagImageWithCountryCode: countryCode.uppercased())
        } else {
            flagImageView.image = UIImage(flagImageForSpecialFlag: .World)
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
        if !current {
            stopBreathing()
            stopAnimating()
        } else if status == .connecting {
            startAnimating()
        } else {
            if status == .connected {
                startBreathing()
            } else {
                stopBreathing()
                stopAnimating()
            }
        }
    }
}
