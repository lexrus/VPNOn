//
//  VPNDataManager.swift
//  VPN On
//
//  Created by Lex Tang on 12/5/14.
//  Copyright (c) 2014 LexTang.com. All rights reserved.
//

import UIKit
import CoreData

let kLastVPNIDKey = "lastVPNID"
let kAppGroupIdentifier = "group.VPNOn"

class VPNDataManager
{
    class var sharedManager : VPNDataManager
    {
        struct Static
        {
            static let sharedInstance = VPNDataManager()
        }
        
        return Static.sharedInstance
    }
    
    var lastVPNID: NSManagedObjectID? {
        get {
            if let URLData = NSUserDefaults.standardUserDefaults().objectForKey(kLastVPNIDKey) as NSData? {
                let url = NSKeyedUnarchiver.unarchiveObjectWithData(URLData) as NSURL
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
                NSUserDefaults.standardUserDefaults().setObject(URLData, forKey: kLastVPNIDKey)
            } else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey(kLastVPNIDKey)
            }
        }
    }
    
    // MARK: - Core Data stack
    
    private lazy var _oldDataDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let url = urls[urls.count-1] as NSURL
        return url
    }()
    
    lazy var dataDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.LexTang.VPNOn" in the application's documents Application Support directory.
            return NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(kAppGroupIdentifier)!
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("VPNOn", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        self.migrateToVersion2(coordinator!)
        
        let url = self.dataDirectory.URLByAppendingPathComponent("VPNOn.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        
        var error: NSError? = nil
        if let store = coordinator!.persistentStoreForURL(url) { }
        else if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Migration
    
    func migrateToVersion2(coordinator: NSPersistentStoreCoordinator) {
        let srcURL = self._oldDataDirectory.URLByAppendingPathComponent("VPNOn.sqlite")
        let dstURL = self.dataDirectory.URLByAppendingPathComponent("VPNOn.sqlite")
        
        if !NSFileManager.defaultManager().fileExistsAtPath(srcURL.path!) {
            return
        }
        
        if NSFileManager.defaultManager().fileExistsAtPath(dstURL.path!) {
            return
        }
        
        let options = NSDictionary(
            objects: [NSNumber(bool: true), NSNumber(bool: true), "WAL"],
            forKeys: [NSMigratePersistentStoresAutomaticallyOption, NSInferMappingModelAutomaticallyOption, "journal_mode"])
        
        var srcError: NSError?
        if coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: srcURL, options: options, error: &srcError) == nil {
            println("Failed to add src store: \(srcError)")
            return
        }
        
        if let oldStore = coordinator.persistentStoreForURL(srcURL) {
            var migrationError: NSError?
            if coordinator.migratePersistentStore(oldStore, toURL: dstURL, options: options, withType: NSSQLiteStoreType, error: &migrationError) == nil {
                println("Failed to migrate CoreData: \(migrationError)")
            } else {
                if NSFileManager.defaultManager().removeItemAtPath(srcURL.path!, error: nil) {
                    println("CoreData migration complete.")
                }
            }
        }
    }
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
    
    // MARK: - Move data file to shared container if needed
    
    func shareCoreData () {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let url = urls[urls.count-1] as NSURL
        let oldDataURL = dataDirectory.URLByAppendingPathComponent("VPNOn.sqlite")
        if let oldDataPath = oldDataURL.path {
            if NSFileManager.defaultManager().fileExistsAtPath(oldDataPath) {
                var error: NSError?
                let newDataURL = dataDirectory.URLByAppendingPathComponent("VPNOn.sqlite")
                NSFileManager.defaultManager().moveItemAtURL(oldDataURL, toURL: newDataURL, error: &error)
                if let err = error {
                    println("\(err)")
                }
            }
        }
    }
}