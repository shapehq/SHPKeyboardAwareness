//
// SHPKeyboardAwareness
// SHPKeyboardAwarenessScrollViewClient.m
//
// Copyright (c) 2014-2016 SHAPE A/S. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHPKeyboardAwarenessScrollViewClient.h"
#import "SHPKeyboardEvent.h"


@interface SHPKeyboardAwarenessScrollViewClient ()
@property(nonatomic, strong) UIScrollView *view;
@property(nonatomic, assign) CGFloat defaultBottomInset;
@property(nonatomic) CGFloat conflictingViewPadding;
@end

@implementation SHPKeyboardAwarenessScrollViewClient {

}
- (instancetype _Nonnull)initWithView:(UIScrollView *_Nonnull)view conflictingViewPadding:(CGFloat)padding {
    if( !(self = [super init])) {return nil;}
    self.view = view;
    self.defaultBottomInset = view.contentInset.bottom;
    self.conflictingViewPadding = padding;
    return self;
}

+ (instancetype _Nonnull)ClientWithView:(UIScrollView *_Nonnull)view conflictingViewPadding:(CGFloat)padding {
    return [[SHPKeyboardAwarenessScrollViewClient alloc] initWithView: view conflictingViewPadding: padding];
}

#pragma mark - SHPKeyboardAwarenessClient

- (void)keyboardTriggeredEvent:(SHPKeyboardEvent *)keyboardEvent {
    UIScrollView *scrollView = self.view;
    CGFloat offset = 0;
    if (keyboardEvent.keyboardEventType == SHPKeyboardEventTypeShow) {
        // Keyboard will be shown

        // Save the current offset of the text field
        keyboardEvent.originalOffset = scrollView.contentOffset.y;

        // Add the required offset plus some padding to have space between keyboard and text field
        offset = (scrollView.contentOffset.y - keyboardEvent.requiredViewOffset);
    }
    else if(keyboardEvent.keyboardEventType == SHPKeyboardEventTypeHide) {
        // Re-apply the original text field offset
        offset = keyboardEvent.originalOffset;
    }
    else if(keyboardEvent.keyboardEventType == SHPKeyboardEventTypeViewChanged) {
        offset = (scrollView.contentOffset.y - keyboardEvent.requiredViewOffset);
    }
    else if(keyboardEvent.keyboardEventType == SHPKeyboardEventTypeKeyboardFrameChanged) {
        offset = (scrollView.contentOffset.y - keyboardEvent.requiredViewOffset);
    }

    // Animate
    // Use the provided animation duration and curve to have the text field slide in the same pace as the keyboard

    [UIView animateWithDuration:keyboardEvent.keyboardAnimationDuration delay:0 options:keyboardEvent.keyboardAnimationOptionCurve animations:^{
        scrollView.contentInset = UIEdgeInsetsMake(scrollView.contentInset.top, scrollView.contentInset.left, offset > 0 ? keyboardEvent.keyboardFrame.size.height : self.defaultBottomInset, scrollView.contentInset.right);
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, offset);
    } completion:nil];
}

- (CGFloat)shpKeyboardAwarenessPaddingBetweenKeyboardAndView:(UIView *_Nonnull)view {
    return self.conflictingViewPadding;
}


@end