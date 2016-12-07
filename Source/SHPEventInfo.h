//
// Copyright (c) 2014-2016 SHAPE A/S. All rights reserved.
//

#import <UIKit/UIkit.h>

@class SHPKeyboardInfo;

@interface SHPEventInfo : NSObject <NSCopying>
@property (nonatomic, strong) UIView *conflictView;
@property (nonatomic, strong) SHPKeyboardInfo *keyboardInfo;
@end
