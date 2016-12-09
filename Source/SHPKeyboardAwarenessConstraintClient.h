//
// SHPKeyboardAwareness
// SHPKeyboardAwarenessConstraintClient.h
//
// Copyright (c) 2014-2016 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHPKeyboardAwarenessClient.h"

// Internal client, used for a default implementation of handing keyboardEvents with a Constraint type
@interface SHPKeyboardAwarenessConstraintClient : NSObject <SHPKeyboardAwarenessClient>
+ (SHPKeyboardAwarenessConstraintClient *)ClientWithView:(UIView *)view verticalConstraint:(NSLayoutConstraint *)constraint conflictingViewPadding:(CGFloat)padding;

- (instancetype)initWithView:(UIView *)view verticalConstraint:(NSLayoutConstraint *)constraint conflictingViewPadding:(CGFloat)padding;
@end