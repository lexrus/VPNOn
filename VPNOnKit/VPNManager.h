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

@property (strong, nonatomic) NSDictionary *activatedVPNDict;
@property (readonly, nonatomic) NEVPNStatus status;

+ (VPNManager *)sharedManager;

- (void)connect;

- (void)disconnect;

- (void)removeProfile;

@end

#endif
