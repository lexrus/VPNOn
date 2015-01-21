//
//  KeychainWrapper.swift
//  KeychainWrapper
//
//  Created by Jason Rendel on 9/23/14.
//  Copyright (c) 2014 jasonrendel. All rights reserved.
//

import Foundation

let SecMatchLimit: String! = kSecMatchLimit as String
let SecReturnData: String! = kSecReturnData as String
let SecValueData: String! = kSecValueData as String
let SecAttrAccessible: String! = kSecAttrAccessible as String
let SecClass: String! = kSecClass as String
let SecAttrService: String! = kSecAttrService as String
let SecAttrGeneric: String! = kSecAttrGeneric as String
let SecAttrAccount: String! = kSecAttrAccount as String
let SecReturnPersistentRef: String! = kSecReturnPersistentRef as String

class KeychainWrapper {
   private struct internalVars {
        static var serviceName: String = ""
    }
    
    // MARK: Public Properties
    
    /*!
    @var serviceName
    @abstract Used for the kSecAttrService property to uniquely identify this keychain accessor.
    @discussion Service Name will default to the app's bundle identifier if it can
    */
    class var serviceName: String {
        get {
            if internalVars.serviceName.isEmpty {
                internalVars.serviceName = NSBundle.mainBundle().bundleIdentifier ?? "SwiftKeychainWrapper"
            }
            return internalVars.serviceName
        }
        set(newServiceName) {
            internalVars.serviceName = newServiceName
        }
    }
    
    // MARK: Public Methods
    class func hasValueForKey(key: String) -> Bool {
        var keychainData: NSData? = self.dataForKey(key)
        if let data = keychainData {
            return true
        } else {
            return false
        }
    }
    
    // MARK: Getting Values
    class func stringForKey(keyName: String) -> String? {
        var keychainData: NSData? = self.dataForKey(keyName)
        var stringValue: String?
        if let data = keychainData {
            stringValue = NSString(data: data, encoding: NSUTF8StringEncoding) as String?
        }
        
        return stringValue
    }
    
    class func objectForKey(keyName: String) -> NSCoding? {
        let dataValue: NSData? = self.dataForKey(keyName)
        
        var objectValue: NSCoding?
        
        if let data = dataValue {
            objectValue = NSKeyedUnarchiver.unarchiveObjectWithData(data) as NSCoding?
        }
        
        return objectValue;
    }
    
    class func dataForKey(keyName: String) -> NSData? {
        var keychainQueryDictionary = self.setupKeychainQueryDictionaryForKey(keyName)
        
        // Limit search results to one
        keychainQueryDictionary[SecMatchLimit] = kSecMatchLimitOne
        
        // Specify we want NSData/CFData returned
        keychainQueryDictionary[SecReturnData] = kCFBooleanTrue
        
        // Search
        var searchResultRef: Unmanaged<AnyObject>?
        var keychainValue: NSData?
        
        let status: OSStatus = SecItemCopyMatching(keychainQueryDictionary, &searchResultRef)
        
        if status == noErr {
            if let resultRef = searchResultRef {
                keychainValue = resultRef.takeUnretainedValue() as? NSData
            }
        }
        
        return keychainValue;
    }
    
    class func dataRefForKey(keyName: String) -> NSData? {
        var keychainQueryDictionary = self.setupKeychainQueryDictionaryForKey(keyName)
        
        // Limit search results to one
        keychainQueryDictionary[SecMatchLimit] = kSecMatchLimitOne
        
        keychainQueryDictionary[SecReturnPersistentRef] = kCFBooleanTrue
        
        // Search
        var searchResultRef: Unmanaged<AnyObject>?
        var keychainValue: NSData?
        
        let status: OSStatus = SecItemCopyMatching(keychainQueryDictionary, &searchResultRef)
        
        if status == noErr {
            if let resultRef = searchResultRef {
                keychainValue = resultRef.takeUnretainedValue() as? NSData
            }
        }
        
        return keychainValue;
    }
    
    // MARK: Setting Values
    class func setString(value: String, forKey keyName: String) -> Bool {
        if let data = value.dataUsingEncoding(NSUTF8StringEncoding) {
            return self.setData(data, forKey: keyName)
        } else {
            return false
        }
    }
    
    class func setObject(value: NSCoding, forKey keyName: String) -> Bool {
        let data = NSKeyedArchiver.archivedDataWithRootObject(value)
        
        return self.setData(data, forKey: keyName)
    }
    
    class func setData(value: NSData, forKey keyName: String) -> Bool {
        var keychainQueryDictionary: NSMutableDictionary = self.setupKeychainQueryDictionaryForKey(keyName)
        
        keychainQueryDictionary[SecValueData] = value
        
        keychainQueryDictionary[SecAttrAccessible] = kSecAttrAccessibleAlwaysThisDeviceOnly
        
        let status: OSStatus = SecItemAdd(keychainQueryDictionary, nil)
        
        if status == errSecSuccess {
            return true
        } else if status == errSecDuplicateItem {
            return self.updateData(value, forKey: keyName)
        } else {
            return false
        }
    }
    
    // MARK: Removing Values
    class func removeObjectForKey(keyName: String) -> Bool {
        let keychainQueryDictionary: NSMutableDictionary = self.setupKeychainQueryDictionaryForKey(keyName)
        
        // Delete
        let status: OSStatus =  SecItemDelete(keychainQueryDictionary);
        
        if status == errSecSuccess {
            return true
        } else {
            return false
        }
    }
    
    // MARK: Private Methods
    private class func updateData(value: NSData, forKey keyName: String) -> Bool {
        let keychainQueryDictionary: NSMutableDictionary = self.setupKeychainQueryDictionaryForKey(keyName)
        let updateDictionary = [SecValueData:value]
        
        // Update
        let status: OSStatus = SecItemUpdate(keychainQueryDictionary, updateDictionary)

        if status == errSecSuccess {
            return true
        } else {
            return false
        }
    }
    
    private class func setupKeychainQueryDictionaryForKey(keyName: String) -> NSMutableDictionary {
        // Setup dictionary to access keychain and specify we are using a generic password (rather than a certificate, internet password, etc)
        var keychainQueryDictionary: NSMutableDictionary = [SecClass:kSecClassGenericPassword]
        
        // Uniquely identify this keychain accessor
        keychainQueryDictionary[SecAttrService] = KeychainWrapper.serviceName
        
        // Uniquely identify the account who will be accessing the keychain
        var encodedIdentifier: NSData? = keyName.dataUsingEncoding(NSUTF8StringEncoding)
        
        keychainQueryDictionary[SecAttrGeneric] = encodedIdentifier
        
        keychainQueryDictionary[SecAttrAccount] = encodedIdentifier
        
        return keychainQueryDictionary
    }
}