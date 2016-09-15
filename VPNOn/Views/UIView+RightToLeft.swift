//
//  UIView+RightToLeft.swift
//  VPNOn
//
//  Created by Lex on 5/20/16.
//  Copyright © 2016 lexrus.com. All rights reserved.
//

import UIKit

extension UIView {

    var isRightToLeft: Bool {
        if #available(iOS 9.0, *) {
            return UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft
        } else {
            return UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft
        }
    }

}
