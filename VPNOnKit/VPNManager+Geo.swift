//
//  VPNManager+Geo.swift
//  VPNOn
//
//  Created by Lex on 2/25/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit

public struct GeoIP {
    public var countryCode: String
    public var isp: String
    public var latitude: Float
    public var longitude: Float
}

extension VPNManager
{
    public func geoInfoOfIP(IP: String) -> GeoIP? {
        let urlString = String(format: "http://www.telize.com/geoip/%@", IP)
        if let url = NSURL(string: urlString) {
            let request = NSMutableURLRequest(URL: url)
            var agent = "VPN On"
            if let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as String? {
                agent = "\(agent) \(version)"
            }
            request.HTTPShouldHandleCookies = false
            request.HTTPShouldUsePipelining = true
            request.cachePolicy = NSURLRequestCachePolicy.ReloadRevalidatingCacheData
            request.addValue(agent, forHTTPHeaderField: "User-Agent")
            request.timeoutInterval = 10
            
            var response: NSURLResponse? = nil
            if let data = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: nil) {
                var parseError: NSError? = nil
                let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &parseError) as NSDictionary?
                if parseError == nil {
                    if let js = json {
                        let countryCode = js.valueForKey("country_code3") as String?
                        let isp = js.valueForKey("isp") as String?
                        let latitude = js.valueForKey("latitude") as Float?
                        let longitude = js.valueForKey("longitude") as Float?
                        if countryCode != nil && isp != nil && latitude != nil && longitude != nil {
                            var geoIP = GeoIP(countryCode: countryCode!, isp: isp!, latitude: latitude!, longitude: longitude!)
                            return geoIP
                        }
                    }
                }
            }
        }
        
        return .None
    }
}
