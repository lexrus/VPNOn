//
//  VPNDataManager+VPN.swift
//  VPN On
//
//  Created by Lex Tang on 12/5/14.
//  Copyright (c) 2014 LexTang.com. All rights reserved.
//

import CoreData
import VPNOnKit

extension VPNDataManager
{
    func allVPN() -> [VPN]
    {
        var vpns = [VPN]()
        
        var request = NSFetchRequest(entityName: "VPN")
        var error: NSError?
        let fetchResults = self.managedObjectContext!.executeFetchRequest(request, error: &error) as [VPN]?
        
        if let results = fetchResults {
            vpns = results
        } else {
            println("cannot fetch vpns. \(error?.localizedDescription)")
        }
        
        return vpns
    }
    
    func createVPN(title: String, server: String, account: String, password: String, group: String, secret: String, alwaysOn: Bool = true) -> Bool
    {
        let entity = NSEntityDescription.entityForName("VPN", inManagedObjectContext: self.managedObjectContext!)
        let vpn = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: self.managedObjectContext!) as VPN
        
        vpn.title = title
        vpn.server = server
        vpn.account = account
        vpn.group = group
        vpn.alwaysOn = alwaysOn
        
        var error: NSError?
        if !self.managedObjectContext!.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
            return false
        } else {
            self.saveContext()
            
            if !vpn.objectID.temporaryID {
                VPNKeychainWrapper.setPassword(password, forVPNID: vpn.ID)
                VPNKeychainWrapper.setSecret(secret, forVPNID: vpn.ID)
                
                if allVPN().count == 0 {
                    VPNManager.sharedManager().activatedVPNID = vpn.ID
                }
            }
            return true
        }
    }
    
    func deleteVPN(vpn:VPN) -> Bool
    {
        let objectID = vpn.objectID
        managedObjectContext?.deleteObject(vpn)
        if let vpn = managedObjectContext?.existingObjectWithID(objectID, error: nil) {
            return false
        }
        saveContext()
        return true
    }
    
    func VPNByID(ID: NSManagedObjectID) -> VPN?
    {
        var error: NSError?
        var result = self.managedObjectContext?.existingObjectWithID(ID, error: &error) as VPN?
        if let vpn = result {
            return vpn
        } else {
            println("Fetch error: \(error)")
            return .None
        }
    }
    
    func VPNByIDString(ID: String) -> VPN?
    {
        if let URL = NSURL(string: ID) {
            if let scheme = URL.scheme {
                if scheme.lowercaseString == "x-coredata" {
                    if let moid = self.persistentStoreCoordinator!.managedObjectIDForURIRepresentation(URL) {
                        return self.VPNByID(moid)
                    }
                }
            }
        }
        return .None
    }
    
    func VPNByPredicate(predicate: NSPredicate) -> [VPN]
    {
        var vpns = [VPN]()
        var request = NSFetchRequest(entityName: "VPN")
        request.predicate = predicate
        
        var error: NSError?
        let fetchResults = self.managedObjectContext!.executeFetchRequest(request, error: &error) as [VPN]?
        
        if let results = fetchResults {
            vpns = results
        } else {
            println("cannot fetch vpns. \(error?.localizedDescription)")
        }
        
        return vpns
    }
    
    func VPNBeginsWithTitle(title: String) -> [VPN]
    {
        let titleBeginsWithPredicate = NSPredicate(format: "title beginswith[cd] %@", argumentArray: [title])
        return VPNByPredicate(titleBeginsWithPredicate)
    }
    
    func VPNHasTitle(title: String) -> [VPN]
    {
        let titleBeginsWithPredicate = NSPredicate(format: "title == %@", argumentArray: [title])
        return VPNByPredicate(titleBeginsWithPredicate)
    }
    
    func duplicate(vpn: VPN) -> VPN? {
        let duplicatedVPNs = VPNDataManager.sharedManager.VPNBeginsWithTitle(vpn.title)
        if duplicatedVPNs.count > 0 {
            let newTitle = "\(vpn.title) \(duplicatedVPNs.count)"
            
            VPNKeychainWrapper.passwordForVPNID(vpn.ID)
            
            if createVPN(
                newTitle,
                server: vpn.server,
                account: vpn.account,
                password: VPNKeychainWrapper.passwordStringForVPNID(vpn.ID),
                group: vpn.group,
                secret: VPNKeychainWrapper.secretStringForVPNID(vpn.ID),
                alwaysOn: vpn.alwaysOn)
            {
                let newVPNs = VPNHasTitle(newTitle)
                if newVPNs.count > 0 {
                    return newVPNs.first!
                }
            }
        }
        
        return .None
    }
}
