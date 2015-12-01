//
//  XActivatePowerMode.h
//  XActivatePowerMode
//
//  Created by QFish on 12/1/15.
//  Copyright © 2015 QFish. All rights reserved.
//

#import <AppKit/AppKit.h>

@class XActivatePowerMode;

@interface XActivatePowerMode : NSObject

+ (instancetype)sharedPlugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;

@end