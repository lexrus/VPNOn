//
//  VPNManager+Geo.swift
//  VPNOn
//
//  Created by Lex on 2/25/15.
//  Copyright (c) 2016 lexrus.com. All rights reserved.
//

import Foundation
import MMDB

private let kGeoIPQueryURI = "https://www.telize.com/geoip/%@"

extension VPNManager {

    public typealias MMDBLookupCallback = (country: MMDBCountry?) -> Void
    
    public func countryOfIP(IP: String) -> MMDBCountry? {
        if let mmdb = self.mmdb, country = mmdb.lookup(IP) {
            return country
        }
        return nil
    }
    
    // See http://stackoverflow.com/questions/25890533/how-can-i-get-a-real-ip-address-from-dns-query-in-swift
    public func IPOfHost(host: String) -> String? {
        let host = CFHostCreateWithName(nil, host).takeRetainedValue()
        CFHostStartInfoResolution(host, .Addresses, nil)
        var success: DarwinBoolean = DarwinBoolean(false)
        guard let addressing = CFHostGetAddressing(host, &success) else {
            return nil
        }

        let addresses = addressing.takeUnretainedValue() as NSArray
        if addresses.count > 0 {
            let theAddress = addresses[0] as! NSData
            var hostname = [CChar](count: Int(NI_MAXHOST), repeatedValue: 0)
            let infoResult = getnameinfo(
                UnsafePointer(theAddress.bytes),
                socklen_t(theAddress.length),
                &hostname,
                socklen_t(hostname.count),
                nil,
                0,
                NI_NUMERICHOST
            )
            if infoResult == 0 {
                if let numAddress = String.fromCString(hostname) {
                    return numAddress
                }
            }
        }

        return nil
    }

    public func countryOfHost(host: String, callback: MMDBLookupCallback) -> Void {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            [weak self] in
            if let ip = self?.IPOfHost(host), country = self?.countryOfIP(ip) {
                dispatch_async(dispatch_get_main_queue()) {
                    callback(country: country)
                }
            }
        }
    }
}
