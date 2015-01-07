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
        KeychainWrapper.serviceName = kKeychainServiceName
        KeychainWrapper.removeObjectForKey(VPNID)
        return KeychainWrapper.setString(password, forKey: VPNID)
    }
    
    class func setSecret(secret: String, forVPNID VPNID: String) -> Bool {
        KeychainWrapper.serviceName = kKeychainServiceName
        KeychainWrapper.removeObjectForKey("\(VPNID)psk")
        return KeychainWrapper.setString(secret, forKey: "\(VPNID)psk")
    }
    
    class func passwordForVPNID(VPNID: String) -> NSData? {
        KeychainWrapper.serviceName = kKeychainServiceName
        return KeychainWrapper.dataForKey(VPNID)
    }
    
    class func secretForVPNID(VPNID: String) -> NSData? {
        KeychainWrapper.serviceName = kKeychainServiceName
        return KeychainWrapper.dataForKey("\(VPNID)psk")
    }
    
    class func destoryKeyForVPNID(VPNID: String) {
        KeychainWrapper.serviceName = kKeychainServiceName
        KeychainWrapper.removeObjectForKey(VPNID)
        KeychainWrapper.removeObjectForKey("\(VPNID)psk")
    }
}