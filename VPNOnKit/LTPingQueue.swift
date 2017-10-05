//
//  File.swift
//  VPNOn
//
//  Created by Lex Tang on 1/7/15.
//  Copyright (c) 2017 lexrus.com. All rights reserved.
//

import Foundation

public struct LTHostLatency {
    public let hostname: String
    public var latency: Int
}

public let kPingDidUpdate = "kPingDidUpdate"
public let kPingDidComplete = "kPingDidComplete"

private let kPingTimeout: TimeInterval = 7

open class LTPingOperation : NSObject, SimplePingDelegate {
    
    open var hostLatency: LTHostLatency
    open var ping: SimplePing?
    open var completed = false
    
    fileprivate var timeoutTimer: Timer?
    fileprivate var startTimeInterval: TimeInterval?
    
    init(hostname: String) {
        hostLatency = LTHostLatency(hostname: hostname, latency: -1)
    }
    
    deinit {
        ping?.delegate = nil
    }
    
    open func start() {
        completed = false
        ping = SimplePing(hostName: hostLatency.hostname)
        if let p = ping {
            p.delegate = self
            timeoutTimer = Timer.scheduledTimer(
                timeInterval: kPingTimeout,
                target: self,
                selector: #selector(LTPingOperation.stop),
                userInfo: nil,
                repeats: false)
            p.start()
        }
    }
    
    @objc open func stop() {
        ping?.stop()
        ping = nil
        timeoutTimer?.invalidate()
        timeoutTimer = nil
        startTimeInterval = nil
        completed = true
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: kPingDidUpdate), object: nil)
    }
    
    // MARK: - SimplePingDelegate
    
    /**
    Called after the SimplePing has successfully started up.  After this callback, you
    can start sending pings via -sendPingWithData:
    */
    open func simplePing(_ pinger: SimplePing!, didStartWithAddress address: Data!) {
        startTimeInterval = Date.timeIntervalSinceReferenceDate
        pinger.send(with: nil)
    }
    
    /**
    If this is called, the SimplePing object has failed.  By the time this callback is
    called, the object has stopped (that is, you don't need to call -stop yourself).
    
    IMPORTANT: On the send side the packet does not include an IP header.
    On the receive side, it does.  In that case, use +[SimplePing icmpInPacket:]
    to find the ICMP header within the packet.
    */
    open func simplePing(_ pinger: SimplePing!, didFailWithError error: Error!) {
        stop()
    }
    
    /**
    Called whenever the SimplePing object has successfully sent a ping packet.
    */
    open func simplePing(_ pinger: SimplePing!, didSendPacket packet: Data!) {
        
    }
    
    /**
    Called whenever the SimplePing object tries and fails to send a ping packet.
    */
    open func simplePing(_ pinger: SimplePing!, didFailToSendPacket packet: Data!, error: Error!) {
        stop()
    }
    
    /**
    Called whenever the SimplePing object receives an ICMP packet that looks like
    a response to one of our pings (that is, has a valid ICMP checksum, has
    an identifier that matches our identifier, and has a sequence number in
    the range of sequence numbers that we've sent out).
    public */
    open func simplePing(_ pinger: SimplePing!, didReceivePingResponsePacket packet: Data!) {
        if let startTime = startTimeInterval {
            let latency = Date.timeIntervalSinceReferenceDate - startTime
            hostLatency.latency = Int(latency * 1000)
        }
        stop()
    }
    
    open func simplePing(_ pinger: SimplePing!, didReceiveUnexpectedPacket packet: Data!) {
        
    }
}

private let LTPingQueueInstance = LTPingQueue()

open class LTPingQueue : NSObject, SimplePingDelegate {
    
    open class var sharedQueue : LTPingQueue {
        return LTPingQueueInstance
    }
    
    open lazy var operations: [LTPingOperation] = {
        return [LTPingOperation]()
        }()
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(LTPingQueue.pingDidUpdate(_:)),
            name: NSNotification.Name(rawValue: kPingDidUpdate),
            object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kPingDidUpdate), object: nil)
    }
    
    open func latencyForHostname(_ hostname: String) -> Int {
        if let pinger = (operations.filter { $0.hostLatency.hostname == hostname }.first) {
            return pinger.hostLatency.latency
        }
        
        let pingOperation = LTPingOperation(hostname: hostname)
        pingOperation.start()
        operations.append(pingOperation)
        return -1
    }
    
    open func restartPing() {
        operations.forEach {
            $0.hostLatency.latency = -1
            $0.start()
        }
    }
    
    open func clean() {
        operations.forEach { $0.stop() }
        operations.removeAll(keepingCapacity: false)
    }
    
    @objc open func pingDidUpdate(_ notification: Notification) {
        if operations.count != 0 && operations.filter({ !$0.completed }).count == 0 {
            NotificationCenter.default.post(name: Notification.Name(rawValue: kPingDidComplete), object: nil)
        }
    }
    
}
