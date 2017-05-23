//
// SHPKeyboardAwareness
// SHPKeyboardAwareness.m
//
// Copyright (c) 2014-2016 SHAPE A/S. All rights reserved.
//

#import "SHPKeyboardEvent.h"
#import "SHPKeyboardAwarenessObserver.h"
#import "SHPKeyboardAwarenessClient.h"
#import "SHPEventInfo.h"
#import "SHPKeyboardInfo.h"
#import "SHPKeyboardAwarenessScrollViewClient.h"
#import "SHPKeyboardAwarenessConstraintClient.h"

static const CGAffineTransform kNormalRotation     = (CGAffineTransform){1,  0, -0,  1, 0, 0};
static const CGAffineTransform kRightRotation      = (CGAffineTransform){0, -1,  1,  0, 0, 0};
static const CGAffineTransform kLeftRotation       = (CGAffineTransform){0,  1, -1,  0, 0, 0};
static const CGAffineTransform kUpsideDownRotation = (CGAffineTransform){-1, 0, -0, -1, 0, 0};

@interface SHPKeyboardEvent (Mutability)

@property (nonatomic, strong) UIView *conflictingView;

@property (nonatomic, assign) CGFloat requiredViewOffset;
@property (nonatomic, assign) CGRect visibleScreenArea;
@property (nonatomic, assign) CGRect keyboardFrame;
@property (nonatomic, assign) NSTimeInterval keyboardAnimationDuration;
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

@interface SHPKeyboardAwarenessObserver()
@property (nonatomic, strong) SHPKeyboardEvent *event;
@property (nonatomic, strong) SHPEventInfo *eventInfo;
@property (nonatomic, strong) UIView *presetConflictingView;

/// For default observing of views
@property (nonatomic, strong, nullable) id client;
@end

@implementation SHPKeyboardAwarenessObserver

#pragma mark - setup
- (instancetype)initWithObserverSuperView:(UIView *)superView {
    if( !(self = [self initWithObserveView:nil delegate:nil observerSuperView:superView])){ return nil;}
    return self;
}

- (instancetype)initWithObserveView:(UIView *_Nullable)view observerSuperView:(UIView *)superView {
    if( !(self = [self initWithObserveView:view delegate:nil observerSuperView:superView])){ return nil;}
    return self;
}

- (instancetype)initWithDelegate:(id <SHPKeyboardAwarenessClient> _Nullable)delegate observerSuperView:(UIView * _Nullable)superView {
    if( !(self = [self initWithObserveView:nil delegate:delegate observerSuperView:superView])){ return nil;}
    return self;
}

