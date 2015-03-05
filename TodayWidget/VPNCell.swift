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

class VPNCell: UICollectionViewCell {
    
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
//    var typeTag: VPNTypeTag {
//        get {
//            if tagLabel.subviews.first == nil {
//                let effect = UIVibrancyEffect()
//                let tagEffectView = UIVisualEffectView(effect: UIVibrancyEffect.notificationCenterVibrancyEffect())
//                tagEffectView.frame = tagLabel.bounds
//                let tagView = VPNTypeTag(frame: tagEffectView.bounds)
//                tagLabel.addSubview(tagEffectView)
//                tagEffectView.contentView.addSubview(tagView)
//            }
//            return tagLabel.subviews.first!.contentView.subviews.first! as VPNTypeTag
//        }
//    }
    
    var status: NEVPNStatus = .Disconnected {
        didSet {
            flagImageView.transform = CGAffineTransformIdentity
            switch status {
            case .Connected:
                titleLabel.textColor = UIColor.greenColor()
                break
            case .Connecting:
                titleLabel.textColor = UIColor.yellowColor()
                break
            default:
                titleLabel.textColor = UIColor(white: 1.0, alpha: 0.5)
            }
        }
    }
    
    func configureWithVPN(vpn: VPN, selected: Bool = false) {
        titleLabel.text = vpn.title
        
        if let countryCode = vpn.countryCode {
            flagImageView.image = UIImage(named: countryCode)
        }
        
        // TODO: Display a more vivid selection mark
        if selected && status == .Connected {
            flagImageView.transform = CGAffineTransformMakeScale(1.1, 1.1)
        } else {
            flagImageView.transform = CGAffineTransformMakeScale(0.9, 0.9)
        }
    }
}
