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
    
    func testDomainsInString() {
        let mustBe2 = VPNManager.sharedManager.domainsInString("a")
        XCTAssert(mustBe2.count == 2, "Must be 2 domains.")
        let mustBe4 = VPNManager.sharedManager.domainsInString("a b")
        XCTAssert(mustBe4.count == 4, "Must be 4 domains.")
    }
    
    func testGeoIP() {
        let geoInfoOfGoogleDNS = VPNManager.sharedManager.geoInfoOfIP("8.8.4.4")
        XCTAssert(geoInfoOfGoogleDNS != nil, "Google DNS must has Geo IP info.")
        XCTAssert(geoInfoOfGoogleDNS!.isp == "Google Inc.", "Google DNS must be hosted by Google Inc.")
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
        
        VPNManager.sharedManager.geoInfoOfHost("google.com") {
            geoInfo in
            
            XCTAssert(geoInfo.countryCode != "", "Country code must not be empty.")
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
}
