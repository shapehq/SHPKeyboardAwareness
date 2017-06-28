//
// Copyright (c) 2014-2016 SHAPE A/S. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHPEventInfo.h"
#import "SHPKeyboardInfo.h"


@implementation SHPEventInfo {

}

- (instancetype)init {
    if ( !(self = [super init])) { return nil; }
    return self;
}


- (id)copyWithZone:(NSZone *)zone {
    SHPEventInfo *copy = [[[self class] alloc] init];

    if( copy ) {
        copy.conflictView = self.conflictView;
        if( self.keyboardInfo) {
            copy.keyboardInfo = [SHPKeyboardInfo infoWithEventType:self.keyboardInfo.eventType frame:self.keyboardInfo.rect animationDuration:self.keyboardInfo.animationDuration animationOption:self.keyboardInfo.animationOption];
        }
        else {
            copy.keyboardInfo = nil;
        }
        
    }

    return copy;
}

@end
