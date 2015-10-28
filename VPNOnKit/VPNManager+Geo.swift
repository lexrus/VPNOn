//
//  VPNManager+Geo.swift
//  VPNOn
//
//  Created by Lex on 2/25/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import Foundation

public struct GeoIP {
    public var countryCode: String
    public var isp: String
    public var latitude: Float
    public var longitude: Float
}

private let kGeoIPQueryURI = "https://www.telize.com/geoip/%@"

extension VPNManager {
    
    public func geoInfoOfIP(IP: String) -> GeoIP? {
        let URLString = String(format: kGeoIPQueryURI, IP)
        guard let URL = NSURL(string: URLString) else { return nil }
        
        let request = NSMutableURLRequest(URL: URL)
        
        if let version = NSBundle.mainBundle()
                         .objectForInfoDictionaryKey("CFBundleShortVersionString") as? String {
            request.addValue("VPN On \(version)", forHTTPHeaderField: "User-Agent")
        }

        request.HTTPShouldHandleCookies = false
        request.HTTPShouldUsePipelining = true
        request.cachePolicy = NSURLRequestCachePolicy.ReloadRevalidatingCacheData
        request.timeoutInterval = 6
        
        var response: NSURLResponse? = nil
        guard let data = try? NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
              else { return nil }
        guard let JSON = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? NSDictionary
              else { return nil }
        
        guard let countryCode = JSON.valueForKey("country_code") as? String else { return nil }
        let ISP = JSON.valueForKey("isp") as? String ?? ""
        let latitude = JSON.valueForKey("latitude") as? Float ?? 0
        let longitude = JSON.valueForKey("longitude") as? Float ?? 0
        
        let geoIP = GeoIP(
            countryCode: countryCode.uppercaseString,
            isp: ISP,
            latitude: latitude,
            longitude: longitude)
        return geoIP
    }
    
    // See http://stackoverflow.com/questions/25890533/how-can-i-get-a-real-ip-address-from-dns-query-in-swift
    public func IPOfHost(host: String) -> String? {
        let host = CFHostCreateWithName(nil, host).takeRetainedValue()
        CFHostStartInfoResolution(host, .Addresses, nil)
        var success: DarwinBoolean = DarwinBoolean(false)
        if let addressing = CFHostGetAddressing(host, &success) {
            let addresses = addressing.takeUnretainedValue() as NSArray
            if addresses.count > 0 {
                let theAddress = addresses[0] as! NSData
                var hostname = [CChar](count: Int(NI_MAXHOST), repeatedValue: 0)
                if getnameinfo(UnsafePointer(theAddress.bytes), socklen_t(theAddress.length),
                    &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                        if let numAddress = String.fromCString(hostname) {
                            return numAddress
                        }
                }
            }
        }
        
        return nil
    }
    
    public func geoInfoOfHost(host: String, callback: (geoInfo: GeoIP) -> ()) -> Void {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            [weak self] in
            if let ip = self?.IPOfHost(host), geo = self?.geoInfoOfIP(ip) {
                dispatch_async(dispatch_get_main_queue()) {
                    callback(geoInfo: geo)
                }
            }
        }
    }
}
