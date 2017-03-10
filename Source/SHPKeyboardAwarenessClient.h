//
// SHPKeyboardAwareness
// SHPKeyboardAwarenessClient.h
//
// Copyright (c) 2014-2016 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SHPKeyboardEvent;

@protocol SHPKeyboardAwarenessClient <NSObject>

- (void)keyboardTriggeredEvent:(nonnull SHPKeyboardEvent *)keyboardEvent;

@optional
/// The default padding between the keyboard and the view/caret is 0
/// Implement this delegate method to change the padding
/// @param view The conflicting view
- (CGFloat)shpKeyboardAwarenessPaddingBetweenKeyboardAndView: (UIView *_Nonnull)view;
@end
