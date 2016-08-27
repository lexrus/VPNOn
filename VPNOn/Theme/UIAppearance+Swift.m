//
//  UIAppearance+Swift.m
//  VPNOn
//
//  Created by Lex on 1/15/15.
//  Copyright (c) 2016 lexrus.com. All rights reserved.
//

#import "UIAppearance+Swift.h"

@implementation UIView (UIViewAppearance_Swift)

+ (instancetype) lt_appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return [self appearanceWhenContainedIn:containerClass, nil];
}

@end
