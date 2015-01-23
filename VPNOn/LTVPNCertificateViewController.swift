//
//  LTVPNCertificateViewController.swift
//  VPNOn
//
//  Created by Lex on 1/23/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit

class LTVPNCertificateViewController: UITableViewController, UITextViewDelegate {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var certificateTextView: UITextView!
    @IBOutlet weak var deleteCell: UITableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateSaveButton()
    }
    
    // MARK: - Save
    
    @IBAction func save(sender: AnyObject) {
        
    }
    
    func updateSaveButton() {
        saveButton.enabled = !certificateTextView.text!.isEmpty
    }
    
    // MARK: - TextView delegate
    
    func textViewDidEndEditing(textView: UITextView) {
        updateSaveButton()
    }
    
    func textViewDidChange(textView: UITextView) {
        updateSaveButton()
    }
    
}
