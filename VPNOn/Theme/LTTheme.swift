//
//  LTTheme.swift
//  VPNOn
//
//  Created by Lex on 1/15/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit

public protocol LTTheme {
    var navigationBarColor       : UIColor { get set }
    var tintColor                : UIColor { get set }
    var textColor                : UIColor { get set }
    var placeholderColor         : UIColor { get set }
    var textFieldColor           : UIColor { get set }
    var tableViewBackgroundColor : UIColor { get set }
    var tableViewLineColor       : UIColor { get set }
    var tableViewCellColor       : UIColor { get set }
}