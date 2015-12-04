//
//  XPowerModeHero.h
//  XActivatePowerMode
//
//  Created by QFish on 12/3/15.
//  Copyright © 2015 QFish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XPowerModePreferences.h"
#import "XPowerModeCommand.h"

@protocol XPowerModeHero <NSObject, XPowerModePreferencesDelegate>
@optional
- (void)onPowerModeCommand:(XPowerModeCommand *)command;
@end

@interface XPowerModeHero : NSObject <XPowerModeHero>
@property (nonatomic, strong, readonly) NSBundle * bundle;
@property (nonatomic, strong, readonly) XPowerModePreferences * preferences;
@end
