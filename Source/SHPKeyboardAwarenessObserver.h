//
// SHPKeyboardAwareness
// SHPKeyboardAwareness.h
//
// Copyright (c) 2014-2016 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol SHPKeyboardAwarenessClient;

/// The offsetType defines how the Observer will calculate the required offset
typedef NS_ENUM(NSUInteger, SHPKeyboardAwarenessOffsetType){
    /// Bottom - offset required to move the bottom of a view above the keyboard
    SHPKeyboardAwarenessOffsetTypeBottom,
    /// Caret - the offset required to have Caret (insertion point) above the keyboard
    /// If set as offsetType, this will only apply if the observeView is a UITextView (or the observeView isn't set)
    SHPKeyboardAwarenessOffsetTypeCaret // insertion point
};

@interface SHPKeyboardAwarenessObserver : NSObject
@property (nonatomic, weak, nullable) id<SHPKeyboardAwarenessClient> delegate;
/// The observer will only observe childviews within in the observerSuperView
/// If the superview is not set, the observer will send keyboard events for all conflicting views (even across viewControllers)
@property (nonatomic, strong, nullable) UIView *observerSuperView;

/// The point the observer will try to calculate offset to
@property (nonatomic, assign) SHPKeyboardAwarenessOffsetType offsetType;

- (instancetype _Nonnull)initWithObserverSuperView: (UIView *_Nullable)superView;
- (instancetype _Nonnull)initWithObserveView: (UIView *_Nullable)view observerSuperView: (UIView *_Nullable)superView;
- (instancetype _Nonnull)initWithDelegate: (id<SHPKeyboardAwarenessClient> _Nullable) delegate observerSuperView: (UIView *_Nullable)superView;
- (instancetype _Nonnull)initWithObserveView: (UIView *_Nullable)view delegate: (id<SHPKeyboardAwarenessClient> _Nullable) delegate observerSuperView: (UIView *_Nullable)superView;

/// The receiver will get keyboard events during its life time. The receiver must implement the keyboardTriggeredEvent: method as defined
/// in the SHPKeyboardAwarenessClient protocol. Does not currently support events for rotation while the keyboard is visible. If required, use
/// ObserveView:observerSuperView: instead.
/// @param observerSuperView The view that contains the observed views, the Observer will not callback with events that are not childViews of the superView
+ (instancetype _Nonnull)ObserveWithObserverSuperView: (UIView *_Nullable)superView;

/// The receiver will get keyboard events during its life time. The receiver must implement the keyboardTriggeredEvent: method as defined
/// in the SHPKeyboardAwarenessClient protocol. Does not currently support events for rotation while the keyboard is visible. If required, use
/// ObserveView:withDelegate:observerSuperView: instead.
/// @param delegate The delegate to receive keyboardevents
/// @param observerSuperView The view that contains the observed views, the Observer will not callback with events that are not childViews of the superView
+ (instancetype _Nonnull)ObserveWithDelegate: (id<SHPKeyboardAwarenessClient> _Nullable) delegate observerSuperView: (UIView *_Nullable)superView;

/// The receiver will get keyboard events during its life time. The receiver must implement the keyboardTriggeredEvent: method as defined
/// in the SHPKeyboardAwarenessClient protocol. Optionally, provide a view which you want to limit the events to. Keyboard events will be
/// sent, only when view conflicts with the keyboard bounds.
/// @param view The view you want to stay clear of the keyboard. Provide nil to get same functionality as ObserveWithObserverSuperView:
/// @param observerSuperView The view that contains the observed views, the Observer will not callback with events that are not childViews of the superView
+ (instancetype _Nonnull)ObserveView: (UIView *_Nullable)view observerSuperView: (UIView *_Nullable)superView;

/// The receiver will get keyboard events during its life time. The receiver must implement the keyboardTriggeredEvent: method as defined
/// in the SHPKeyboardAwarenessClient protocol. Optionally, provide a view which you want to limit the events to. Keyboard events will be
/// sent, only when view conflicts with the keyboard bounds.
/// @param view The view you want to stay clear of the keyboard. Provide nil to get same functionality as ObserveWithDelegate:observerSuperView:
/// @param delegate The delegate to receive keyboardevents
/// @param observerSuperView The view that contains the observed views, the Observer will not callback with events that are not childViews of the superView
+ (instancetype _Nonnull)ObserveView: (UIView *_Nullable)view withDelegate: (id<SHPKeyboardAwarenessClient> _Nullable) delegate observerSuperView: (UIView *_Nullable)superView;

@end
