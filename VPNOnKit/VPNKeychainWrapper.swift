//
//  VPNKeychainWrapper.swift
//  VPNOn
//
//  Created by Lex Tang on 12/12/14.
//  Copyright (c) 2014 LexTang.com. All rights reserved.
//

import Foundation

//let kKeychainServiceName = NSBundle.mainBundle().bundleIdentifier!
let kKeychainServiceName = "com.LexTang.VPNOn"

final public class VPNKeychainWrapper
{
    public class func setPassword(password: String, forVPNID VPNID: String) -> Bool {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        KeychainWrapper.serviceName = kKeychainServiceName
        KeychainWrapper.removeObjectForKey(key)
        if password.isEmpty {
            return true
        }
        return KeychainWrapper.setString(password, forKey: key)
    }
    
    public class func setSecret(secret: String, forVPNID VPNID: String) -> Bool {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        KeychainWrapper.serviceName = kKeychainServiceName
        KeychainWrapper.removeObjectForKey("\(key)psk")
        if secret.isEmpty {
            return true
        }
        return KeychainWrapper.setString(secret, forKey: "\(key)psk")
    }
    
    public class func setCertificate(certificate: NSData?, forVPNID VPNID: String) -> Bool {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        KeychainWrapper.serviceName = kKeychainServiceName
        KeychainWrapper.removeObjectForKey("\(key)cert")
        if let data = certificate {
            KeychainWrapper.setData(data, forKey: "\(key)cert")
        }
        return true
    }
    
    public class func passwordForVPNID(VPNID: String) -> NSData? {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        KeychainWrapper.serviceName = kKeychainServiceName
        return KeychainWrapper.dataRefForKey(key)
    }
    
    public class func secretForVPNID(VPNID: String) -> NSData? {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        KeychainWrapper.serviceName = kKeychainServiceName
        return KeychainWrapper.dataRefForKey("\(key)psk")
    }
    
    public class func destoryKeyForVPNID(VPNID: String) {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        KeychainWrapper.serviceName = kKeychainServiceName
        KeychainWrapper.removeObjectForKey(key)
        KeychainWrapper.removeObjectForKey("\(key)psk")
        KeychainWrapper.removeObjectForKey("\(key)cert")
    }
    
    public class func passwordStringForVPNID(VPNID: String) -> String? {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        KeychainWrapper.serviceName = kKeychainServiceName
        return KeychainWrapper.stringForKey(key)
    }
    
    public class func secretStringForVPNID(VPNID: String) -> String? {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        KeychainWrapper.serviceName = kKeychainServiceName
        return KeychainWrapper.stringForKey("\(key)psk")
    }
    
    public class func certificateForVPNID(VPNID: String) -> NSData? {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        KeychainWrapper.serviceName = kKeychainServiceName
        return KeychainWrapper.dataForKey("\(key)cert")
    }
}