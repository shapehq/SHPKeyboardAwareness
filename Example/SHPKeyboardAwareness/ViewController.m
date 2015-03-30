//
// SHPKeyboardAwareness
// ViewController.m
//
// Copyright (c) 2014-2015 SHAPE A/S. All rights reserved.
//

#import "ViewController.h"
#import "SHPKeyboardAwareness.h"
#import "UITextField+Pretty.h"

@interface ViewController () <SHPKeyboardAwarenessClient, UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) NSLayoutConstraint *bottomConstraint;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    [self setupSubviews];
    
    // Subscribe to keyboard events. The receiver (self in this case) will be automatically unsubscribed when deallocated
    [self shp_engageKeyboardAwareness];
}

- (void)setupSubviews {
    self.textField.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.textField];
    
    // Make the auto layout constraints
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    // Save the bottom constraint so that we can animate it when the keyboard appears
    self.bottomConstraint = [NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-150];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:36.0]];
    
    [self.view addConstraint:self.bottomConstraint];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:-100]];
}

#pragma mark - SHPKeyboardAwarenessClient

- (void)keyboardTriggeredEvent:(SHPKeyboardEvent *)keyboardEvent {
    CGFloat offset = 0;
    
    if (keyboardEvent.keyboardEventType == SHPKeyboardEventTypeShow) {
        // Keyboard will be shown
        
        // Save the current offset of the text field
        keyboardEvent.originalOffset = self.bottomConstraint.constant;
        
        // Add the required offset plus some padding to have space between keyboard and text field
        offset = self.bottomConstraint.constant + keyboardEvent.requiredViewOffset - 10;
    }
    else {
        // Re-apply the original text field offset
        offset = keyboardEvent.originalOffset;
    }
    
    // Animate
    self.bottomConstraint.constant = offset;
    
    // Use the provided animation duration and curve to have the text field slide in the same pace as the keyboard
    [UIView animateWithDuration:keyboardEvent.keyboardAnimationDuration delay:0 options:keyboardEvent.keyboardAnimationOptionCurve animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Lazy Initialization

- (UITextField *)textField {
    if (!_textField) {
        _textField = [UITextField shp_prettyTextField];
        _textField.delegate = self;
    }
    return _textField;
}

@end
