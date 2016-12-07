//
//  DualInputsViewController.m
//  SHPKeyboardAwarenessExample
//
// Copyright (c) 2014-2016 SHAPE A/S. All rights reserved.
//

@import SHPKeyboardAwareness;

#import "DualInputsViewController.h"
#import "UITextField+Pretty.h"

@interface DualInputsViewController () <UITextFieldDelegate, SHPKeyboardAwarenessClient>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UITextView *longTextField;

@property (nonatomic, strong) SHPKeyboardAwarenessObserver *keyboardAwareness;
@end

@implementation DualInputsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    [self setupSubviews];

    // Subscribe to keyboard events. The receiver (self in this case) will be automatically unsubscribed when deallocated
    self.keyboardAwareness = [SHPKeyboardAwarenessObserver ObserveView:self.longTextField withDelegate:self observerSuperView:self.view];
//    self.keyboardAwareness = [SHPKeyboardAwarenessObserver ObserveWithDelegate:self];
}

- (void)setupSubviews {
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.textField.translatesAutoresizingMaskIntoConstraints = NO;
    self.longTextField.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.containerView];
    [self.containerView addSubview:self.textField];
    [self.containerView addSubview:self.longTextField];

    // Make the auto layout constraints
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];

    [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];

    [self.containerView addConstraints:@[
        [NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeTop multiplier:1 constant:350],
        [NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeLeading multiplier:1 constant:50],
        [NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-50],
        [NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:44.0],

        [NSLayoutConstraint constraintWithItem:self.longTextField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.textField attribute:NSLayoutAttributeBottom multiplier:1 constant:50],
        [NSLayoutConstraint constraintWithItem:self.longTextField attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeLeading multiplier:1 constant:50],
        [NSLayoutConstraint constraintWithItem:self.longTextField attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-50],
        [NSLayoutConstraint constraintWithItem:self.longTextField attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeBottom multiplier:1 constant:-50],
    ]];
}

#pragma mark - SHPKeyboardAwarenessClient

- (void)keyboardTriggeredEvent:(SHPKeyboardEvent *)keyboardEvent {
    CGFloat offset = 0;
    if (keyboardEvent.keyboardEventType == SHPKeyboardEventTypeShow) {
        // Keyboard will be shown
        
        // Save the current offset of the text field
        keyboardEvent.originalOffset = self.scrollView.contentOffset.y;
        
        // Add the required offset plus some padding to have space between keyboard and text field
        offset = (self.scrollView.contentOffset.y - keyboardEvent.requiredViewOffset);
    }
    else if(keyboardEvent.keyboardEventType == SHPKeyboardEventTypeHide) {
        // Re-apply the original text field offset
        offset = keyboardEvent.originalOffset;
    }
    else if(keyboardEvent.keyboardEventType == SHPKeyboardEventTypeViewChanged) {
        offset = (self.scrollView.contentOffset.y - keyboardEvent.requiredViewOffset);
    }
    else if(keyboardEvent.keyboardEventType == SHPKeyboardEventTypeKeyboardFrameChanged) {
        offset = (self.scrollView.contentOffset.y - keyboardEvent.requiredViewOffset);
    }
    
    // Animate
    // Use the provided animation duration and curve to have the text field slide in the same pace as the keyboard
    [UIView animateWithDuration:keyboardEvent.keyboardAnimationDuration delay:0 options:keyboardEvent.keyboardAnimationOptionCurve animations:^{
        self.scrollView.contentInset = UIEdgeInsetsMake(self.scrollView.contentInset.top, self.scrollView.contentInset.left, offset, self.scrollView.contentInset.right);
        self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x, offset);
    } completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Lazy Initialization

- (UIScrollView *)scrollView {
    if(!_scrollView) {
        _scrollView = [UIScrollView new];
        _scrollView.alwaysBounceVertical = YES;
        _scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }
    return _scrollView;
}

- (UIView *)containerView {
    if(!_containerView) {
        _containerView = [UIView new];
    }
    return _containerView;
}


- (UITextField *)textField {
    if (!_textField) {
        _textField = [UITextField shp_prettyTextField];
        _textField.text = @"Short text";
        _textField.delegate = self;
    }
    return _textField;
}

- (UITextView *)longTextField {
    if (!_longTextField) {
        _longTextField = [UITextView new];
        _longTextField.scrollEnabled = NO;
        _longTextField.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";

    }
    return _longTextField;
}

@end