//
//  VPNEditor+TextField.swift
//  VPNOn
//
//  Created by Lex on 1/17/15.
//  Copyright (c) 2017 lexrus.com. All rights reserved.
//

import UIKit

extension VPNEditor {

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(UITextInputDelegate.textDidChange(_:)),
            name: NSNotification.Name.UITextFieldTextDidChange,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(VPNEditor.keyboardWillShow(_:)),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(VPNEditor.keyboardWillHide(_:)),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
        case groupTextField:
            remoteIDTextField.becomeFirstResponder()
            break
        default:
            remoteIDTextField.resignFirstResponder()
        }

        return true
    }

    func textDidChange(_ notification: Notification) {
        toggleSaveButtonByStatus()
    }

    func keyboardWillShow(_ notification: Notification) {
        // Add bottom edge inset so that the last cell is visiable

        var bottom: CGFloat = 216
        defer {
            var edgeInsets = self.tableView.contentInset
            edgeInsets.bottom = bottom
            self.tableView.contentInset = edgeInsets
        }

        guard let userInfo = (notification as NSNotification).userInfo else {
            return
        }

        guard let boundsObject = userInfo["UIKeyboardBoundsUserInfoKey"] else {
            return
        }

        bottom = (boundsObject as AnyObject).cgRectValue.height
    }

    func keyboardWillHide(_ notification: Notification) {
        var edgeInsets = self.tableView.contentInset
        edgeInsets.bottom = 0
        self.tableView.contentInset = edgeInsets
    }
    
}
