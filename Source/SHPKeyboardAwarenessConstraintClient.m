//
// SHPKeyboardAwareness
// SHPKeyboardAwarenessConstraintClient.m
//
// Copyright (c) 2014-2016 SHAPE A/S. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHPKeyboardAwarenessConstraintClient.h"
#import "SHPKeyboardEvent.h"


@interface SHPKeyboardAwarenessConstraintClient ()
@property(nonatomic, strong) UIView *view;
@property(nonatomic, strong) NSLayoutConstraint *constraint;
@property(nonatomic) CGFloat constraintDefaultConstant;
@property(nonatomic) CGFloat conflictingViewPadding;
@end

@implementation SHPKeyboardAwarenessConstraintClient {

}
- (instancetype)initWithView:(UIView *)view verticalConstraint:(NSLayoutConstraint *)constraint conflictingViewPadding:(CGFloat)padding {
    if( !(self = [super init])) {return nil;}
    self.view = view;
    self.constraint = constraint;
    self.constraintDefaultConstant = constraint.constant;
    self.conflictingViewPadding = padding;
    return self;
}

+ (SHPKeyboardAwarenessConstraintClient *)clientWithView:(UIView *)view verticalConstraint:(NSLayoutConstraint *)constraint conflictingViewPadding:(CGFloat)padding {
    return [[SHPKeyboardAwarenessConstraintClient alloc] initWithView: view verticalConstraint: constraint conflictingViewPadding: padding];
}

#pragma mark - SHPKeyboardAwarenessClient

- (void)keyboardTriggeredEvent:(SHPKeyboardEvent *)keyboardEvent {
    CGFloat offset = 0;

    if (keyboardEvent.keyboardEventType == SHPKeyboardEventTypeShow) {
        // Keyboard will be shown

        // Save the current offset of the text field
        keyboardEvent.originalOffset = self.constraint.constant;

        // Add the required offset plus some padding to have space between keyboard and text field
        offset = self.constraint.constant + keyboardEvent.requiredViewOffset;
    }
    else if(keyboardEvent.keyboardEventType == SHPKeyboardEventTypeHide) {
        // Re-apply the original text field offset
        offset = keyboardEvent.originalOffset;
    }
    else if(keyboardEvent.keyboardEventType == SHPKeyboardEventTypeViewChanged) {
        offset = self.constraint.constant + keyboardEvent.requiredViewOffset;
    }
    else if(keyboardEvent.keyboardEventType == SHPKeyboardEventTypeKeyboardFrameChanged) {
        offset = self.constraint.constant + keyboardEvent.requiredViewOffset;
    }

    // Animate
    self.constraint.constant = offset;

    // Use the provided animation duration and curve to have the text field slide in the same pace as the keyboard
    [UIView animateWithDuration:keyboardEvent.keyboardAnimationDuration delay:0 options:keyboardEvent.keyboardAnimationOptionCurve animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (CGFloat)shpKeyboardAwarenessPaddingBetweenKeyboardAndView:(UIView *_Nonnull)view {
    return self.conflictingViewPadding;
}


@end