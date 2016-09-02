//
//  VPNManager.swift
//  VPNOn
//
//  Created by Lex Tang on 12/5/14.
//  Copyright (c) 2014 lexrus.com. All rights reserved.
//

import Foundation
import NetworkExtension
import CoreData
import MMDB

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
    public var passwordRef: Data? {
        return KeychainWrapper.passwordRefForVPNID(ID)
    }
    public var secretRef: Data? {
        return KeychainWrapper.secretRefForVPNID(ID)
    }
    
    public init() { }
}

public typealias VPNConfigureCompletion = (Void) -> Void

open class VPNManager {

    fileprivate lazy var manager: NEVPNManager = {
        return NEVPNManager.shared()
        }()
    
    open lazy var defaults: UserDefaults = {
        return UserDefaults(suiteName: kAppGroupIdentifier)!
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

    fileprivate func loadPreferances(_ completion: @escaping () -> Void) {
        manager.loadFromPreferences { error in
            assert(error == nil, "Failed to load preferences: \(error!.localizedDescription)")
            self.manager.localizedDescription = "VPN On"
            self.manager.isEnabled = true
            completion()
        }
    }

    public func save(_ account: VPNAccount, completion: VPNConfigureCompletion?) {
        loadPreferances { [weak self] in
            self?._save(account, completion: completion)
        }
    }
    
    fileprivate func _save(_ account: VPNAccount, completion: VPNConfigureCompletion?) {
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
                p.authenticationMethod = .sharedSecret
                p.sharedSecretReference = secret
            } else {
                p.authenticationMethod = .none
            }
            pt = p
        } else {
            let p = NEVPNProtocolIKEv2()
            p.useExtendedAuthentication = true
            p.localIdentifier = account.group ?? "VPN"
            p.remoteIdentifier = account.server
            if let secret = account.secretRef {
                p.authenticationMethod = .sharedSecret
                p.sharedSecretReference = secret
            } else {
                p.authenticationMethod = .none
            }
            p.deadPeerDetectionRate = NEVPNIKEv2DeadPeerDetectionRate.medium
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
    
        manager.isEnabled = true
        manager.`protocol` = pt
        
        configOnDemand()
        
        manager.saveToPreferences { error in
            if let err = error {
                print("Failed to save profile: \(err.localizedDescription)")
            } else {
                let delayTime = DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    completion?()
                }
            }
        }
    }
    
    public func connect() {
        do {
            try self.manager.connection.startVPNTunnel()
        } catch NEVPNErrorDomain.configurationInvalid {
            
        } catch NEVPNErrorDomain.configurationDisabled {
            
        } catch let error as NSError {
            print(error.localizedDescription)
            NotificationCenter.default.post(
                name: NSNotification.Name.NEVPNStatusDidChange,
                object: nil
            )
        }
    }
    
    public func saveAndConnect(_ account: VPNAccount) {
        save(account) {
            [weak self] in
            self?.connect()
        }
    }
    
    public func configOnDemand() {
        if onDemandDomainsArray.count > 0 && onDemand {
            let connectionRule = NEEvaluateConnectionRule(
                matchDomains: onDemandDomainsArray,
                andAction: NEEvaluateConnectionRuleAction.connectIfNeeded
            )
            let ruleEvaluateConnection = NEOnDemandRuleEvaluateConnection()
            ruleEvaluateConnection.connectionRules = [connectionRule]
            manager.onDemandRules = [ruleEvaluateConnection]
            manager.isOnDemandEnabled = true
        } else {
            manager.onDemandRules = [NEOnDemandRule]()
            manager.isOnDemandEnabled = false
        }
    }
    
    public func disconnect() {
        manager.connection.stopVPNTunnel()
    }
    
    public func removeProfile() {
        manager.loadFromPreferences { _ in
            self.manager.removeFromPreferences { _ in
                
            }
        }
    }
}
