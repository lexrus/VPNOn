//
//  VPNDataManager+VPN.swift
//  VPN On
//
//  Created by Lex Tang on 12/5/14.
//  Copyright (c) 2014 lexrus.com. All rights reserved.
//

import CoreData
import VPNOnKit

extension VPNDataManager {

    func allVPN() -> [VPN] {
        var vpns = [VPN]()
        
        let request = NSFetchRequest(entityName: "VPN")
        let sortByTitle = NSSortDescriptor(key: "title", ascending: true)
        let sortByServer = NSSortDescriptor(key: "server", ascending: true)
        let sortByType = NSSortDescriptor(key: "ikev2", ascending: false)
        request.sortDescriptors = [sortByTitle, sortByServer, sortByType]
        
        if let moc = managedObjectContext, results = (try? moc.executeFetchRequest(request)) as? [VPN] {
            results.forEach {
                if !$0.deleted {
                    vpns.append($0)
                }
            }
        }
        return vpns
    }
    
    func createVPN(
        title: String,
        server: String,
        account: String,
        password: String,
        group: String,
        secret: String,
        alwaysOn: Bool = true,
        ikev2: Bool = false
        ) -> VPN?
    {
        guard let entity = NSEntityDescription.entityForName("VPN", inManagedObjectContext: managedObjectContext!) else {
            debugPrint("No entity.")
            return nil
        }
        guard let vpn = NSManagedObject(entity: entity, insertIntoManagedObjectContext: managedObjectContext!) as? VPN else {
            debugPrint("Failed to insert")
            return nil
        }
        
        vpn.title = title
        vpn.server = server
        vpn.account = account
        vpn.group = group
        vpn.alwaysOn = alwaysOn
        vpn.ikev2 = ikev2
        
        do {
            try managedObjectContext!.save()
            saveContext()
            
            if !vpn.objectID.temporaryID {
                Keychain.setPassword(password, forVPNID: vpn.ID)
                Keychain.setSecret(secret, forVPNID: vpn.ID)
                
                if allVPN().count == 1 {
                    VPNManager.sharedManager.activatedVPNID = vpn.ID
                }
                return vpn
            }
        } catch let error as NSError {
            debugPrint("Could not save VPN \(error), \(error.userInfo)")
        }
        
        return .None
    }
    
    func deleteVPN(vpn:VPN) {
        let ID = "\(vpn.ID)"
        
        Keychain.destoryKeyForVPNID(ID)
        managedObjectContext!.deleteObject(vpn)
        
        do {
            try managedObjectContext!.save()
        } catch { }
        saveContext()
        
        if VPNManager.sharedManager.activatedVPNID == ID {
            VPNManager.sharedManager.activatedVPNID = nil
            
            let vpns = allVPN()
            
            if let firstVPN = vpns.first {
                VPNManager.sharedManager.activatedVPNID = firstVPN.ID
            }
        }
    }
    
    func VPNByID(ID: NSManagedObjectID) -> VPN? {
        var error: NSError?
        if ID.temporaryID {
            return .None
        }
        
        var result: NSManagedObject?
        do {
            result = try managedObjectContext?.existingObjectWithID(ID)
        } catch let error1 as NSError {
            error = error1
            result = nil
        }
        if let vpn = result {
            if !vpn.deleted {
                managedObjectContext?.refreshObject(vpn, mergeChanges: true)
                return vpn as? VPN
            }
        } else {
            debugPrint("Fetch error: \(error)")
            return .None
        }
        return .None
    }
    
    func VPNByIDString(ID: String) -> VPN? {
        guard let URL = NSURL(string: ID) else { return nil }
        if URL.scheme.lowercaseString == "x-coredata" {
            if let moid = persistentStoreCoordinator!.managedObjectIDForURIRepresentation(URL) {
                return VPNByID(moid)
            }
        }
        return nil
    }
    
    func VPNByPredicate(predicate: NSPredicate) -> [VPN] {
        var vpns = [VPN]()
        let request = NSFetchRequest(entityName: "VPN")
        request.predicate = predicate
        
        guard let results = try? managedObjectContext!.executeFetchRequest(request) as! [VPN] else { return vpns }
        
        results.filter { !$0.deleted }.forEach { vpns.append($0) }
        
        return vpns
    }
    
    func VPNBeginsWithTitle(title: String) -> [VPN] {
        let titleBeginsWithPredicate = NSPredicate(format: "title beginswith[cd] %@", argumentArray: [title])
        return VPNByPredicate(titleBeginsWithPredicate)
    }
    
    func VPNHasTitle(title: String) -> [VPN] {
        let titleBeginsWithPredicate = NSPredicate(format: "title == %@", argumentArray: [title])
        return VPNByPredicate(titleBeginsWithPredicate)
    }
    
    func duplicate(vpn: VPN) -> VPN? {
        let duplicatedVPNs = VPNDataManager.sharedManager.VPNBeginsWithTitle(vpn.title)
        if duplicatedVPNs.count > 0 {
            let newTitle = "\(vpn.title) \(duplicatedVPNs.count)"
            
            Keychain.passwordForVPNID(vpn.ID)

            if let newVPN = createVPN(
                newTitle,
                server: vpn.server,
                account: vpn.account,
                password: Keychain.passwordStringForVPNID(vpn.ID) ?? "",
                group: vpn.group,
                secret: Keychain.secretStringForVPNID(vpn.ID) ?? "",
                alwaysOn: vpn.alwaysOn,
                ikev2: vpn.ikev2
                ) {
                    if let password = Keychain.passwordStringForVPNID(vpn.ID) {
                        Keychain.setPassword(password, forVPNID: newVPN.ID)
                    }
                    if let secret = Keychain.secretStringForVPNID(vpn.ID) {
                        Keychain.setSecret(secret, forVPNID: newVPN.ID)
                    }

                    return newVPN
            }
        }
        
        return nil
    }
}
