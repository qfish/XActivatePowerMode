//
//  XPowerModeCommand.h
//  XActivatePowerMode
//
//  Created by QFish on 12/3/15.
//  Copyright © 2015 QFish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

// TODO: Detect typing speed, getting a combo ...

@interface XPowerModeCommand : NSObject

@property (nonatomic, assign) NSTextView * source;
@property (nonatomic, assign) CGPoint position;

@property (nonatomic, assign, readonly) BOOL isValid;

+ (instancetype)commandWithSource:(id)source position:(CGPoint)position;

@end

