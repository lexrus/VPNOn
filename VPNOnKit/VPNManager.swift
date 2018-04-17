//
//  VPNManager.swift
//  VPNOn
//
//  Created by Lex Tang on 12/5/14.
//  Copyright (c) 2017 lexrus.com. All rights reserved.
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
    public var remoteID: String?
    public var alwaysOn = true
    public var passwordRef: Data? {
        return KeychainWrapper.passwordRefForVPNID(ID)
    }
    public var secretRef: Data? {
        return KeychainWrapper.secretRefForVPNID(ID)
    }
    
    public init() { }
}

public typealias VPNConfigureCompletion = () -> Void

open class VPNManager {

    private var manager: NEVPNManager {
        return NEVPNManager.shared()
    }
    
    open lazy var defaults: UserDefaults = {
        return UserDefaults(suiteName: kAppGroupIdentifier)!
        }()
    
    public var status: NEVPNStatus {
        return manager.connection.status
    }

    public lazy var mmdb: MMDB? = {
        return MMDB()
    }()
    
    public class var shared: VPNManager {
        return instance
    }

    fileprivate func loadPreferances(_ completion: @escaping () -> Void) {
        manager.loadFromPreferences { error in
            assert(error == nil, "Failed to load preferences: \(error!.localizedDescription)")
            completion()
        }
    }

    public func save(_ account: VPNAccount, completion: VPNConfigureCompletion?) {
        loadPreferances { [weak self] in
            self?._save(account, completion: completion)
        }
    }
    
    fileprivate func _save(_ account: VPNAccount, completion: VPNConfigureCompletion?) {
        #if targetEnvironment(simulator)
            assert(false, "I'm afraid you can not connect VPN in simulators.")
        #endif
        
        var pt: NEVPNProtocol
        
        if account.type == .IPSec {
            let p = NEVPNProtocolIPSec()
            p.useExtendedAuthentication = true
            p.localIdentifier = account.group ?? "VPN"
            p.remoteIdentifier = account.remoteID
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
            p.remoteIdentifier = account.remoteID
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
        
        manager.localizedDescription = "VPN On"
        manager.protocolConfiguration = pt
        manager.isEnabled = true
        
        configOnDemand()
        
        manager.saveToPreferences { error in
            if let err = error {
                print("Failed to save profile: \(err.localizedDescription)")
            } else {
                completion?()
            }
        }
    }
    
    public func connect() {
        do {
            try self.manager.connection.startVPNTunnel()
        } catch NEVPNError.configurationInvalid {
            
        } catch NEVPNError.configurationDisabled {
            
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
        // The first removing disable on demand feature of the VPN
        manager.removeFromPreferences { _ in
            // This one actually remove the VPN profile
            self.manager.removeFromPreferences { _ in
                
            }
        }
    }
}
