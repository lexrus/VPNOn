//
//  VPNDataManager+Selection.swift
//  VPNOn
//
//  Created by Lex Tang on 1/20/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit
import CoreData

let kSelectedVPNIDKey = "lastVPNID"

extension VPNDataManager
{
    var selectedVPNID: NSManagedObjectID? {
        get {
            if let URLData = NSUserDefaults.standardUserDefaults().objectForKey(kSelectedVPNIDKey) as! NSData? {
                let url = NSKeyedUnarchiver.unarchiveObjectWithData(URLData) as! NSURL
                if let ID = self.persistentStoreCoordinator!.managedObjectIDForURIRepresentation(url) {
                    return ID
                }
            }
            
            return .None
        }
        set {
            if let value = newValue {
                let IDURL = value.URIRepresentation()
                let URLData = NSKeyedArchiver.archivedDataWithRootObject(IDURL)
                NSUserDefaults.standardUserDefaults().setObject(URLData, forKey: kSelectedVPNIDKey)
            } else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey(kSelectedVPNIDKey)
            }
        }
    }
}
