//
//  Acknowledgements.swift
//  VPNOn
//
//  Created by Lex on 10/31/15.
//  Copyright © 2016 lexrus.com. All rights reserved.
//

import UIKit

class Acknowledgements : UITableViewController {
    
    var acknowledgements: [NSDictionary]? {
        didSet { tableView.reloadData() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundView = LTViewControllerBackground()
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        
        guard let plistURL = Bundle.main.url(
            forResource: "Acknowledgements",
            withExtension: "plist"
            ) else {
                assert(true, "Failed to load Acknowledgements.plist")
                return
        }
        
        if let array = NSArray(contentsOf: plistURL) as? [NSDictionary] {
            acknowledgements = array
        }
    }
    
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
        ) -> Int {
            return 1
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return acknowledgements?.count ?? 0
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
        ) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "AcknowledgementCell",
                for: indexPath
                ) as! AcknowledgementCell
            let acknowledgement = acknowledgements![(indexPath as NSIndexPath).section]
            
            cell.titleLabel.text
                = acknowledgement.object(forKey: "title") as? String
            cell.contentLabel.text
                = acknowledgement.object(forKey: "text") as? String
            
            return cell
    }
    
}
