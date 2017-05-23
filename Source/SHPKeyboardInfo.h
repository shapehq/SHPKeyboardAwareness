//
// Copyright (c) 2014-2016 SHAPE A/S. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHPKeyboardEvent.h"


@interface SHPKeyboardInfo : NSObject
@property(nonatomic, readonly) SHPKeyboardEventType eventType;
@property(nonatomic, readonly) CGRect rect;
@property(nonatomic, readonly) NSTimeInterval animationDuration;
@property(nonatomic, readonly) UIViewAnimationCurve animationOption;

+ (SHPKeyboardInfo *)infoWithEventType:(SHPKeyboardEventType)eventType frame:(CGRect)keyboardRect animationDuration:(NSTimeInterval)animationDuration animationOption:(UIViewAnimationCurve)animationOption;
- (instancetype)initWithEventType:(SHPKeyboardEventType)eventType frame:(CGRect)keyboardRect animationDuration:(NSTimeInterval)animationDuration animationOption:(UIViewAnimationCurve)animationOption;

@end
