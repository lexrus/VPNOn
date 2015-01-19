//
//  LTThemeManager.swift
//  VPNOn
//
//  Created by Lex on 1/15/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit

class LTThemeManager
{
    var currentTheme : LTTheme? = .None
    
    class var sharedManager : LTThemeManager
    {
        struct Static
        {
            static let sharedInstance = LTThemeManager()
        }
        
        return Static.sharedInstance
    }
    
    func activateTheme(theme : LTTheme)
    {
        currentTheme = theme
        
        UIWindow.appearance().tintColor = theme.tintColor
        LTViewControllerBackground.appearance().backgroundColor = theme.defaultBackgroundColor
        
        // Switch
        UISwitch.appearance().tintColor = theme.switchBorderColor
        UISwitch.appearance().onTintColor = theme.tintColor
        UISwitch.appearance().thumbTintColor = theme.switchBorderColor
        
        // Navigation
        UINavigationBar.appearance().barTintColor = theme.navigationBarColor
        UINavigationBar.appearance().tintColor = theme.tintColor
        UINavigationBar.appearance().backgroundColor = UIColor.clearColor()
        UINavigationBar.appearance().titleTextAttributes = NSDictionary(objects: [theme.textColor], forKeys: [NSForegroundColorAttributeName])
        
        // TableView
        UITableView.appearance().backgroundColor = theme.tableViewBackgroundColor
        UITableView.appearance().separatorColor = theme.tableViewLineColor
        UITableViewCell.appearance().backgroundColor = theme.tableViewCellColor
        UITableViewCell.appearance().tintColor = theme.tintColor
        UITableViewCell.appearance().selectionStyle = UITableViewCellSelectionStyle.None
        UILabel.lt_appearanceWhenContainedIn(UITableViewHeaderFooterView.self).textColor = theme.textColor
        LTTableViewCellTitle.appearance().textColor = theme.textColor
        
        // TextField
        UITextField.appearance().tintColor = theme.tintColor
        UITextField.appearance().textColor = theme.textFieldColor
        UILabel.lt_appearanceWhenContainedIn(LTVPNTableViewCell.self).textColor = theme.textColor
        
    }
}
