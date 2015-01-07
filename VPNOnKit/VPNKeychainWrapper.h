//
//  VPNKeychainWrapper.h
//  VPNOnFramework
//
//  Created by Lex on 12/12/14.
//  Copyright (c) 2014 Lex Tang. All rights reserved.
//

#ifndef VPNOnFramework_VPNKeychainWrapper_h
#define VPNOnFramework_VPNKeychainWrapper_h

@import Foundation;

@class VPNKeychainWrapper;

@interface VPNKeychainWrapper : NSObject

+ (BOOL) setPassword:(NSString*)password forVPNID:(NSString*)VPNID;

+ (BOOL) setSecret:(NSString*)secret forVPNID:(NSString*)VPNID;

+ (NSData*) passwordForVPNID:(NSString*)VPNID;

+ (NSData*) secretForVPNID:(NSString*)VPNID;

+ (void)destoryKeyForVPNID:(NSString*)VPNID;

@end

#endif
