//
// SHPKeyboardAwareness
// NSObject+SHPKeyboardAwareness.m
//
// Copyright (c) 2014-2015 SHAPE A/S. All rights reserved.
//

#import "SHPKeyboardEvent.h"
#import "NSObject+SHPKeyboardAwareness.h"
#import "ReactiveCocoa.h"
#import "SHPKeyboardAwarenessClient.h"

static const CGAffineTransform kNormalRotation     = (CGAffineTransform){1,  0, -0,  1, 0, 0};
static const CGAffineTransform kRightRotation      = (CGAffineTransform){0, -1,  1,  0, 0, 0};
static const CGAffineTransform kLeftRotation       = (CGAffineTransform){0,  1, -1,  0, 0, 0};
static const CGAffineTransform kUpsideDownRotation = (CGAffineTransform){-1, 0, -0, -1, 0, 0};

@interface SHPKeyboardEvent (Mutability)

@property (nonatomic, strong) UIView *conflictingView;
@property (nonatomic, assign) CGFloat requiredViewOffset;
@property (nonatomic, assign) CGRect visibleScreenArea;
@property (nonatomic, assign) CGRect keyboardFrame;
@property (nonatomic, assign) CGFloat keyboardAnimationDuration;
@property (nonatomic, assign) UIViewAnimationCurve keyboardAnimationCurve;
@property (nonatomic, assign) SHPKeyboardEventType keyboardEventType;

@end

CGRect shp_normalizedFrame(CGRect frame, UIWindow *window) {
    CGAffineTransform transform = window.rootViewController.view.transform;
    CGRect windowFrame = window.frame;
    CGRect normalizedRect = frame;

    if (CGAffineTransformEqualToTransform(transform, kNormalRotation)) {

    }
    else if (CGAffineTransformEqualToTransform(transform, kLeftRotation)) {
        normalizedRect.origin.x = frame.origin.y;
        normalizedRect.origin.y = windowFrame.size.width - (frame.origin.x + frame.size.width);
        normalizedRect.size.width = frame.size.height;
        normalizedRect.size.height = frame.size.width;
    }
    else if (CGAffineTransformEqualToTransform(transform, kRightRotation)) {
        normalizedRect.origin.y = frame.origin.x;
        normalizedRect.origin.x = frame.origin.y;
        normalizedRect.size.width = frame.size.height;
        normalizedRect.size.height = frame.size.width;
    }
    else if (CGAffineTransformEqualToTransform(transform, kUpsideDownRotation)) {
        normalizedRect.origin.y = windowFrame.size.height - frame.size.height - frame.origin.y;
    }

    return normalizedRect;
}

@implementation NSObject (SHPKeyboardAwareness)

- (RACSignal *)shp_keyboardAwarenessSignal {
    return [self shp_keyboardAwarenessSignalForView:nil];
}

- (RACSignal *)shp_keyboardAwarenessSignalForView:(UIView *)view {

    RACSignal *keyboardNotificationSignal = [self shpka_rac_notifyUntilDealloc:UIKeyboardWillShowNotification];

    RACSignal *keyboardSignal = [keyboardNotificationSignal map:^id(NSNotification *notification) {
        return [notification userInfo];
    }];


    RACSignal *viewSignal = nil;
    RACSignal *combinedShowSignal = nil; // If a view is provided, it only signals once so combineLatest will do, otherwise we have to wait for both signals (zip)
    if (view) {
        viewSignal = [RACSignal return:view];
        combinedShowSignal = [RACSignal combineLatest:@[viewSignal,keyboardSignal]];
    }
    else {
        RACSignal *viewNotifications = [RACSignal merge:@[[self shpka_rac_notifyUntilDealloc:UITextFieldTextDidBeginEditingNotification],
                                                          [self shpka_rac_notifyUntilDealloc:UITextViewTextDidBeginEditingNotification]]];

        viewSignal = [[viewNotifications map:^id(NSNotification *notification) {
            return notification.object;
        }] filter:^BOOL(UIView *view) {
            Class ignoredClass1 = NSClassFromString(@"DCTextView"); // DCIntrospect messes with the first responder
            Class ignoredClass2 = NSClassFromString(@"_SHPKeyboardTextView"); // So does SHPKeyboard
            return ![view isKindOfClass:ignoredClass1] && ![view isKindOfClass:ignoredClass2];
        }];
        combinedShowSignal = [RACSignal zip:@[viewSignal,keyboardSignal]];
    }

    __block SHPKeyboardEvent *event = nil;

    // Keyboard will show
    RACSignal *showOffset = [combinedShowSignal map:^id(RACTuple *tuple) {
        RACTupleUnpack(UIView *view, NSDictionary *keyboardInfo) = tuple;

        // Window stuff
        UIWindow *window = view.window;

        // Keyboard stuff

        CGRect kbRect = [keyboardInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGRect normKeyboardRect = shp_normalizedFrame(kbRect, window);
        CGFloat keyboardTop = normKeyboardRect.origin.y;

        // View stuff
        CGRect viewBounds = view.bounds;
        CGRect viewRect = [view convertRect:viewBounds toView:nil];
        CGRect normViewBounds = shp_normalizedFrame(viewRect, window);
        CGFloat viewBottom = CGRectGetMaxY(normViewBounds);

        // Business stuff
        CGFloat offset = keyboardTop - viewBottom;
        offset = offset > 0 ? 0 : offset;

        CGRect visibleRect = shp_normalizedFrame(window.frame, window);
        visibleRect.size.height -= normKeyboardRect.size.height;

        // Encapsulation stuff
        event = [SHPKeyboardEvent new];
        event.requiredViewOffset = offset;
        event.conflictingView = view;
        event.visibleScreenArea = visibleRect;
        event.keyboardFrame = normKeyboardRect;
        event.keyboardAnimationDuration = [keyboardInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
        event.keyboardAnimationCurve = [keyboardInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
        event.keyboardEventType = SHPKeyboardEventTypeShow;

        return event;
    }];

    // Keyboard will hide
    RACSignal *hideOffset = [[self shpka_rac_notifyUntilDealloc:UIKeyboardWillHideNotification] map:^id(NSNotification *notification) {
        NSDictionary *keyboardInfo = notification.userInfo;

        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        CGRect normWindowRect = shp_normalizedFrame(window.frame, window);

        event.requiredViewOffset = 0;
        event.conflictingView = nil;
        event.visibleScreenArea = normWindowRect;
        event.keyboardFrame = CGRectZero;
        event.keyboardAnimationDuration = [keyboardInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
        event.keyboardAnimationCurve = [keyboardInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
        event.keyboardEventType = SHPKeyboardEventTypeHide;

        return event;
    }];

    return [RACSignal merge:@[showOffset, hideOffset]];
}

- (void)shp_engageKeyboardAwareness {
    [self shp_engageKeyboardAwarenessForView:nil];
}

- (void)shp_engageKeyboardAwarenessForView:(UIView *)view {
    NSAssert([self respondsToSelector:@selector(keyboardTriggeredEvent:)], @"%@ engaged keyboard awareness, but does not respond to shp_keyboardTriggeredEvent:", self);

    [self rac_liftSelector:@selector(keyboardTriggeredEvent:) withSignals:[self shp_keyboardAwarenessSignalForView:view], nil];
}

#pragma mark - Private

- (RACSignal *)shpka_rac_notifyUntilDealloc:(NSString *)notificationName {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    return [[notificationCenter rac_addObserverForName:notificationName object:nil] takeUntil:[self rac_willDeallocSignal]];
}

@end
