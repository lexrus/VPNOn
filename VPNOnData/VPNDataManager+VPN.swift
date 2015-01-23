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
        let fetchResults = self.managedObjectContext!.executeFetchRequest(request, error: nil) as [VPN]?
        
        if let results = fetchResults {
            for vpn in results {
                if vpn.deleted {
                    continue
                }
                vpns.append(vpn)
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
        ikev2: Bool = false,
        certificate: String = ""
        ) -> Bool
    {
        let entity = NSEntityDescription.entityForName("VPN", inManagedObjectContext: self.managedObjectContext!)
        let vpn = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: self.managedObjectContext!) as VPN
        
        vpn.title = title
        vpn.server = server
        vpn.account = account
        vpn.group = group
        vpn.alwaysOn = alwaysOn
        vpn.ikev2 = ikev2
        
        var error: NSError?
        if !self.managedObjectContext!.save(&error) {
            println("Could not save VPN \(error), \(error?.userInfo)")
            return false
        } else {
            saveContext()
            
            if !vpn.objectID.temporaryID {
                if !password.isEmpty {
                    VPNKeychainWrapper.setPassword(password, forVPNID: vpn.ID)
                }
                if !secret.isEmpty {
                    VPNKeychainWrapper.setSecret(secret, forVPNID: vpn.ID)
                }
                if !certificate.isEmpty {
                    VPNKeychainWrapper.setCertificate(certificate, forVPNID: vpn.ID)
                }
                
                if allVPN().count == 1 {
                    VPNManager.sharedManager().activatedVPNID = vpn.ID
                }
            }
            return true
        }
    }
    
    func deleteVPN(vpn:VPN)
    {
        let objectID = vpn.objectID
        let ID = "\(vpn.ID)"
        
        VPNKeychainWrapper.destoryKeyForVPNID(ID)
        managedObjectContext!.deleteObject(vpn)
        
        var saveError: NSError?
        managedObjectContext!.save(&saveError)
        saveContext()
        
        if let activatedVPNID = VPNManager.sharedManager().activatedVPNID {
            if activatedVPNID == ID {
                VPNManager.sharedManager().activatedVPNID = nil
                
                var vpns = allVPN()
                
                if let firstVPN = vpns.first {
                    VPNManager.sharedManager().activatedVPNID = firstVPN.ID
                }
            }
        }
    }
    
    func VPNByID(ID: NSManagedObjectID) -> VPN?
    {
        var error: NSError?
        if ID.temporaryID {
            return .None
        }
        
        var result = self.managedObjectContext?.existingObjectWithID(ID, error: &error)
        if let vpn = result {
            if !vpn.deleted {
                return vpn as? VPN
            }
        } else {
            println("Fetch error: \(error)")
            return .None
        }
        return .None
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
            for vpn in results {
                if vpn.deleted {
                    continue
                }
                vpns.append(vpn)
            }
        } else {
            println("Failed to fetch VPNs: \(error?.localizedDescription)")
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
                password: VPNKeychainWrapper.passwordStringForVPNID(vpn.ID) ?? "",
                group: vpn.group,
                secret: VPNKeychainWrapper.secretStringForVPNID(vpn.ID) ?? "",
                alwaysOn: vpn.alwaysOn,
                ikev2: vpn.ikev2,
                certificate: VPNKeychainWrapper.certificateStringForVPNID(vpn.ID) ?? ""
                )
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
