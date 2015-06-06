//
//  Wormhole.swift
//  Remote
//
//  Created by NIX on 15/5/20.
//  Copyright (c) 2015年 nixWork. All rights reserved.
//

import Foundation

func ==(lhs: Wormhole.MessageListener, rhs: Wormhole.MessageListener) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

public class Wormhole: NSObject {
    
    let appGroupIdentifier: String
    let messageDirectoryName: String
    
    public init(appGroupIdentifier: String, messageDirectoryName: String) {
        
        self.appGroupIdentifier = appGroupIdentifier
        
        if messageDirectoryName.isEmpty {
            fatalError("ERROR: Wormhole need a message passing directory")
        }
        
        self.messageDirectoryName = messageDirectoryName
    }
    
    deinit {
        if let center = CFNotificationCenterGetDarwinNotifyCenter() {
            CFNotificationCenterRemoveEveryObserver(center, unsafeAddressOf(self))
        }
    }
    
    public typealias Message = NSCoding
    
    public func passMessage(message: Message?, withIdentifier identifier: String) {
        
        if identifier.isEmpty {
            fatalError("ERROR: Message need identifier")
        }
        
        if let message = message {
            var success = false
            
            if let filePath = filePathForIdentifier(identifier) {
                let data = NSKeyedArchiver.archivedDataWithRootObject(message)
                success = data.writeToFile(filePath, atomically: true)
            }
            
            if success {
                if let center = CFNotificationCenterGetDarwinNotifyCenter() {
                    CFNotificationCenterPostNotification(center, identifier, nil, nil, 1)
                }
            }
            
        } else {
            if let center = CFNotificationCenterGetDarwinNotifyCenter() {
                CFNotificationCenterPostNotification(center, identifier, nil, nil, 1)
            }
        }
    }
    
    public struct Listener {
        
        public typealias Action = Message? -> Void
        
        let name: String
        let action: Action
        
        public init(name: String, action: Action) {
            self.name = name
            self.action = action
        }
    }
    
    struct MessageListener: Hashable {
        
        let messageIdentifier: String
        let listener: Listener
        
        var hashValue: Int {
            return (messageIdentifier + "<nixzhu.Wormhole>" + listener.name).hashValue
        }
    }
    
    var messageListenerSet = Set<MessageListener>()
    
    public func bindListener(listener: Listener, forMessageWithIdentifier identifier: String) {
        
        if let center = CFNotificationCenterGetDarwinNotifyCenter() {
            
            let messageListener = MessageListener(messageIdentifier: identifier, listener: listener)
            messageListenerSet.insert(messageListener)
            
            let block: @objc_block (CFNotificationCenter!, UnsafeMutablePointer<Void>, CFString!, UnsafePointer<Void>, CFDictionary!) -> Void = { _, _, _, _, _ in
                
                if self.messageListenerSet.contains(messageListener) {
                    messageListener.listener.action(self.messageWithIdentifier(identifier))
                }
            }
            
            let imp: COpaquePointer = imp_implementationWithBlock(unsafeBitCast(block, AnyObject.self))
            let callBack: CFNotificationCallback = unsafeBitCast(imp, CFNotificationCallback.self)
            
            CFNotificationCenterAddObserver(center, unsafeAddressOf(self), callBack, identifier, nil, CFNotificationSuspensionBehavior.DeliverImmediately)
            
            
            // Try fire Listener's action for first time
            
            listener.action(messageWithIdentifier(identifier))
        }
    }
    
    public func removeListener(listener: Listener, forMessageWithIdentifier identifier: String) {
        
        let messageListener = MessageListener(messageIdentifier: identifier, listener: listener)
        messageListenerSet.remove(messageListener)
    }
    
    public func removeListenerByName(name: String, forMessageWithIdentifier identifier: String) {
        
        for messageListener in messageListenerSet {
            if messageListener.messageIdentifier == identifier && messageListener.listener.name == name {
                messageListenerSet.remove(messageListener)
                
                break
            }
        }
    }
    
    public func removeAllListenersForMessageWithIdentifier(identifier: String) {
        
        if let center = CFNotificationCenterGetDarwinNotifyCenter() {
            CFNotificationCenterRemoveObserver(center, unsafeAddressOf(self), identifier, nil)
            
            for listener in messageListenerSet {
                if listener.messageIdentifier == identifier {
                    messageListenerSet.remove(listener)
                }
            }
        }
    }
    
    public func messageWithIdentifier(identifier: String) -> Message? {
        
        if let
            filePath = filePathForIdentifier(identifier),
            data = NSData(contentsOfFile: filePath),
            message = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Message {
                return message
        }
        
        return nil
    }
    
    public func destroyMessageWithIdentifier(identifier: String) {
        
        if let filePath = filePathForIdentifier(identifier) {
            let fileManager = NSFileManager.defaultManager()
            fileManager.removeItemAtPath(filePath, error: nil)
        }
    }
    
    public func destroyAllMessages() {
        
        if let directoryPath = messagePassingDirectoryPath() {
            
            let fileManager = NSFileManager.defaultManager()
            
            if let fileNames = fileManager.contentsOfDirectoryAtPath(directoryPath, error: nil) as? [String] {
                
                for fileName in fileNames {
                    let filePath = directoryPath.stringByAppendingPathComponent(fileName)
                    fileManager.removeItemAtPath(filePath, error: nil)
                }
            }
        }
    }
    
    // MARK: Helpers
    
    func filePathForIdentifier(identifier: String) -> String? {
        
        if identifier.isEmpty {
            return nil
        }
        
        if let directoryPath = messagePassingDirectoryPath() {
            let fileName = identifier + ".archive"
            let filePath = directoryPath.stringByAppendingPathComponent(fileName)
            
            return filePath
        }
        
        return nil
    }
    
    func messagePassingDirectoryPath() -> String? {
        
        let fileManager = NSFileManager.defaultManager()
        
        if let
            appGroupContainer = fileManager.containerURLForSecurityApplicationGroupIdentifier(self.appGroupIdentifier),
            appGroupContainerPath = appGroupContainer.path {
                let directoryPath = appGroupContainerPath.stringByAppendingPathComponent(messageDirectoryName)
                
                fileManager.createDirectoryAtPath(directoryPath, withIntermediateDirectories: true, attributes: nil, error: nil)
                
                return directoryPath
        }
        
        return nil
    }
    
}