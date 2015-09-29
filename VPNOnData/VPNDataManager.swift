//
//  VPNDataManager.swift
//  VPN On
//
//  Created by Lex Tang on 12/5/14.
//  Copyright (c) 2014 LexTang.com. All rights reserved.
//

import UIKit
import CoreData

let kAppGroupIdentifier = "group.VPNOn"

private let VPNDataManagerInstance = VPNDataManager()

class VPNDataManager {
    class var sharedManager : VPNDataManager {
        return VPNDataManagerInstance
    }
    
    // MARK: - Core Data stack
    
    private lazy var _oldDataDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let url = urls[urls.count-1] 
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
        
        let options = NSDictionary(
            objects: [NSNumber(bool: true), NSNumber(bool: true), "WAL"],
            forKeys: [NSMigratePersistentStoresAutomaticallyOption, NSInferMappingModelAutomaticallyOption, "journal_mode"])
        
        if let store = coordinator!.persistentStoreForURL(url) { }
        else {
            do {
                try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options as! [NSObject : AnyObject] as [NSObject : AnyObject])
            } catch let error as NSError {
                coordinator = nil
                NSLog("Unresolved error \(error), \(error.userInfo)")
                exit(1)
            } catch {
                fatalError()
            }
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
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: srcURL, options: options as! [NSObject : AnyObject] as [NSObject : AnyObject])
        } catch let error as NSError {
            srcError = error
            debugPrint("Failed to add src store: \(srcError)")
            return
        }
        
        guard let oldStore = coordinator.persistentStoreForURL(srcURL) else { return }
        do {
            try coordinator.migratePersistentStore(oldStore, toURL: dstURL, options: options as? [NSObject : AnyObject], withType: NSSQLiteStoreType)
            do {
                try NSFileManager.defaultManager().removeItemAtPath(srcURL.path!)
            } catch _ {
            }
        } catch let error as NSError {
            debugPrint("Failed to migrate CoreData: \(error)")
        }
    }
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
}