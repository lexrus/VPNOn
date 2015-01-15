//
//  UIAppearance+Swift.h
//  VPNOn
//
//  Created by Lex on 1/15/15.
//  Copyright (c) 2015 LexTang.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (UIViewAppearance_Swift)

+ (instancetype) lt_appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass;

@end
