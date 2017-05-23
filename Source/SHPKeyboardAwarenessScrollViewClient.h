//
// SHPKeyboardAwareness
// SHPKeyboardAwarenessScrollViewClient.h
//
// Copyright (c) 2014-2016 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHPKeyboardAwarenessClient.h"

// Internal client, used for a default implementation of handing keyboardEvents with a ScrollView type
@interface SHPKeyboardAwarenessScrollViewClient : NSObject <SHPKeyboardAwarenessClient>
- (instancetype _Nonnull)initWithView:(UIScrollView *_Nonnull)view conflictingViewPadding:(CGFloat)padding;

+ (instancetype _Nonnull)clientWithView:(UIScrollView *_Nonnull)view conflictingViewPadding:(CGFloat)padding;
@end