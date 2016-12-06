//
// SHPKeyboardAwareness
// SHPKeyboardAwareness.h
//
// Copyright (c) 2014-2016 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol SHPKeyboardAwarenessClient;

@interface SHPKeyboardAwarenessObserver : NSObject
@property (nonatomic, weak, nullable) id<SHPKeyboardAwarenessClient> delegate;

- (instancetype _Nonnull)initWithObserveView: (UIView *_Nullable)view;
- (instancetype _Nonnull)init;

/// The receiver will get keyboard events during its life time. The receiver must implement the keyboardTriggeredEvent: method as defined
/// in the SHPKeyboardAwarenessClient protocol. Does not currently support events for rotation while the keyboard is visible. If required, use
/// ObserverForView: instead.
+ (instancetype _Nonnull)Observer;
/// The receiver will get keyboard events during its life time. The receiver must implement the keyboardTriggeredEvent: method as defined
/// in the SHPKeyboardAwarenessClient protocol. Optionally, provide a view which you want to limit the events to. Keyboard events will be
/// sent, only when view conflicts with the keyboard bounds.
/// @param view The view you want to stay clear of the keyboard. Provide nil to get same functionality as shp_engageKeyboardAwareness
+ (instancetype _Nonnull)ObserverForView: (UIView *_Nullable)view;

//- (void)shp_engageKeyboardAwareness;
//
//- (void)shp_engageKeyboardAwarenessForView:(UIView *)view;

@end
