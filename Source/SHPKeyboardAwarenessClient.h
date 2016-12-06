//
// SHPKeyboardAwareness
// SHPKeyboardAwarenessClient.h
//
// Copyright (c) 2014-2016 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SHPKeyboardEvent;

@protocol SHPKeyboardAwarenessClient <NSObject>

- (void)keyboardTriggeredEvent:(nullable SHPKeyboardEvent *)keyboardEvent;

@end
