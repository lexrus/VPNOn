//
//  VPNManager+Geo.swift
//  VPNOn
//
//  Created by Lex on 2/25/15.
//  Copyright (c) 2017 lexrus.com. All rights reserved.
//

import Foundation
import MMDB

private let kGeoIPQueryURI = "https://www.telize.com/geoip/%@"

extension VPNManager {

    public typealias MMDBLookupCallback = (_ country: MMDBCountry?) -> Void
    
    public func countryOfIP(_ IP: String) -> MMDBCountry? {
        if let mmdb = self.mmdb, let country = mmdb.lookup(IP) {
            return country
        }
        return nil
    }
    
    // See http://stackoverflow.com/questions/25890533/how-can-i-get-a-real-ip-address-from-dns-query-in-swift
    public func IPOfHost(_ host: String) -> String? {
        let host = CFHostCreateWithName(nil, host as CFString).takeRetainedValue()
        CFHostStartInfoResolution(host, .addresses, nil)
        var success: DarwinBoolean = DarwinBoolean(false)
        guard let addressing = CFHostGetAddressing(host, &success) else {
            return nil
        }

        let addresses = addressing.takeUnretainedValue() as NSArray
        if addresses.count > 0 {
            let theAddress = addresses[0] as! Data
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            let infoResult = getnameinfo(
                (theAddress as NSData).bytes.bindMemory(to: sockaddr.self, capacity: theAddress.count),
                socklen_t(theAddress.count),
                &hostname,
                socklen_t(hostname.count),
                nil,
                0,
                NI_NUMERICHOST
            )
            if infoResult == 0 {
                if let numAddress = String(validatingUTF8: hostname) {
                    return numAddress
                }
            }
        }

        return nil
    }

    public func countryOfHost(_ host: String, callback: @escaping MMDBLookupCallback) -> Void {
        DispatchQueue.global().async {
            [weak self] in
            guard let ip = self?.IPOfHost(host), let country = self?.countryOfIP(ip) else {
                return
            }
            
            DispatchQueue.main.async {
                callback(country)
            }
        }
    }
}
