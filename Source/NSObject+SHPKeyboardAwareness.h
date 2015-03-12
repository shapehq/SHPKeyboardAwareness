//
// SHPKeyboardAwareness
// NSObject+SHPKeyboardAwareness.h
//
// Copyright (c) 2014-2015 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACSignal;

@interface NSObject (SHPKeyboardAwareness)

/// returns a signal that provides a signal containing the offset needed for clearing the active textField or textView from the keyboard
- (RACSignal *)shp_keyboardAwarenessSignal;

/// returns a signal that provides a signal containing the offset needed for clearing a view from the keyboard
/// @param view The view you want to stay clear of the keyboard.
- (RACSignal *)shp_keyboardAwarenessSignalForView:(UIView *)view;

/// The receiver will get keyboard events during its life time. The receiver must implement the keyboardTriggeredEvent: method as defined
/// in the SHPKeyboardAwarenessClient protocol. Does not currently support events for rotation while the keyboard is visible. If required, use
/// shp_engageKeyboardAwarenessForView: instead.
- (void)shp_engageKeyboardAwareness;

/// The receiver will get keyboard events during its life time. The receiver must implement the keyboardTriggeredEvent: method as defined
/// in the SHPKeyboardAwarenessClient protocol. Optionally, provide a view which you want to limit the events to. Keyboard events will be
/// sent, only when view conflicts with the keyboard bounds.
/// @param view The view you want to stay clear of the keyboard. Provide nil to get same functionality as shp_engageKeyboardAwareness
- (void)shp_engageKeyboardAwarenessForView:(UIView *)view;

@end
