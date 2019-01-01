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
            name: UITextField.textDidChangeNotification,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(VPNEditor.keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(VPNEditor.keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case titleTextField:
            serverTextField.becomeFirstResponder()

        case serverTextField:
            accountTextField.becomeFirstResponder()

        case accountTextField:
            passwordTextField.becomeFirstResponder()

        case passwordTextField:
            secretTextField.becomeFirstResponder()

        case secretTextField:
            groupTextField.becomeFirstResponder()

        case groupTextField:
            remoteIDTextField.becomeFirstResponder()

        default:
            remoteIDTextField.resignFirstResponder()
        }

        return true
    }

    func textDidChange(_ notification: Notification) {
        toggleSaveButtonByStatus()
    }

    @objc func keyboardWillShow(_ notification: Notification) {
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

    @objc func keyboardWillHide(_ notification: Notification) {
        var edgeInsets = self.tableView.contentInset
        edgeInsets.bottom = 0
        self.tableView.contentInset = edgeInsets
    }
    
}
