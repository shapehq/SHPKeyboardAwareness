//
// SHPKeyboardAwareness
// SHPKeyboardAwareness.h
//
// Copyright (c) 2014-2016 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol SHPKeyboardAwarenessClient;
@class SHPKeyboardAwarenessScrollViewClient;

/// The offsetType defines how the Observer will calculate the required offset
typedef NS_ENUM(NSUInteger, SHPKeyboardAwarenessOffsetType){
    /// (Default) Caret - the offset required to have Caret (insertion point) above the keyboard
    /// If set as offsetType, this will only apply if the observeView is a UITextView (or the observeView isn't set)
    SHPKeyboardAwarenessOffsetTypeCaret,
    /// Bottom - offset required to move the bottom of a view above the keyboard
    SHPKeyboardAwarenessOffsetTypeBottom,
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
/// @param superView The view that contains the observed views, the Observer will not callback with events that are not childViews of the superView
+ (instancetype _Nonnull)observeWithObserverSuperView: (UIView *_Nullable)superView;

/// The receiver will get keyboard events during its life time. The receiver must implement the keyboardTriggeredEvent: method as defined
/// in the SHPKeyboardAwarenessClient protocol. Does not currently support events for rotation while the keyboard is visible. If required, use
/// ObserveView:withDelegate:observerSuperView: instead.
/// @param delegate The delegate to receive keyboardevents
/// @param superView The view that contains the observed views, the Observer will not callback with events that are not childViews of the superView
+ (instancetype _Nonnull)observeWithDelegate:(id <SHPKeyboardAwarenessClient> _Nullable)delegate observerSuperView: (UIView *_Nullable)superView;

/// The receiver will get keyboard events during its life time. The receiver must implement the keyboardTriggeredEvent: method as defined
/// in the SHPKeyboardAwarenessClient protocol. Optionally, provide a view which you want to limit the events to. Keyboard events will be
/// sent, only when view conflicts with the keyboard bounds.
/// @param view The view you want to stay clear of the keyboard. Provide nil to get same functionality as ObserveWithObserverSuperView:
/// @param superView The view that contains the observed views, the Observer will not callback with events that are not childViews of the superView
+ (instancetype _Nonnull)observeView:(UIView *_Nullable)view observerSuperView: (UIView *_Nullable)superView;

/// The receiver will get keyboard events during its life time. The receiver must implement the keyboardTriggeredEvent: method as defined
/// in the SHPKeyboardAwarenessClient protocol. Optionally, provide a view which you want to limit the events to. Keyboard events will be
/// sent, only when view conflicts with the keyboard bounds.
/// @param view The view you want to stay clear of the keyboard. Provide nil to get same functionality as ObserveWithDelegate:observerSuperView:
/// @param delegate The delegate to receive keyboardevents
/// @param superView The view that contains the observed views, the Observer will not callback with events that are not childViews of the superView
+ (instancetype _Nonnull)observeView:(UIView *_Nullable)view withDelegate:(id <SHPKeyboardAwarenessClient> _Nullable)delegate observerSuperView: (UIView *_Nullable)superView;

/// Makes the observer observe and handle events for a scrollView. The observer will be the delegate for all events
/// If you don't wan't to handle the offset your self, then use this method, or, if the view isn't a ScrollView, you might wan't to use the ObserveView:verticalConstraint:conflictingViewPadding:
/// Note, if you set the delegate after initialisation, you'll have to handle the offset yourself
/// @param view The scrollView to observe
/// @param padding The padding will be added around a view that is obscured by the keyboard.
+ (instancetype _Nonnull)observeScrollView:(UIScrollView *_Nonnull)view conflictingViewPadding: (CGFloat)padding;

/// Makes the observer observe and handle events for a view. The observer will be the delegate for all events
/// Provide a vertical constraint, which the observer can use to reposition the view
/// Note, if you set the delegate after initialisation, you'll have to handle the offset yourself
/// @param view The view to observe
/// @param constraint Vertical constraint used to move the view
/// @param padding Padding will be added around the conflicting view
+ (instancetype _Nonnull)observeView:(UIView *_Nonnull)view verticalConstraint:(NSLayoutConstraint *_Nonnull)constraint conflictingViewPadding: (CGFloat)padding;
@end
