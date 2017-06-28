//
// SHPKeyboardAwareness
// AdvancedViewController.m
//
// Copyright (c) 2014-2016 SHAPE A/S. All rights reserved.
//

@import SHPKeyboardAwareness;

#import "AdvancedViewController.h"
#import "UITextField+Pretty.h"

@interface AdvancedViewController () <UITextFieldDelegate, SHPKeyboardAwarenessClient>

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) NSLayoutConstraint *bottomConstraint;


@property(nonatomic, strong) SHPKeyboardAwarenessObserver *keyboardAwareness;
@end

@implementation AdvancedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupSubviews];
    
    // Subscribe to keyboard events. The receiver (self in this case) will be automatically unsubscribed when deallocated
    self.keyboardAwareness = [SHPKeyboardAwarenessObserver observeView:self.containerView observerSuperView:self.view];
    self.keyboardAwareness.delegate = self;
}

- (void)setupSubviews {
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.textField.translatesAutoresizingMaskIntoConstraints = NO;
    self.button.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.textField];
    [self.containerView addSubview:self.button];
    
    // Make the auto layout constraints
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    // Save the bottom constraint so that we can animate it when the keyboard appears
    self.bottomConstraint = [NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-150];
    
    [self.view addConstraint:self.bottomConstraint];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:-100]];
    
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeLeft multiplier:1 constant:10]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeTop multiplier:1 constant:10]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeRight multiplier:1 constant:-10]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:36.0]];

    
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeLeft multiplier:1 constant:10]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.textField attribute:NSLayoutAttributeBottom multiplier:1 constant:10]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeRight multiplier:1 constant:-10]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeBottom multiplier:1 constant:-10]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:36.0]];
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
    else if(keyboardEvent.keyboardEventType == SHPKeyboardEventTypeHide) {
        // Re-apply the original text field offset
        offset = keyboardEvent.originalOffset;
    }
    else if(keyboardEvent.keyboardEventType == SHPKeyboardEventTypeViewChanged) {
        offset = self.bottomConstraint.constant + keyboardEvent.requiredViewOffset - 10;
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

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [UIView new];
        _containerView.backgroundColor = [UIColor colorWithRed:16.0f/255.0f green:49.0f/255.0f blue:77.0f/255.0f alpha:1.0];
    }
    return _containerView;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [UITextField shp_prettyTextField];
        _textField.delegate = self;
    }
    return _textField;
}

- (UIButton *)button {
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.backgroundColor = [UIColor colorWithRed:233.0f/255.0f green:77.0f/255.0f blue:58.0f/255.0f alpha:1.0];
        _button.layer.cornerRadius = 2.0;
        [_button setTitle:@"Hit Me" forState:UIControlStateNormal];
    }
    return _button;
}

@end
