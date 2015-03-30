//
// SHPKeyboardAwareness
// UITextField+Pretty.h
//
// Copyright (c) 2014-2015 SHAPE A/S. All rights reserved.
//


#import "UITextField+Pretty.h"

@implementation UITextField (Pretty)

+ (UITextField *)shp_prettyTextField {
    UITextField *textField = [UITextField new];
    textField.backgroundColor = [UIColor colorWithRed:24.0f/255.0f green:74.0f/255.0f blue:115.0f/255.0f alpha:1.0];
    textField.textAlignment = NSTextAlignmentCenter;
    textField.textColor = [UIColor whiteColor];
    textField.layer.cornerRadius = 2;
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Tap me" attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:24.0f/96.0f green:74.0f/159.0f blue:115.0f/205.0f alpha:1.0]}];
    return textField;
}

@end
