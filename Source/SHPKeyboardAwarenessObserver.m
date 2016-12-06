//
// SHPKeyboardAwareness
// SHPKeyboardAwareness.m
//
// Copyright (c) 2014-2016 SHAPE A/S. All rights reserved.
//

#import "SHPKeyboardEvent.h"
#import "SHPKeyboardAwarenessObserver.h"
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
@property(nonatomic) BOOL conflictingViewIsPreset;
@property(nonatomic, strong) UIView *conflictView;
@property(nonatomic, strong) SHPKeyboardEvent *event;
@end

@implementation SHPKeyboardAwarenessObserver

#pragma mark - setup
- (instancetype)initWithObserveView:(UIView *_Nullable)view {
    if( !(self = [super init])) { return nil; }
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

    // If there's no preset view, we need to grab it from the notifications in order to calculate the required offset
    self.conflictingViewIsPreset = view != nil;
    self.conflictView = view;
    if( view == nil ) {
        [notificationCenter addObserver:self selector:@selector(viewNotification:) name:UITextFieldTextDidBeginEditingNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(viewNotification:) name:UITextViewTextDidBeginEditingNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(viewNotification:) name:UITextInputCurrentInputModeDidChangeNotification object:nil];
    }

    [notificationCenter addObserver:self selector:@selector(keyboardNotification:) name:UIKeyboardWillShowNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(keyboardNotification:) name:UIKeyboardWillHideNotification object:nil];

    return self;
}

- (instancetype)init {
    if( !(self = [self initWithObserveView:nil])){ return nil;}
    return self;
}

+ (instancetype)Observer {
    return [[SHPKeyboardAwarenessObserver alloc] initWithObserveView:nil];
}

+ (instancetype)ObserverForView:(UIView *_Nullable)view {
    return [[SHPKeyboardAwarenessObserver alloc] initWithObserveView:view];
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

#pragma mark - Event handling
- (void)viewNotification: (NSNotification *_Nonnull)notification {

    // Get the conflicting view
    // We only get the view, if the view to observe is not set on initialization
    if([notification.object isKindOfClass:[UIView class]]) {
        Class ignoredClass1 = NSClassFromString(@"DCTextView"); // DCIntrospect messes with the first responder
        Class ignoredClass2 = NSClassFromString(@"_SHPKeyboardTextView"); // So does SHPKeyboard

        UIView *view = (UIView *)notification.object;
        if(![view isKindOfClass:ignoredClass1] && ![view isKindOfClass:ignoredClass2]) {
            self.conflictView = view;
        }
    }
}

- (void)keyboardNotification: (NSNotification *_Nonnull)notification {

    if( notification.userInfo == nil ) { return; }

    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSInteger animationCurve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];


    if( [notification.name isEqualToString:UIKeyboardWillShowNotification] ) {
        [self showEventWithKeyboardFrame:keyboardFrame animationDuration:animationDuration animationOption:animationCurve conflictingView:self.conflictView];
    }
    else if( [notification.name isEqualToString:UIKeyboardWillHideNotification] ) {
        [self hideEventWithKeyboardFrame:keyboardFrame animationDuration:animationDuration animationOption:animationCurve conflictingView:self.conflictView];
    }
}

- (void)showEventWithKeyboardFrame: (CGRect)kbRect animationDuration: (NSTimeInterval)duration animationOption: (UIViewAnimationCurve)option conflictingView: (UIView *)view {
    // Window stuff
    UIWindow *window = view.window;

    // Keyboard stuff

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
    self.event = [SHPKeyboardEvent new];
    self.event.requiredViewOffset = offset;
    self.event.conflictingView = view;
    self.event.visibleScreenArea = visibleRect;
    self.event.keyboardFrame = normKeyboardRect;
    self.event.keyboardAnimationDuration = duration;
    self.event.keyboardAnimationCurve = option;
    self.event.keyboardEventType = SHPKeyboardEventTypeShow;

    if(self.delegate) {
        [self.delegate keyboardTriggeredEvent:self.event];
    }
}

- (void)hideEventWithKeyboardFrame: (CGRect)_ animationDuration: (NSTimeInterval)duration animationOption: (UIViewAnimationCurve)option conflictingView: (UIView *)view {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGRect normWindowRect = shp_normalizedFrame(window.frame, window);

    self.event.requiredViewOffset = 0;
    self.event.conflictingView = nil;
    self.event.visibleScreenArea = normWindowRect;
    self.event.keyboardFrame = CGRectZero;
    self.event.keyboardAnimationDuration = duration;
    self.event.keyboardAnimationCurve = option;
    self.event.keyboardEventType = SHPKeyboardEventTypeHide;

    if(self.delegate) {
        [self.delegate keyboardTriggeredEvent:self.event];
    }

    if(!self.conflictingViewIsPreset) {
        self.conflictView = nil;
    }
    self.event = nil;
}

@end
