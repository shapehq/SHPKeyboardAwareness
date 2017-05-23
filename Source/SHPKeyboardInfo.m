//
// Copyright (c) 2014-2016 SHAPE A/S. All rights reserved.
//

#import "SHPKeyboardInfo.h"
#import "SHPKeyboardEvent.h"


@interface SHPKeyboardInfo ()
@property(nonatomic) SHPKeyboardEventType eventType;
@property(nonatomic) CGRect rect;
@property(nonatomic) NSTimeInterval animationDuration;
@property(nonatomic) UIViewAnimationCurve animationOption;
@end

@implementation SHPKeyboardInfo {

}
+ (SHPKeyboardInfo *)infoWithEventType:(SHPKeyboardEventType)eventType frame:(CGRect)keyboardRect animationDuration:(NSTimeInterval)animationDuration animationOption:(UIViewAnimationCurve)animationOption {
    return [[SHPKeyboardInfo alloc] initWithEventType: eventType frame: keyboardRect animationDuration: animationDuration animationOption: animationOption];
}

- (instancetype)initWithEventType:(SHPKeyboardEventType)eventType frame:(CGRect)keyboardRect animationDuration:(NSTimeInterval)animationDuration animationOption:(UIViewAnimationCurve)animationOption {
    if( !(self = [super init])) { return nil; }
    self.eventType = eventType;
    self.rect = keyboardRect;
    self.animationDuration = animationDuration;
    self.animationOption = animationOption; 
    return self;
}
@end
