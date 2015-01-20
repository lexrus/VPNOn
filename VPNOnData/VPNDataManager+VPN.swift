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
    
    func deleteVPN(vpn:VPN)
    {
        self.managedObjectContext?.deleteObject(vpn)
        self.saveContext()
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
            if let moid = self.persistentStoreCoordinator!.managedObjectIDForURIRepresentation(URL) {
                return self.VPNByID(moid)
            }
        }
        return .None
    }
}
