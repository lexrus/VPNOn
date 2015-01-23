//
//  VPNManager.swift
//  VPNOn
//
//  Created by Lex Tang on 12/5/14.
//  Copyright (c) 2014 LexTang.com. All rights reserved.
//

import Foundation
import NetworkExtension
import CoreData

let kAppGroupIdentifier = "group.VPNOn"

@objc(VPNManager)
class VPNManager
{
    lazy var _manager: NEVPNManager = {
        return NEVPNManager.sharedManager()!
        }()
    
    lazy var _defaults: NSUserDefaults = {
        return NSUserDefaults(suiteName: kAppGroupIdentifier)!
        }()
    
    var status: NEVPNStatus {
        get {
            return _manager.connection.status
        }
    }
    
    class var _sharedManager : VPNManager
    {
        struct Static
        {
            static let sharedInstance : VPNManager = {
                let instance = VPNManager()
                instance._manager.loadFromPreferencesWithCompletionHandler {
                    (error: NSError!) -> Void in
                    if let err = error {
                        println("Failed to load preferences: \(err.localizedDescription)")
                    }
                }
                instance._manager.localizedDescription = "VPN On"
                instance._manager.enabled = true
                return instance
            }()
        }
        
        return Static.sharedInstance
    }
    
    class func sharedManager() -> VPNManager {
        return VPNManager._sharedManager
    }
    
    func connectIPSec(title: String, server: String, account: String?, group: String?, alwaysOn: Bool = true, passwordRef: NSData?, secretRef: NSData?, certificate: String?) {
        
        // TODO: Add a tailing closure for callback.
        
        let p = NEVPNProtocolIPSec()

        p.authenticationMethod = NEVPNIKEAuthenticationMethod.SharedSecret
        p.useExtendedAuthentication = true
        p.serverAddress = server
        p.disconnectOnSleep = !alwaysOn
        
        _manager.localizedDescription = "VPN On - \(title)"
        
        if let grp = group {
            p.localIdentifier = grp
        } else {
            p.localIdentifier = "VPN"
        }

        if let username = account {
            p.username = username
        }
        
        if let password = passwordRef {
            p.passwordReference = password
        }
        
        if let secret = secretRef {
            p.sharedSecretReference = secret
        }
    
        _manager.enabled = true
        _manager.`protocol` = p
        _manager.saveToPreferencesWithCompletionHandler {
            (error: NSError!) -> Void in
            if let err = error {
                println("Failed to save profile: \(err.localizedDescription)")
            } else {
                var connectError : NSError?
                self._manager.connection.startVPNTunnelAndReturnError(&connectError)
                
                if let connectErr = connectError {
//                    println("Failed to start tunnel: \(connectErr.localizedDescription)")
                } else {
//                    println("VPN tunnel started.")
                }
            }
        }
    }
    
    func connectIKEv2(title: String, server: String, account: String?, group: String?, alwaysOn: Bool = true, passwordRef: NSData?, secretRef: NSData?, certificate: String?) {
        let p = NEVPNProtocolIKEv2()
        
        p.authenticationMethod = NEVPNIKEAuthenticationMethod.SharedSecret
        p.useExtendedAuthentication = true
        p.serverAddress = server
        p.disconnectOnSleep = !alwaysOn
        
        _manager.localizedDescription = "VPN On - \(title)"
        
        if let grp = group {
            p.localIdentifier = grp
        } else {
            p.localIdentifier = "VPN"
        }
        
        if let username = account {
            p.username = username
        }
        
        if let password = passwordRef {
            p.passwordReference = password
        }
        
        if let secret = secretRef {
            p.sharedSecretReference = secret
        }
        
        _manager.enabled = true
        _manager.`protocol` = p
        _manager.saveToPreferencesWithCompletionHandler {
            (error: NSError!) -> Void in
            if let err = error {
                println("Failed to save profile: \(err.localizedDescription)")
            } else {
                var connectError : NSError?
                self._manager.connection.startVPNTunnelAndReturnError(&connectError)
                
                if let connectErr = connectError {
                    println("Failed to start IKEv2 tunnel: \(connectErr.localizedDescription)")
                } else {
                    println("IKEv2 tunnel started.")
                }
            }
        }
    }
    
    func disconnect() {
        _manager.connection.stopVPNTunnel()
    }
    
    func removeProfile() {
        _manager.removeFromPreferencesWithCompletionHandler {
            (error: NSError!) -> Void in
            
        }
    }
}
