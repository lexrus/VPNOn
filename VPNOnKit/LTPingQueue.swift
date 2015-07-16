//
//  File.swift
//  VPNOn
//
//  Created by Lex Tang on 1/7/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

import Foundation

public struct LTHostLatency {
    public let hostname: String
    public var latency: Int
}

public let kPingDidUpdate = "kPingDidUpdate"
public let kPingDidComplete = "kPingDidComplete"

let kPingTimeout: NSTimeInterval = 5

public class LTPingOperation: NSObject, SimplePingDelegate {
    
    public var hostLatency: LTHostLatency
    public var ping: SimplePing?
    public var complete = false
    
    var timeoutTimer: NSTimer?
    var startTimeInterval: NSTimeInterval?
    
    init(hostname: String) {
        hostLatency = LTHostLatency(hostname: hostname, latency: -1)
    }
    
    deinit {
        if let _ping = ping {
            _ping.delegate = nil
        }
    }
    
    public func start() {
        complete = false
        ping = SimplePing(hostName: hostLatency.hostname)
        if let p = ping {
            p.delegate = self
            timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(kPingTimeout, target: self, selector: Selector("stop"), userInfo: nil, repeats: false)
            p.start()
        }
    }
    
    public func stop() {
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
        
        NSNotificationCenter.defaultCenter().postNotificationName(kPingDidUpdate, object: nil)
    }
    
    // MARK: - SimplePingDelegate
    
    /**
    Called after the SimplePing has successfully started up.  After this callback, you
    can start sending pings via -sendPingWithData:
    */
    public func simplePing(pinger: SimplePing!, didStartWithAddress address: NSData!) {
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
    public func simplePing(pinger: SimplePing!, didFailWithError error: NSError!) {
        stop()
    }
    
    /**
    Called whenever the SimplePing object has successfully sent a ping packet.
    */
    public func simplePing(pinger: SimplePing!, didSendPacket packet: NSData!) {
        
    }
    
    /**
    Called whenever the SimplePing object tries and fails to send a ping packet.
    */
    public func simplePing(pinger: SimplePing!, didFailToSendPacket packet: NSData!, error: NSError!) {
        stop()
    }
    
    /**
    Called whenever the SimplePing object receives an ICMP packet that looks like
    a response to one of our pings (that is, has a valid ICMP checksum, has
    an identifier that matches our identifier, and has a sequence number in
    the range of sequence numbers that we've sent out).
    public */
    public func simplePing(pinger: SimplePing!, didReceivePingResponsePacket packet: NSData!) {
        if let startTime = startTimeInterval {
            let latency = NSDate.timeIntervalSinceReferenceDate() - startTime
            hostLatency.latency = Int(latency * 1000)
//            println("\(hostLatency.hostname) = \(hostLatency.latency)ms")
        }
        stop()
    }
    
    public func simplePing(pinger: SimplePing!, didReceiveUnexpectedPacket packet: NSData!) {
        
    }
}

public class LTPingQueue: NSObject, SimplePingDelegate {
    
    public class var sharedQueue : LTPingQueue
    {
        struct Static
        {
            static let sharedInstance = LTPingQueue()
        }
        
        return Static.sharedInstance
    }
    
    public var operations = [LTPingOperation]()
    
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("pingDidUpdate:"), name: kPingDidUpdate, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kPingDidUpdate, object: nil)
    }
    
    public func latencyForHostname(hostname: String) -> Int {
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
    
    public func restartPing() {
        for pingOperation in operations {
            pingOperation.hostLatency.latency = -1
            pingOperation.start()
        }
    }
    
    public func clean() {
        for pingOperation in operations {
            pingOperation.stop()
        }
        operations.removeAll(keepCapacity: false)
    }
    
    public func pingDidUpdate(notification: NSNotification) {
        if operations.count == 0 {
            return
        }
        
        for pingOperation in operations {
            if !pingOperation.complete {
                return
            }
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(kPingDidComplete, object: nil)
    }
    
}