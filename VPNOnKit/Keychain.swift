//
//  Keychain.swift
//  VPNOn
//
//  Created by Lex Tang on 12/12/14.
//  Copyright (c) 2014 LexTang.com. All rights reserved.
//

import Foundation

public struct Keychain {
    
    public static var defaultKeychain: KeychainWrapper {
        return KeychainWrapper(serviceName: "com.LexTang.VPNOn")
    }
    
    public static func setPassword(password: String, forVPNID VPNID: String) -> Bool {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        defaultKeychain.removeObjectForKey(key)
        if password.isEmpty {
            return true
        }
        return defaultKeychain.setString(password, forKey: key)
    }
    
    public static func setSecret(secret: String, forVPNID VPNID: String) -> Bool {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        defaultKeychain.removeObjectForKey("\(key)psk")
        if secret.isEmpty {
            return true
        }
        return defaultKeychain.setString(secret, forKey: "\(key)psk")
    }
    
    public static func passwordForVPNID(VPNID: String) -> NSData? {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        return defaultKeychain.dataRefForKey(key)
    }
    
    public static func secretForVPNID(VPNID: String) -> NSData? {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        return defaultKeychain.dataRefForKey("\(key)psk")
    }
    
    public static func destoryKeyForVPNID(VPNID: String) {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        defaultKeychain.removeObjectForKey(key)
        defaultKeychain.removeObjectForKey("\(key)psk")
        defaultKeychain.removeObjectForKey("\(key)cert")
    }
    
    public static func passwordStringForVPNID(VPNID: String) -> String? {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        return defaultKeychain.stringForKey(key)
    }
    
    public static func secretStringForVPNID(VPNID: String) -> String? {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        return defaultKeychain.stringForKey("\(key)psk")
    }

}
