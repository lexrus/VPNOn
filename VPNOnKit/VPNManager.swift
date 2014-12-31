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

let kAppGroupName = "group.VPNOn"
let kActivatedVPNKey = "activatedVPN"

@objc(VPNManager)
class VPNManager
{
    let _manager = NEVPNManager.sharedManager()!
    
    var status: NEVPNStatus {
        get {
            return _manager.connection.status
        }
    }
    
    class var _sharedManager : VPNManager
    {
        struct Static
        {
            static var onceToken : dispatch_once_t = 0
            static var instance : VPNManager? = nil
        }
        
        dispatch_once(&Static.onceToken)
            {
                Static.instance = VPNManager()
                Static.instance!._manager.loadFromPreferencesWithCompletionHandler {
                    (error: NSError!) -> Void in
                    if let err = error {
                        println("Failed to load preferences: \(err.localizedDescription)")
                    }
                }
                Static.instance!._manager.localizedDescription = "VPN On"
                Static.instance!._manager.enabled = true
        }
        
        return Static.instance!
    }
    
    class func sharedManager() -> VPNManager {
        return VPNManager._sharedManager
    }
    
    var activatedVPNDict: NSDictionary? {
        get {
            if let defaults = NSUserDefaults(suiteName: kAppGroupName) {
                if let VPNDict = defaults.objectForKey(kActivatedVPNKey) as NSDictionary? {
                    return VPNDict
                }
            }
            return .None
        }
        set {
            if let defaults = NSUserDefaults(suiteName: kAppGroupName) {
                defaults.setObject(newValue, forKey: kActivatedVPNKey)
                defaults.synchronize()
            }
        }
    }
    
    func connect() {
        if let VPNDict = activatedVPNDict {
            var p = NEVPNProtocolIPSec()
            p.authenticationMethod = NEVPNIKEAuthenticationMethod.SharedSecret
            
            if let group = VPNDict.objectForKey("group") as String? {
                p.localIdentifier = group
            } else {
                p.localIdentifier = "VPN"
            }
            
            if let title = VPNDict.objectForKey("title") as String? {
                p.remoteIdentifier = title
                _manager.localizedDescription = "VPN On - \(title)"
            } else {
                p.remoteIdentifier = "VPN On"
            }
            
            if let username = VPNDict.objectForKey("account") as String? {
                p.username = username
            }
            
            if let server = VPNDict.objectForKey("server") as String? {
                p.serverAddress = server
            }
            
            p.useExtendedAuthentication = true
            p.disconnectOnSleep = false
            
            let VPNID = VPNDict.objectForKey("ID") as String
            
            if let passwordRef = VPNKeychainWrapper.passwordForVPNID(VPNID) {
                p.passwordReference = passwordRef
            }
            
            if let secretRef = VPNKeychainWrapper.secretForVPNID(VPNID) {
                p.sharedSecretReference = secretRef
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
                        println("Failed to start tunnel: \(connectErr.localizedDescription)")
                    } else {
                        println("VPN tunnel started.")
                    }
                }
            }
        } else {
            println("Please activate a VPN.")
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
