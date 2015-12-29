//
//  VPNOnKitTests.swift
//  VPNOnKitTests
//
//  Created by Lex on 12/12/14.
//  Copyright (c) 2014 LexTang.com. All rights reserved.
//

import Foundation
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
    
    func testDomainsInString() {
        let mustBe2 = VPNManager.sharedManager.domainsInString("a")
        XCTAssert(mustBe2.count == 2, "Must be 2 domains.")
        let mustBe4 = VPNManager.sharedManager.domainsInString("a b")
        XCTAssert(mustBe4.count == 4, "Must be 4 domains.")
    }
    
    func testGeoIP() {
        let countryOfGoogleDNS = VPNManager.sharedManager.countryOfIP("8.8.4.4")
        XCTAssert(countryOfGoogleDNS != nil, "Google DNS must has Geo IP info.")
        XCTAssert(countryOfGoogleDNS!.isoCode == "US", "Google DNS must be hosted in USA.")
    }
    
    func testResolve() {
        let ipOfPingAn = VPNManager.sharedManager.IPOfHost("pingan.com")
        XCTAssert(ipOfPingAn != nil, "IP must not be nil.")
        XCTAssert(ipOfPingAn! == "202.69.26.11", "IP of PingAn must not be changed for years.")
        let ipOfGoogleDNS = VPNManager.sharedManager.IPOfHost("8.8.4.4")
        XCTAssert(ipOfGoogleDNS! == "8.8.4.4", "IP of Google DNS must be valid.")
    }
    
    func testInvalidDomain() {
        let ipOfInvalidDomain = VPNManager.sharedManager.IPOfHost("asdfghijkl")
        XCTAssertNil(ipOfInvalidDomain, "This domain must be invalid.")
    }
    
    func testEmptyDomain() {
        let ipOfEmptyDomain = VPNManager.sharedManager.IPOfHost("")
        XCTAssertNil(ipOfEmptyDomain, "No domain must be invalid.")
    }
    
    func testAsyncResolve() {
        let expectation = self.expectationWithDescription("Async fetch GeoInfo.")
        
        VPNManager.sharedManager.countryOfHost("shields.io") {
            country in
            
            XCTAssert(country!.isoCode != "", "Country code must not be empty.")
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(9.0, handler: nil)
    }
}
