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

final public class VPNManager
{
    lazy var _manager: NEVPNManager = {
        return NEVPNManager.sharedManager()!
        }()
    
    lazy var _defaults: NSUserDefaults = {
        return NSUserDefaults(suiteName: kAppGroupIdentifier)!
        }()
    
    public lazy var wormhole: MMWormhole = {
        return MMWormhole(applicationGroupIdentifier: kAppGroupIdentifier, optionalDirectory: "wormhole")
        }()
    
    public var status: NEVPNStatus {
        get {
            return _manager.connection.status
        }
    }
    
    private let kVPNOnDisplayFlags = "displayFlags"
    
    public var displayFlags: Bool {
        get {
            if let value = _defaults.objectForKey(kVPNOnDisplayFlags) as Int? {
                return Bool(value)
            }
            return true
        }
        set {
            _defaults.setObject(Int(newValue), forKey: kVPNOnDisplayFlags)
            _defaults.synchronize()
        }
    }
    
    public class var sharedManager : VPNManager
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
    
    public func connectIPSec(title: String, server: String, account: String?, group: String?, alwaysOn: Bool = true, passwordRef: NSData?, secretRef: NSData?, certificate: NSData?) {

        let p = NEVPNProtocolIPSec()

        p.authenticationMethod = NEVPNIKEAuthenticationMethod.None
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
            p.authenticationMethod = NEVPNIKEAuthenticationMethod.SharedSecret
            p.sharedSecretReference = secret
        }
        
        if let certficiateData = certificate {
            p.authenticationMethod = NEVPNIKEAuthenticationMethod.Certificate
            p.identityData = certficiateData
        }
    
        _manager.enabled = true
        _manager.`protocol` = p
        
        configOnDemand()
        
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
    
    public func connectIKEv2(title: String, server: String, account: String?, group: String?, alwaysOn: Bool = true, passwordRef: NSData?, secretRef: NSData?, certificate: NSData?) {
        
        let p = NEVPNProtocolIKEv2()
        
        p.authenticationMethod = NEVPNIKEAuthenticationMethod.None
        p.useExtendedAuthentication = true
        p.serverAddress = server
        p.remoteIdentifier = server
        p.disconnectOnSleep = !alwaysOn
        p.deadPeerDetectionRate = NEVPNIKEv2DeadPeerDetectionRate.Medium
        // TODO: Add an option into config page
        
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
            p.authenticationMethod = NEVPNIKEAuthenticationMethod.SharedSecret
            p.sharedSecretReference = secret
        }
        
        if let certficiateData = certificate {
            p.authenticationMethod = NEVPNIKEAuthenticationMethod.Certificate
            p.serverCertificateCommonName = server
            p.serverCertificateIssuerCommonName = server
            p.identityData = certficiateData
        }
        
        _manager.enabled = true
        _manager.`protocol` = p
        
        configOnDemand()
        
        _manager.saveToPreferencesWithCompletionHandler {
            (error: NSError!) -> Void in
            if let err = error {
                println("Failed to save profile: \(err.localizedDescription)")
            } else {
                var connectError : NSError?
                if self._manager.connection.startVPNTunnelAndReturnError(&connectError) {
                    if let connectErr = connectError {
                        println("Failed to start IKEv2 tunnel: \(connectErr.localizedDescription)")
                    } else {
                        println("IKEv2 tunnel started.")
                    }
                } else {
                    println("Failed to connect: \(connectError?.localizedDescription)")
                }
            }
        }
    }
    
    public func configOnDemand() {
        if onDemandDomainsArray.count > 0 && onDemand {
            let connectionRule = NEEvaluateConnectionRule(
                matchDomains: onDemandDomainsArray,
                andAction: NEEvaluateConnectionRuleAction.ConnectIfNeeded
            )
            let ruleEvaluateConnection = NEOnDemandRuleEvaluateConnection()
            ruleEvaluateConnection.connectionRules = [connectionRule]
            _manager.onDemandRules = [ruleEvaluateConnection]
            _manager.onDemandEnabled = true
        } else {
            _manager.onDemandRules = [AnyObject]()
            _manager.onDemandEnabled = false
        }
    }
    
    public func disconnect() {
        _manager.connection.stopVPNTunnel()
    }
    
    public func removeProfile() {
        _manager.removeFromPreferencesWithCompletionHandler {
            (error: NSError!) -> Void in
            
        }
    }
}
