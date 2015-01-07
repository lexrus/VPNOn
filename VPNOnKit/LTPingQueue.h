//
//  LTPingQueue.h
//  VPNOn
//
//  Created by Lex Tang on 1/7/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

#ifndef LTPingQueue_Header_h
#define LTPingQueue_Header_h

@import Foundation;

@class LTPingQueue;

@interface LTPingQueue : NSObject

@property (strong, nonatomic) NSDictionary *activatedVPNDict;
@property (readonly, nonatomic) NEVPNStatus status;

+ (LTPingQueue *)sharedQueue;

- (void) restartPing;
- (int) latencyForHostname:(NSString *)hostname;
- (void) clean;

@end

#endif
