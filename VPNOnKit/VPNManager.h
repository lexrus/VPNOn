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
@property (readonly, nonatomic) BOOL isActivatedVPNIDDeprecated;

+ (VPNManager *) sharedManager;

- (void) connectIPSec:(NSString *)title
               server:(NSString *)server
              account:(NSString *)account
                group:(NSString *)group
             alwaysOn:(BOOL)alwaysOn
          passwordRef:(NSData *)passwordRef
            secretRef:(NSData *)secretRef
          certificate:(NSString *)certificate;

- (void) connectIKEv2:(NSString *)title
               server:(NSString *)server
              account:(NSString *)account
                group:(NSString *)group
             alwaysOn:(BOOL)alwaysOn
          passwordRef:(NSData *)passwordRef
            secretRef:(NSData *)secretRef
          certificate:(NSString *)certificate;

- (void) disconnect;

- (void) removeProfile;

@end

#endif
