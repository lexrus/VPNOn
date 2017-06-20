//
//  VPNDataManager.swift
//  VPN On
//
//  Created by Lex Tang on 12/5/14.
//  Copyright (c) 2017 lexrus.com. All rights reserved.
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
    
    fileprivate lazy var _oldDataDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let url = urls[urls.count-1] 
        return url
        }()
    
    lazy var dataDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.LexTang.VPNOn" in the application's documents Application Support directory.
            return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: kAppGroupIdentifier)!
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "VPNOn", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        self.migrateToVersion2(coordinator!)
        
        let url = self.dataDirectory.appendingPathComponent("VPNOn.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        
        let options = [
            NSMigratePersistentStoresAutomaticallyOption: NSNumber(value: true),
            NSInferMappingModelAutomaticallyOption: NSNumber(value: true),
            "journal_mode": "WAL"
        ] as [String : Any]
        
        if coordinator!.persistentStore(for: url) != nil {

        } else {
            do {
                try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
            } catch {
                coordinator = nil
                print("Unresolved error \(error)")
                exit(1)
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
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Migration
    
    func migrateToVersion2(_ coordinator: NSPersistentStoreCoordinator) {
        let srcURL = self._oldDataDirectory.appendingPathComponent("VPNOn.sqlite")
        let dstURL = self.dataDirectory.appendingPathComponent("VPNOn.sqlite")
        
        if !FileManager.default.fileExists(atPath: srcURL.path) {
            return
        }
        
        if FileManager.default.fileExists(atPath: dstURL.path) {
            return
        }
        
        let options = NSDictionary(
            objects: [NSNumber(value: true), NSNumber(value: true), "WAL"],
            forKeys: [NSMigratePersistentStoresAutomaticallyOption as NSCopying, NSInferMappingModelAutomaticallyOption as NSCopying, "journal_mode" as NSCopying])

        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: srcURL, options: options as [NSObject : AnyObject] as [NSObject : AnyObject])
        } catch {
            print("Failed to add src store: \(error)")
            return
        }
        
        guard let oldStore = coordinator.persistentStore(for: srcURL) else { return }
        do {
            try coordinator.migratePersistentStore(oldStore, to: dstURL, options: options as? [AnyHashable : AnyObject], withType: NSSQLiteStoreType)
            do {
                try FileManager.default.removeItem(atPath: srcURL.path)
            } catch _ {
            }
        } catch let error as NSError {
            debugPrint("Failed to migrate CoreData: \(error)")
        }
    }
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        guard let moc = self.managedObjectContext else { return }
        if !moc.hasChanges {
            return
        }
        do {
            try moc.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            print("Unresolved error \(error)")
            abort()
        }
    }
}
