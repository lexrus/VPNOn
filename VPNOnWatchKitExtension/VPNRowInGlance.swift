//
//  VPNRowInGlance.swift
//  VPNOn
//
//  Created by Lex Tang on 3/31/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import WatchKit
import Foundation

class VPNRowInGlance: VPNRow
{
    @IBOutlet weak var titleLabel: WKInterfaceLabel!
   
    @IBOutlet weak var latencyLabel: WKInterfaceLabel!
    
    override var latency: Int {
        didSet {
            if let label = self.latencyLabel {
                label.setAttributedText(latencyAttributedString)
            }
        }
    }
    
    override init() {
        super.init()
        latency = -1
    }
}
