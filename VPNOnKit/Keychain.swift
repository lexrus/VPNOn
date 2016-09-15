//
//  Keychain.swift
//  VPNOn
//
//  Created by Lex Tang on 12/12/14.
//  Copyright (c) 2014 lexrus.com. All rights reserved.
//

import Foundation
import KeychainAccess

public struct KeychainWrapper {
    
    private static var k: Keychain {
        return Keychain(service: "com.LexTang.VPNOn")
    }

    public static func setPassword(_ password: String, forVPNID VPNID: String) {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        _ = try? k.remove(key)
        k[key] = password
    }
    
    public static func setSecret(_ secret: String, forVPNID VPNID: String) {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        _ = try? k.remove("\(key)psk")
        k["\(key)psk"] = secret
    }
    
    public static func passwordRefForVPNID(_ VPNID: String) -> Data? {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        return k[attributes: key]?.persistentRef
    }
    
    public static func secretRefForVPNID(_ VPNID: String) -> Data? {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        return k[attributes: "\(key)psk"]?.persistentRef
    }
    
    public static func destoryKeyForVPNID(_ VPNID: String) {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        _ = try? k.remove(key)
        _ = try? k.remove("\(key)psk")
        _ = try? k.remove("\(key)cert")
    }
    
    public static func passwordStringForVPNID(_ VPNID: String) -> String? {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        return k[key]
    }
    
    public static func secretStringForVPNID(_ VPNID: String) -> String? {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        return k["\(key)psk"]
    }

}