- (instancetype)initWithObserveView:(UIView *_Nullable)view delegate:(id <SHPKeyboardAwarenessClient> _Nullable)delegate observerSuperView:(UIView * _Nullable)superView {
    if( !(self = [super init])) { return nil; }
    _eventInfo = [SHPEventInfo new];

    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

    self.delegate = delegate;
    self.presetConflictingView = view;
    self.observerSuperView = superView;
    
    [notificationCenter addObserver:self selector:@selector(viewNotification:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(viewNotification:) name:UITextViewTextDidBeginEditingNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(viewNotification:) name:UITextInputCurrentInputModeDidChangeNotification object:nil];

    [notificationCenter addObserver:self selector:@selector(keyboardNotification:) name:UIKeyboardWillShowNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(keyboardNotification:) name:UIKeyboardWillHideNotification object:nil];
    return self;
}

#pragma mark - Convenience
+ (instancetype)observeWithObserverSuperView:(UIView *_Nullable)superView {
    return [[SHPKeyboardAwarenessObserver alloc] initWithObserveView:nil delegate:nil observerSuperView:superView];
}

+ (instancetype)observeWithDelegate:(id <SHPKeyboardAwarenessClient> _Nullable)delegate observerSuperView:(UIView * _Nullable)superView {
    return [[SHPKeyboardAwarenessObserver alloc] initWithObserveView:nil delegate:delegate observerSuperView:superView];
}

+ (instancetype)observeView:(UIView *_Nullable)view observerSuperView:(UIView * _Nullable)superView {
    return [[SHPKeyboardAwarenessObserver alloc] initWithObserveView:view delegate:nil observerSuperView:superView];
}

+ (instancetype)observeView:(UIView *_Nullable)view withDelegate:(id <SHPKeyboardAwarenessClient> _Nullable)delegate observerSuperView:(UIView * _Nullable)superView {
    return [[SHPKeyboardAwarenessObserver alloc] initWithObserveView:view delegate:delegate observerSuperView:superView];
}

+ (instancetype _Nonnull)observeScrollView:(UIScrollView *_Nonnull)view conflictingViewPadding: (CGFloat)padding {
    SHPKeyboardAwarenessScrollViewClient *observerClient = [SHPKeyboardAwarenessScrollViewClient clientWithView:view conflictingViewPadding:padding];
    SHPKeyboardAwarenessObserver *observer = [[SHPKeyboardAwarenessObserver alloc] initWithObserveView:nil delegate:observerClient observerSuperView:view];
    observer.client = observerClient;
    return observer;
}

+ (instancetype _Nonnull)observeView:(UIView *_Nonnull)view verticalConstraint:(NSLayoutConstraint *_Nonnull)constraint conflictingViewPadding: (CGFloat)padding {
    SHPKeyboardAwarenessConstraintClient *observerClient = [SHPKeyboardAwarenessConstraintClient clientWithView:view verticalConstraint:constraint conflictingViewPadding:padding];
    SHPKeyboardAwarenessObserver *observer = [[SHPKeyboardAwarenessObserver alloc] initWithObserveView:nil delegate:observerClient observerSuperView:view];
    observer.client = observerClient;
    return observer;
}


#pragma mark - Teardown
- (void)dealloc {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
    [notificationCenter removeObserver:self name:UITextViewTextDidBeginEditingNotification object:nil];
    [notificationCenter removeObserver:self name:UITextInputCurrentInputModeDidChangeNotification object:nil];

    [notificationCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [notificationCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Notifications handling
- (void)viewNotification: (NSNotification *_Nonnull)notification {

    // Get the conflicting view
    // We only get the view, if the view to observe is not set on initialization
    if([notification.object isKindOfClass:[UIView class]]) {
        Class ignoredClass1 = NSClassFromString(@"DCTextView"); // DCIntrospect messes with the first responder
        Class ignoredClass2 = NSClassFromString(@"_SHPKeyboardTextView"); // So does SHPKeyboard

        UIView *view = (UIView *)notification.object;
        if(![view isKindOfClass:ignoredClass1] && ![view isKindOfClass:ignoredClass2]) {
            
            BOOL handleKeyboardEventsForView = NO;
            if(self.presetConflictingView) {
                if([self.presetConflictingView isEqual:view]){
                    handleKeyboardEventsForView = YES;
                }
                else if( [self isView:view aSubviewOfView:self.presetConflictingView]) {
                    handleKeyboardEventsForView = YES;
                }
            }
            else if( self.observerSuperView ) {
                if( [self isView:view aSubviewOfView:self.observerSuperView]) {
                    handleKeyboardEventsForView = YES;
                }
            }
            else {
                handleKeyboardEventsForView = YES;
            }
            if( handleKeyboardEventsForView ) {
                if( self.offsetType == SHPKeyboardAwarenessOffsetTypeCaret && [view isKindOfClass:[UITextView class]]) {
                    // We need to set the view assync, otherwise, we will be served the wrong frame for the selected textRange on the UITextView
                    // This might cause the offset to be calculated wrong
                    dispatch_async(dispatch_get_main_queue(), ^{
                        SHPEventInfo *eventInfoCopy = [self.eventInfo copy];
                        eventInfoCopy.conflictView = self.presetConflictingView?: view;
                        self.eventInfo = eventInfoCopy;
                    });
                }
                else {
                    SHPEventInfo *eventInfoCopy = [self.eventInfo copy];
                    eventInfoCopy.conflictView = self.presetConflictingView?: view;
                    self.eventInfo = eventInfoCopy;
                }
            }
        }
    }
}

- (BOOL)isView: (UIView *)view aSubviewOfView: (UIView *)potentialParentView {
    BOOL isSubview = NO;
    if([view.superview isEqual:potentialParentView]) {
        isSubview = YES;
    }
    else if( view.superview ) {
        isSubview = [self isView:view.superview aSubviewOfView:potentialParentView];
    }
    return isSubview;
}

- (void)keyboardNotification: (NSNotification *_Nonnull)notification {

    if( notification.userInfo == nil ) { return; }
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = (UIViewAnimationCurve)[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];


    if( [notification.name isEqualToString:UIKeyboardWillShowNotification] ) {
        SHPEventInfo *eventInfoCopy = [self.eventInfo copy];
        eventInfoCopy.keyboardInfo = [SHPKeyboardInfo infoWithEventType:SHPKeyboardEventTypeShow frame:keyboardFrame animationDuration:animationDuration animationOption:animationCurve];
        self.eventInfo = eventInfoCopy;
    }
    else if( [notification.name isEqualToString:UIKeyboardWillHideNotification] ) {
        SHPEventInfo *eventInfoCopy = [self.eventInfo copy];
        eventInfoCopy.keyboardInfo = [SHPKeyboardInfo infoWithEventType:SHPKeyboardEventTypeHide frame:CGRectZero animationDuration:animationDuration animationOption:animationCurve];
        self.eventInfo = eventInfoCopy;
    }
}

#pragma mark - Event handling
- (void)setEventInfo:(SHPEventInfo *)eventInfo {
    SHPKeyboardEvent *keyboardEvent;
    if( eventInfo.conflictView != nil && eventInfo.keyboardInfo != nil && _eventInfo.keyboardInfo != nil) {
        // Change view/keyboard or hide keyboard
        // this is at least a second time we are called

        if( !CGRectEqualToRect(eventInfo.keyboardInfo.rect, _eventInfo.keyboardInfo.rect) || eventInfo.keyboardInfo.eventType != _eventInfo.keyboardInfo.eventType ) {
            // keyboard is changing
            if(eventInfo.keyboardInfo.eventType == SHPKeyboardEventTypeHide) {
                keyboardEvent = [self hideEventWithExistingEvent:self.event keyboardInfo:eventInfo.keyboardInfo conflictingView:eventInfo.conflictView];
            }
            else {
                keyboardEvent = [self showEventWithKeyboardInfo:eventInfo.keyboardInfo conflictingView:eventInfo.conflictView];
                keyboardEvent.originalOffset = self.event.originalOffset;
                keyboardEvent.keyboardEventType = SHPKeyboardEventTypeKeyboardFrameChanged;
            }
        }
        else if( ![_eventInfo.conflictView isEqual:eventInfo.conflictView] ) {
            // view is changing
            keyboardEvent = [self showEventWithKeyboardInfo:eventInfo.keyboardInfo conflictingView:eventInfo.conflictView];
            keyboardEvent.originalOffset = self.event.originalOffset;
            keyboardEvent.keyboardEventType = SHPKeyboardEventTypeViewChanged;
        }

    }
    else if( eventInfo.conflictView != nil && eventInfo.keyboardInfo != nil && eventInfo.keyboardInfo.eventType == SHPKeyboardEventTypeShow) {
        // Show keyboard
        keyboardEvent = [self showEventWithKeyboardInfo:eventInfo.keyboardInfo conflictingView:eventInfo.conflictView];
    }
    

    if( keyboardEvent != nil ) {
        if(self.delegate) {
            [self.delegate keyboardTriggeredEvent:keyboardEvent];
        }
        self.event = keyboardEvent;
    }

    if( eventInfo != nil && eventInfo.keyboardInfo.eventType == SHPKeyboardEventTypeHide ) {
        // clean up
        _eventInfo.keyboardInfo = nil;
        _eventInfo.conflictView = nil;

        self.event = nil;
    }
    else {
        _eventInfo = eventInfo;
    }
}

- (CGRect)selectedRectForTextInput: (id<UITextInput>)textInput {
    UITextRange *selectedTextRange = [textInput selectedTextRange];
    if( selectedTextRange ) {
        NSArray<UITextSelectionRect *> *textRanges = [textInput selectionRectsForRange:selectedTextRange];
        if(textRanges.firstObject) {
            UITextSelectionRect *firstRange = textRanges.firstObject;
            return firstRange.rect;
        }
        else {
            return CGRectZero;
        }
    }
    return CGRectZero;
}

- (SHPKeyboardEvent *)showEventWithKeyboardInfo: (SHPKeyboardInfo *)keyboardInfo conflictingView: (UIView *)view {
    // Window stuff
    UIWindow *window = view.window;

    // Keyboard stuff
    CGRect normKeyboardRect = shp_normalizedFrame(keyboardInfo.rect, window);
    CGFloat keyboardTop = normKeyboardRect.origin.y;

    // View stuff
    CGRect viewBounds = view.bounds;
    
    CGRect viewRect;
    if(self.offsetType == SHPKeyboardAwarenessOffsetTypeCaret && [view isKindOfClass:[UITextView class]]) {
        CGRect selectedRect = [self selectedRectForTextInput:(id<UITextInput>)view];
        if(CGRectEqualToRect(selectedRect, CGRectZero) || isinf(selectedRect.origin.x) || isinf(selectedRect.origin.y) || isinf(selectedRect.size.height) || isinf(selectedRect.size.width)) {
            viewRect = [view convertRect:viewBounds toView:nil];
        }
        else {
            viewRect = [view convertRect:selectedRect toView:nil];
        }
    }
    else {
        //self.offsetType == SHPKeyboardAwarenessOffsetTypeBottom
        viewRect = [view convertRect:viewBounds toView:nil];
    }
    CGRect normViewBounds = shp_normalizedFrame(viewRect, window);

    // Additional padding around the view
    if(self.delegate && [self.delegate respondsToSelector:@selector(shpKeyboardAwarenessPaddingBetweenKeyboardAndView:)]) {
        normViewBounds = CGRectInset(normViewBounds, 0, -1 * [self.delegate shpKeyboardAwarenessPaddingBetweenKeyboardAndView:view]);
    }

    CGFloat viewBottom = CGRectGetMaxY(normViewBounds);
    
    // Business stuff
    CGFloat offset = keyboardTop - viewBottom;
    offset = offset > 0 ? 0 : isinf(offset) ? 0 : offset;
    

    CGRect visibleRect = shp_normalizedFrame(window.frame, window);
    visibleRect.size.height -= normKeyboardRect.size.height;

    // Encapsulation stuff
    SHPKeyboardEvent *event = [SHPKeyboardEvent new];
    event.requiredViewOffset = offset;
    event.conflictingView = view;
    event.visibleScreenArea = visibleRect;
    event.keyboardFrame = normKeyboardRect;
    event.keyboardAnimationDuration = keyboardInfo.animationDuration;
    event.keyboardAnimationCurve = keyboardInfo.animationOption;
    event.keyboardEventType = SHPKeyboardEventTypeShow;

    return event;
}

- (SHPKeyboardEvent *)hideEventWithExistingEvent:(SHPKeyboardEvent *)event keyboardInfo: (SHPKeyboardInfo *)keyboardInfo conflictingView: (UIView *)view {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGRect normWindowRect = shp_normalizedFrame(window.frame, window);

    event.requiredViewOffset = 0;
    event.conflictingView = nil;
    event.visibleScreenArea = normWindowRect;
    event.keyboardFrame = CGRectZero;
    event.keyboardAnimationDuration = keyboardInfo.animationDuration;
    event.keyboardAnimationCurve = keyboardInfo.animationOption;
    event.keyboardEventType = SHPKeyboardEventTypeHide;

    return event;
}

@end
