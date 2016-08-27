//
//  LTThemeManager.swift
//  VPNOn
//
//  Created by Lex on 1/15/15.
//  Copyright (c) 2016 lexrus.com. All rights reserved.
//

import UIKit

let kCurrentThemeIndexKey = "CurrentThemeIndex"

class LTThemeManager
{
    var currentTheme : LTTheme? = .None
    
    let themes: [LTTheme] = [LTDarkTheme(), LTLightTheme(), LTHelloKittyTheme(), LTDarkGreenTheme(), LTDarkPurpleTheme()]
    
    class var sharedManager : LTThemeManager
    {
        struct Static
        {
            static let sharedInstance = LTThemeManager()
        }
        
        return Static.sharedInstance
    }
    
    var themeIndex: Int {
        get {
            if let index = NSUserDefaults.standardUserDefaults().objectForKey(kCurrentThemeIndexKey) as? NSNumber {
                if index.isKindOfClass(NSNumber.self) {
                    return min(themes.count - 1, index.integerValue ?? 0)
                }
            }
            return 0
        }
        set {
            let newNumber = NSNumber(integer: newValue)
            NSUserDefaults.standardUserDefaults().setObject(newNumber, forKey: kCurrentThemeIndexKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func activateTheme() {
        activateTheme(themes[themeIndex])
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
        UINavigationBar.appearance().titleTextAttributes = NSDictionary(objects: [theme.textColor], forKeys: [NSForegroundColorAttributeName]) as? [String : AnyObject]
        
        // TableView
        UITableView.appearance().backgroundColor = theme.tableViewBackgroundColor
        UITableView.appearance().separatorColor = theme.tableViewLineColor
        UITableViewCell.appearance().backgroundColor = theme.tableViewCellColor
        UITableViewCell.appearance().tintColor = theme.tintColor
        UITableViewCell.appearance().selectionStyle = UITableViewCellSelectionStyle.None
        UILabel.lt_appearanceWhenContainedIn(UITableViewHeaderFooterView.self).textColor = theme.textColor
        LTTableViewCellTitle.appearance().textColor = theme.textColor
        UILabel.lt_appearanceWhenContainedIn(LTTableViewActionCell.self).textColor = theme.tintColor
        UILabel.lt_appearanceWhenContainedIn(VPNTableViewCell.self).textColor = theme.textColor
        UILabel.lt_appearanceWhenContainedIn(NormalTableViewCell.self).textColor = theme.textColor
        UILabel.lt_appearanceWhenContainedIn(AcknowledgementCell.self).textColor = theme.textColor
        UITextView.lt_appearanceWhenContainedIn(UITableViewCell.self).backgroundColor = theme.tableViewCellColor
        UITextView.lt_appearanceWhenContainedIn(UITableViewCell.self).textColor = theme.textColor
        
        // TextField
        UITextField.appearance().tintColor = theme.tintColor
        UITextField.appearance().textColor = theme.textFieldColor
        
    }
    
    func activateNextTheme()
    {
        var index = themeIndex
        index += 1
        
        if index >= themes.count {
            themeIndex = 0
        } else {
            themeIndex = index
        }
        
        activateTheme(themes[themeIndex])
        
        let windows = UIApplication.sharedApplication().windows
        
        for window in windows {
            for view in window.subviews {
                view.removeFromSuperview()
                window.addSubview(view )
            }
        }
    }
}
