//
//  VPNManager.h
//  VPNOnFramework
//
//  Created by Lex on 12/12/14.
//  Copyright (c) 2014 Lex Tang. All rights reserved.
//

#ifndef VPNOnFramework_VPNManager_h
#define VPNOnFramework_VPNManager_h

@import Foundation;
@import NetworkExtension;

@class VPNManager;

@interface VPNManager : NSObject

@property (strong, nonatomic) NSString *activatedVPNID;
@property (readonly, nonatomic) NEVPNStatus status;

+ (VPNManager *) sharedManager;

- (void) connect:(NSString *)title
          server:(NSString *)server
         account:(NSString *)account
           group:(NSString *)group
        alwaysOn:(BOOL)alwaysOn
     passwordRef:(NSData *)passwordRef
       secretRef:(NSData *)secretRef;

- (void) disconnect;

- (void) removeProfile;

@end

#endif
