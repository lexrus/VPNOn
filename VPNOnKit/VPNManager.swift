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

private let instance = VPNManager()

public enum VPNType {
    case IPSec
    case IKEv2
}

public struct VPNAccount {
    public var ID: String = ""
    public var type: VPNType = .IPSec
    public var title: String = ""
    public var server: String = ""
    public var account: String?
    public var group: String?
    public var alwaysOn = true
    public var passwordRef: NSData? {
        return Keychain.passwordForVPNID(ID)
    }
    public var secretRef: NSData? {
        return Keychain.secretForVPNID(ID)
    }
    
    public init() { }
}

public typealias VPNConfigureCompletion = (Void) -> Void

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

    public lazy var mmdb: MMDB? = {
        return MMDB()
    }()
    
    public class var sharedManager: VPNManager {
        return instance
    }

    private func loadPreferances(completion: () -> Void) {
        manager.loadFromPreferencesWithCompletionHandler { error in
            assert(error == nil, "Failed to load preferences: \(error!.localizedDescription)")
            self.manager.localizedDescription = "VPN On"
            self.manager.enabled = true
            completion()
        }
    }

    public func save(account: VPNAccount, completion: VPNConfigureCompletion?) {
        loadPreferances { [weak self] in
            self?._save(account, completion: completion)
        }
    }
    
    private func _save(account: VPNAccount, completion: VPNConfigureCompletion?) {
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            // #if TARGET_IPHONE_SIMULATOR for Swift
            assert(false, "I'm afraid you can not connect VPN in simulators.")
        #endif
        
        var pt: NEVPNProtocol
        
        if account.type == .IPSec {
            let p = NEVPNProtocolIPSec()
            p.useExtendedAuthentication = true
            p.localIdentifier = account.group ?? "VPN"
            if let secret = account.secretRef {
                p.authenticationMethod = .SharedSecret
                p.sharedSecretReference = secret
            } else {
                p.authenticationMethod = .None
            }
            pt = p
        } else {
            let p = NEVPNProtocolIKEv2()
            p.useExtendedAuthentication = true
            p.localIdentifier = account.group ?? "VPN"
            p.remoteIdentifier = account.server
            if let secret = account.secretRef {
                p.authenticationMethod = .SharedSecret
                p.sharedSecretReference = secret
            } else {
                p.authenticationMethod = .None
            }
            p.deadPeerDetectionRate = NEVPNIKEv2DeadPeerDetectionRate.Medium
            pt = p
        }

        pt.disconnectOnSleep = !account.alwaysOn
        pt.serverAddress = account.server
        
        if let username = account.account {
            pt.username = username
        }
        
        if let password = account.passwordRef {
            pt.passwordReference = password
        }
        
        manager.localizedDescription = "VPN On - \(account.title)"
        manager.enabled = true
        manager.`protocol` = pt
        
        configOnDemand()
        
        manager.saveToPreferencesWithCompletionHandler {
            (error: NSError?) -> Void in
            if let err = error {
                print("Failed to save profile: \(err.localizedDescription)")
            } else {
                let delayTime = dispatch_time(
                    DISPATCH_TIME_NOW,
                    Int64(0.1 * Double(NSEC_PER_SEC))
                )
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    completion?()
                }
            }
        }
    }
    
    public func connect() {
        do {
            try self.manager.connection.startVPNTunnel()
        } catch NEVPNError.ConfigurationInvalid {
            
        } catch NEVPNError.ConfigurationDisabled {
            
        } catch let error as NSError {
            print(error.localizedDescription)
            NSNotificationCenter.defaultCenter().postNotificationName(
                NEVPNStatusDidChangeNotification,
                object: nil
            )
        }
    }
    
    public func saveAndConnect(account: VPNAccount) {
        save(account) {
            [weak self] in
            self?.connect()
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
