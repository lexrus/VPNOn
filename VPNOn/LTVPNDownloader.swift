//
//  LTVPNDownloader.swift
//  VPNOn
//
//  Created by Lex Tang on 1/27/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import UIKit

class LTVPNDownloader: NSObject
{
    var queue: NSOperationQueue?
    
    func download(URL: NSURL, callback: (NSURLResponse!, NSData!, NSError!) -> Void) {
        let request = NSMutableURLRequest(URL: URL)
        var agent = "VPN On"
        if let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as String? {
            agent = "\(agent) \(version)"
        }
        request.HTTPShouldHandleCookies = false
        request.HTTPShouldUsePipelining = true
        request.cachePolicy = NSURLRequestCachePolicy.ReloadRevalidatingCacheData
        request.addValue(agent, forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 20
        
        if let q = queue {
            q.suspended = true
            queue = nil
        }
        
        queue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: callback)
    }
    
    func cancel() {
        if let q = queue {
            q.suspended = true
            queue = nil
        }
    }
}
