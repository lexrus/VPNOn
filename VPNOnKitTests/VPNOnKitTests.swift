//
//  VPNOnKitTests.swift
//  VPNOnKitTests
//
//  Created by Lex on 12/12/14.
//  Copyright (c) 2014 LexTang.com. All rights reserved.
//

import UIKit
import XCTest
import VPNOnKit

class VPNOnKitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testKeychainReadWrite() {
        self.measureBlock() {
            VPNKeychainWrapper.setPassword("hello", forVPNID: "testVPN")
            XCTAssertNotNil(VPNKeychainWrapper.passwordForVPNID("testVPN"), "Password data in keychain must not be nil.")
            
            VPNKeychainWrapper.setSecret("world", forVPNID: "testVPN")
            XCTAssertNotNil(VPNKeychainWrapper.secretForVPNID("testVPN"), "Secret data in keychain must not be nil.")
            
            let passwordString = VPNKeychainWrapper.passwordStringForVPNID("testVPN")
            XCTAssert(passwordString == "hello", "Password string must match the previous one.")
            
            VPNKeychainWrapper.destoryKeyForVPNID("testVPN")
            XCTAssertNil(VPNKeychainWrapper.passwordForVPNID("testVPN"), "Password data must be empty after destory.")
            XCTAssertNil(VPNKeychainWrapper.secretForVPNID("testVPN"), "Secret data must be empty after destory.")
        }
    }
    
}
