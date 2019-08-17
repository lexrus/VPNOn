//
//  About.swift
//  VPNOn
//
//  Created by Lex Tang on 1/6/15.
//  Copyright (c) 2017 lexrus.com. All rights reserved.
//

import UIKit

private let kReviewCellIndex = 1

class About : UITableViewController {
    
    override func loadView() {
        super.loadView()
        tableView.backgroundView = LTViewControllerBackground()
    }
    
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
        ) -> Int {
        return 2
    }
    
    override func tableView(
        _ tableView: UITableView,
        titleForFooterInSection section: Int
        ) -> String? {
        return appVersion()
    }
    
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
        ) {
        switch (indexPath as NSIndexPath).row {
        case kReviewCellIndex:
            presentAppStore()

        default:
            ()
        }
    }
    
    fileprivate func appVersion() -> String {
        if let version = Bundle.main
            .object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
                return version
        }
        return ""
    }
    
    // MARK: - Review
    
    func presentAppStore() {
        let appStoreURL =
            URL(string: "https://itunes.apple.com/app/vpn-on/id951344279")!
        UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
    }

}
