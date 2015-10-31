//
//  About.swift
//  VPNOn
//
//  Created by Lex Tang on 1/6/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit

class About : UITableViewController {
    
    override func loadView() {
        super.loadView()
        tableView.backgroundView = LTViewControllerBackground()
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String {
            return version
        }
        
        return nil
    }
    
    

}
