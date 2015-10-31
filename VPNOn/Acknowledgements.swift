//
//  Acknowledgements.swift
//  VPNOn
//
//  Created by Lex on 10/31/15.
//  Copyright © 2015 LexTang.com. All rights reserved.
//

import UIKit

class Acknowledgements : UITableViewController {
    
    var acknowledgements: [NSDictionary]? {
        didSet { tableView.reloadData() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        
        guard let plistURL = NSBundle.mainBundle().URLForResource("Acknowledgements", withExtension: "plist") else {
            assert(true, "Failed to load Acknowledgements.plist")
            return
        }
        
        if let array = NSArray(contentsOfURL: plistURL) as? [NSDictionary] {
            acknowledgements = array
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return acknowledgements?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.acknowledgementCell, forIndexPath: indexPath)!
        let acknowledgement = acknowledgements![indexPath.section]
        
        cell.titleLabel.text = acknowledgement.objectForKey("title") as? String
        cell.contentLabel.text = acknowledgement.objectForKey("text") as? String
        
        return cell
    }
    
}
