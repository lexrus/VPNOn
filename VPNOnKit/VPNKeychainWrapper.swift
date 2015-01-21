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

@objc(VPNKeychainWrapper)
class VPNKeychainWrapper
{
    class func setPassword(password: String, forVPNID VPNID: String) -> Bool {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        KeychainWrapper.serviceName = kKeychainServiceName
        KeychainWrapper.removeObjectForKey(key)
        return KeychainWrapper.setString(password, forKey: key)
    }
    
    class func setSecret(secret: String, forVPNID VPNID: String) -> Bool {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        KeychainWrapper.serviceName = kKeychainServiceName
        KeychainWrapper.removeObjectForKey("\(key)psk")
        return KeychainWrapper.setString(secret, forKey: "\(key)psk")
    }
    
    class func passwordForVPNID(VPNID: String) -> NSData? {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        KeychainWrapper.serviceName = kKeychainServiceName
        return KeychainWrapper.dataForKey(key)
    }
    
    class func secretForVPNID(VPNID: String) -> NSData? {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        KeychainWrapper.serviceName = kKeychainServiceName
        return KeychainWrapper.dataForKey("\(key)psk")
    }
    
    class func destoryKeyForVPNID(VPNID: String) {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        KeychainWrapper.serviceName = kKeychainServiceName
        KeychainWrapper.removeObjectForKey(key)
        KeychainWrapper.removeObjectForKey("\(key)psk")
    }
    
    class func passwordStringForVPNID(VPNID: String) -> String? {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        KeychainWrapper.serviceName = kKeychainServiceName
        return KeychainWrapper.stringForKey(key)
    }
    
    class func secretStringForVPNID(VPNID: String) -> String? {
        let key = NSURL(string: VPNID)!.lastPathComponent!
        KeychainWrapper.serviceName = kKeychainServiceName
        return KeychainWrapper.stringForKey("\(key)psk")
    }
}