//
//  Keychain.swift
//  VPNOn
//
//  Created by Lex Tang on 12/12/14.
//  Copyright (c) 2017 lexrus.com. All rights reserved.
//

import Foundation
import KeychainAccess

public struct KeychainWrapper {
    
    private static var instance: Keychain {
        return Keychain(service: "com.LexTang.VPNOn")
    }

    public static func setPassword(_ password: String, forVPNID VPNID: String) {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        _ = try? instance.remove(key)
        instance[key] = password
    }
    
    public static func setSecret(_ secret: String, forVPNID VPNID: String) {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        _ = try? instance.remove("\(key)psk")
        instance["\(key)psk"] = secret
    }
    
    public static func passwordRefForVPNID(_ VPNID: String) -> Data? {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        return instance[attributes: key]?.persistentRef
    }
    
    public static func secretRefForVPNID(_ VPNID: String) -> Data? {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        if let data = instance[attributes: "\(key)psk"]?.data, let value = String(data: data, encoding: .utf8) {
            if !value.isEmpty {
                return instance[attributes: "\(key)psk"]?.persistentRef
            }
        }
        return nil
    }
    
    public static func destoryKeyForVPNID(_ VPNID: String) {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        _ = try? instance.remove(key)
        _ = try? instance.remove("\(key)psk")
        _ = try? instance.remove("\(key)cert")
    }
    
    public static func passwordStringForVPNID(_ VPNID: String) -> String? {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        return instance[key]
    }
    
    public static func secretStringForVPNID(_ VPNID: String) -> String? {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        return instance["\(key)psk"]
    }

}
