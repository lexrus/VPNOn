//
//  LTVPNCreateViewController.swift
//  VPN On
//
//  Created by Lex Tang on 12/4/14.
//  Copyright (c) 2014 LexTang.com. All rights reserved.
//

import UIKit
import CoreData

let kLTVPNDidCreate = "kLTVPNDidCreate"

class LTVPNCreateViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var serverTextField: UITextField!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var groupTextField: UITextField!
    @IBOutlet weak var secretTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBAction func createVPN(sender: AnyObject) {
        let success = VPNDataManager.sharedManager.createVPN(
            titleTextField.text,
            server: serverTextField.text,
            account: accountTextField.text,
            password: passwordTextField.text,
            group: groupTextField.text,
            secret: secretTextField.text)
        
        if success {
            NSNotificationCenter.defaultCenter().postNotificationName(kLTVPNDidCreate, object: self)
        }
    }
    
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
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(
            self, name: UITextFieldTextDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(
            self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(
            self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        saveButton?.enabled = false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        switch textField {
        case titleTextField:
            serverTextField.becomeFirstResponder()
            break
        case serverTextField:
            accountTextField.becomeFirstResponder()
            break
        case accountTextField:
            groupTextField.becomeFirstResponder()
            break
        case groupTextField:
            passwordTextField.becomeFirstResponder()
            break
        case passwordTextField:
            secretTextField.becomeFirstResponder()
            break
        default:
            secretTextField.resignFirstResponder()
        }
        
        return true
    }
    
    func textDidChange(notification: NSNotification) {
        if self.titleTextField.text.isEmpty
            || self.accountTextField.text.isEmpty
            || self.serverTextField.text.isEmpty {
                self.saveButton.enabled = false
        } else {
            self.saveButton.enabled = true
        }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
