//
//  VPNDataManager+Selection.swift
//  VPNOn
//
//  Created by Lex Tang on 1/20/15.
//  Copyright (c) 2016 lexrus.com. All rights reserved.
//

import UIKit
import CoreData

private let kSelectedVPNIDKey = "lastVPNID"

extension VPNDataManager {

    var selectedVPNID: NSManagedObjectID? {
        get {
            if let URLData = UserDefaults.standard.object(forKey: kSelectedVPNIDKey) as! Data? {
                let url = NSKeyedUnarchiver.unarchiveObject(with: URLData) as! URL
                if let ID = self.persistentStoreCoordinator!.managedObjectID(forURIRepresentation: url) {
                    return ID
                }
            }
            
            return .none
        }
        set {
            if let value = newValue {
                let IDURL = value.uriRepresentation()
                let URLData = NSKeyedArchiver.archivedData(withRootObject: IDURL)
                UserDefaults.standard.set(URLData, forKey: kSelectedVPNIDKey)
            } else {
                UserDefaults.standard.removeObject(forKey: kSelectedVPNIDKey)
            }
        }
    }
}
