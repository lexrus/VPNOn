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
            return UIView.userInterfaceLayoutDirectionForSemanticContentAttribute(semanticContentAttribute) == .RightToLeft
        } else {
            return UIApplication.sharedApplication().userInterfaceLayoutDirection == .RightToLeft
        }
    }

}
