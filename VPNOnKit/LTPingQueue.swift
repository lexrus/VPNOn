//
//  File.swift
//  VPNOn
//
//  Created by Lex Tang on 1/7/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import Foundation

struct LTHostLatency {
    let hostname: String
    var latency: Int
}

let kLTPingDidUpdate = "kLTPingDidUpdate"
let kLTPingDidComplete = "kLTPingDidComplete"
let kLTPingTimeout: NSTimeInterval = 5

class LTPingOperation: NSObject, SimplePingDelegate {
    
    var hostLatency: LTHostLatency
    var ping: SimplePing?
    var timeoutTimer: NSTimer?
    var startTimeInterval: NSTimeInterval?
    var complete = false
    
    init(hostname: String) {
        hostLatency = LTHostLatency(hostname: hostname, latency: -1)
    }
    
    deinit {
        if let _ping = ping {
            _ping.delegate = nil
        }
    }
    
    func start() {
        complete = false
        ping = SimplePing(hostName: hostLatency.hostname)
        if let p = ping {
            p.delegate = self
            timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(kLTPingTimeout, target: self, selector: Selector("stop"), userInfo: nil, repeats: false)
            p.start()
        }
    }
    
    func stop() {
        if let p = ping {
            p.stop()
            ping = nil
        }
        if let t = timeoutTimer {
            t.invalidate()
            timeoutTimer = nil
        }
        startTimeInterval = nil
        complete = true
        
        NSNotificationCenter.defaultCenter().postNotificationName(kLTPingDidUpdate, object: nil)
    }
    
    // MARK: - SimplePingDelegate
    
    /**
    Called after the SimplePing has successfully started up.  After this callback, you
    can start sending pings via -sendPingWithData:
    */
    func simplePing(pinger: SimplePing!, didStartWithAddress address: NSData!) {
        startTimeInterval = NSDate.timeIntervalSinceReferenceDate()
        pinger.sendPingWithData(nil)
    }
    
    /**
    If this is called, the SimplePing object has failed.  By the time this callback is
    called, the object has stopped (that is, you don't need to call -stop yourself).
    
    IMPORTANT: On the send side the packet does not include an IP header.
    On the receive side, it does.  In that case, use +[SimplePing icmpInPacket:]
    to find the ICMP header within the packet.
    */
    func simplePing(pinger: SimplePing!, didFailWithError error: NSError!) {
        stop()
    }
    
    /**
    Called whenever the SimplePing object has successfully sent a ping packet.
    */
    func simplePing(pinger: SimplePing!, didSendPacket packet: NSData!) {
        
    }
    
    /**
    Called whenever the SimplePing object tries and fails to send a ping packet.
    */
    func simplePing(pinger: SimplePing!, didFailToSendPacket packet: NSData!, error: NSError!) {
        stop()
    }
    
    /**
    Called whenever the SimplePing object receives an ICMP packet that looks like
    a response to one of our pings (that is, has a valid ICMP checksum, has
    an identifier that matches our identifier, and has a sequence number in
    the range of sequence numbers that we've sent out).
    */
    func simplePing(pinger: SimplePing!, didReceivePingResponsePacket packet: NSData!) {
        if let startTime = startTimeInterval {
            let latency = NSDate.timeIntervalSinceReferenceDate() - startTime
            hostLatency.latency = Int(latency * 1000)
            println("\(hostLatency.hostname) = \(hostLatency.latency)ms")
        }
        stop()
    }
    
    func simplePing(pinger: SimplePing!, didReceiveUnexpectedPacket packet: NSData!) {
        
    }
}

@objc(LTPingQueue)
class LTPingQueue: NSObject, SimplePingDelegate {
    
    class var sharedQueue : LTPingQueue
    {
        struct Static
        {
            static var onceToken : dispatch_once_t = 0
            static var instance : LTPingQueue? = nil
        }
        
        dispatch_once(&Static.onceToken)
        {
            Static.instance = LTPingQueue()
        }
        
        return Static.instance!
    }
    
    var operations = [LTPingOperation]()
    
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("pingDidUpdate:"), name: kLTPingDidUpdate, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kLTPingDidUpdate, object: nil)
    }
    
    func latencyForHostname(hostname: String) -> Int {
        for pingOperation in operations {
            let pinger = pingOperation as LTPingOperation
            if pinger.hostLatency.hostname != hostname {
                continue
            } else {
                return pinger.hostLatency.latency
            }
        }
        
        let pingOperation = LTPingOperation(hostname: hostname)
        pingOperation.start()
        operations.append(pingOperation)
        return -1
    }
    
    func restartPing() {
        for pingOperation in operations {
            pingOperation.hostLatency.latency = -1
            pingOperation.start()
        }
    }
    
    func clean() {
        for pingOperation in operations {
            pingOperation.stop()
        }
        operations.removeAll(keepCapacity: false)
    }
    
    func pingDidUpdate(notification: NSNotification) {
        if operations.count == 0 {
            return
        }
        
        for pingOperation in operations {
            if !pingOperation.complete {
                return
            }
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(kLTPingDidComplete, object: nil)
    }
    
}