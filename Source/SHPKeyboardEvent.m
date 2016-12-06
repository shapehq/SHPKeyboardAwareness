//
// SHPKeyboardAwareness
// SHPKeyboardEvent.m
//
// Copyright (c) 2014-2016 SHAPE A/S. All rights reserved.
//

#import "SHPKeyboardEvent.h"

@implementation SHPKeyboardEvent

- (void)setConflictingView:(UIView *)conflictingView {
    _conflictingView = conflictingView;
}

- (void)setRequiredViewOffset:(CGFloat)requiredViewOffset {
    _requiredViewOffset = requiredViewOffset;
}

- (void)setVisibleScreenArea:(CGRect)visibleScreenArea {
    _visibleScreenArea = visibleScreenArea;
}

- (void)setKeyboardFrame:(CGRect)keyboardFrame {
    _keyboardFrame = keyboardFrame;
}

- (void)setKeyboardAnimationDuration:(NSTimeInterval)keyboardAnimationDuration {
    _keyboardAnimationDuration = keyboardAnimationDuration;
}

- (void)setKeyboardAnimationCurve:(UIViewAnimationCurve)keyboardAnimationCurve {
    _keyboardAnimationCurve = keyboardAnimationCurve;
}

- (UIViewAnimationOptions)keyboardAnimationOptionCurve {
    NSAssert(UIViewAnimationCurveLinear << 16 == UIViewAnimationOptionCurveLinear, @"Unexpected implementation of UIViewAnimationCurve");
    
    return self.keyboardAnimationCurve << 16;
}

- (void)setKeyboardEventType:(SHPKeyboardEventType)keyboardEventType {
    _keyboardEventType = keyboardEventType;
}

@end
