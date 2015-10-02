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

private let kAppGroupIdentifier = "group.VPNOn"
private let VPNManagerInstance: VPNManager = {
    let instance = VPNManager()
    instance.manager.loadFromPreferencesWithCompletionHandler { error in
        if let err = error {
            debugPrint("Failed to load preferences: \(err.localizedDescription)")
        }
    }
    instance.manager.localizedDescription = "VPN On"
    instance.manager.enabled = true
    return instance
    }()

final public class VPNManager {

    private lazy var manager: NEVPNManager = {
        return NEVPNManager.sharedManager()
        }()
    
    public lazy var defaults: NSUserDefaults = {
        return NSUserDefaults(suiteName: kAppGroupIdentifier)!
        }()
    
    public var status: NEVPNStatus {
        return manager.connection.status
    }
    
    public class var sharedManager: VPNManager {
        return VPNManagerInstance
    }
    
    public func connectIPSec(title: String, server: String, account: String?, group: String?, alwaysOn: Bool = true, passwordRef: NSData?, secretRef: NSData?) {
        #if (arch(i386) || arch(x86_64)) && os(iOS) // #if TARGET_IPHONE_SIMULATOR for Swift
        assert(false, "I'm afraid you can not connect VPN in simulators.")
        #endif
            
        let p = NEVPNProtocolIPSec()

        p.authenticationMethod = NEVPNIKEAuthenticationMethod.None
        p.useExtendedAuthentication = true
        p.serverAddress = server
        p.disconnectOnSleep = !alwaysOn
        
        manager.localizedDescription = "VPN On - \(title)"
        
        p.localIdentifier = group ?? "VPN"

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
    
        manager.enabled = true
        manager.`protocol` = p
        
        configOnDemand()
        
        manager.saveToPreferencesWithCompletionHandler { error in
            if let error = error {
                print("Failed to save profile: \(error.localizedDescription)")
                return
            }
            do {
                try self.manager.connection.startVPNTunnel()
            } catch {
                print("Failed to start tunnel")
            }
        }
    }
    
    public func connectIKEv2(title: String, server: String, account: String?, group: String?, alwaysOn: Bool = true, passwordRef: NSData?, secretRef: NSData?) {
        #if (arch(i386) || arch(x86_64)) && os(iOS) // #if TARGET_IPHONE_SIMULATOR for Swift
        assert(false, "I'm afraid you can not connect VPN in simulators.")
        #endif
        
        let p = NEVPNProtocolIKEv2()
        
        p.authenticationMethod = NEVPNIKEAuthenticationMethod.None
        p.useExtendedAuthentication = true
        p.serverAddress = server
        p.remoteIdentifier = server
        p.disconnectOnSleep = !alwaysOn
        p.deadPeerDetectionRate = NEVPNIKEv2DeadPeerDetectionRate.Medium
        // TODO: Add an option into config page
        
        manager.localizedDescription = "VPN On - \(title)"
        
        p.localIdentifier = group ?? "VPN"
        
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
        
        manager.enabled = true
        manager.`protocol` = p
        
        configOnDemand()
        
        manager.saveToPreferencesWithCompletionHandler {
            (error: NSError?) -> Void in
            if let err = error {
                debugPrint("Failed to save profile: \(err.localizedDescription)")
            } else {
                var connectError : NSError?
                do {
                    try self.manager.connection.startVPNTunnel()
                } catch let error as NSError {
                    connectError = error
                    if let connectErr = connectError {
                        debugPrint("Failed to start IKEv2 tunnel: \(connectErr.localizedDescription)")
                    }
                } catch {
                    fatalError()
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
            manager.onDemandRules = [ruleEvaluateConnection]
            manager.onDemandEnabled = true
        } else {
            manager.onDemandRules = [NEOnDemandRule]()
            manager.onDemandEnabled = false
        }
    }
    
    public func disconnect() {
        manager.connection.stopVPNTunnel()
    }
    
    public func removeProfile() {
        manager.removeFromPreferencesWithCompletionHandler { error in
            
        }
    }
}
