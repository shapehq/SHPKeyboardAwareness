//
// SHPKeyboardAwareness
// SHPKeyboardAwarenessClient.h
//
// Copyright (c) 2014-2015 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SHPKeyboardEvent;

@protocol SHPKeyboardAwarenessClient <NSObject>

- (void)keyboardTriggeredEvent:(SHPKeyboardEvent *)keyboardEvent;

@end
