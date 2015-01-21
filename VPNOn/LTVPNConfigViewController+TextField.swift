//
//  LTVPNConfigViewController+TextField.swift
//  VPNOn
//
//  Created by Lex on 1/17/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit

extension LTVPNConfigViewController
{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("textDidChange:"),
            name: UITextFieldTextDidChangeNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("keyboardWillShow:"),
            name: UIKeyboardWillShowNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("keyboardWillHide:"),
            name: UIKeyboardWillHideNotification,
            object: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case titleTextField:
            serverTextField.becomeFirstResponder()
            break
        case serverTextField:
            accountTextField.becomeFirstResponder()
            break
        case accountTextField:
            passwordTextField.becomeFirstResponder()
            break
        case passwordTextField:
            secretTextField.becomeFirstResponder()
            break
        case secretTextField:
            groupTextField.becomeFirstResponder()
            break
        default:
            groupTextField.resignFirstResponder()
        }
        
        return true
    }
    
    func textDidChange(notification: NSNotification) {
        toggleSaveButtonByStatus()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        // Add bottom edge inset so that the last cell is visiable
        
        var bottom: CGFloat = 216
        if let userInfo: NSDictionary = notification.userInfo {
            if let boundsObject: AnyObject = userInfo.valueForKey("UIKeyboardBoundsUserInfoKey") {
                let bounds = boundsObject.CGRectValue()
                bottom = bounds.size.height
            }
        }
        
        var edgeInsets = self.tableView.contentInset
        edgeInsets.bottom = bottom
        self.tableView.contentInset = edgeInsets
    }
    
    func keyboardWillHide(notification: NSNotification) {
        var edgeInsets = self.tableView.contentInset
        edgeInsets.bottom = 0
        self.tableView.contentInset = edgeInsets
    }
}
