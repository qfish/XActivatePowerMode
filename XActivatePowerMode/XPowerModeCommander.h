//
//  Commander.h
//  XActivatePowerMode
//
//  Created by QFish on 12/3/15.
//  Copyright © 2015 QFish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XPowerModePreferences.h"
#import "XPowerModeHero.h"

@interface XPowerModeCommander : NSObject

@property (nonnull, strong) XPowerModePreferences * preferences;

- (void)gogogo;

- (void)addHero:(nonnull id<XPowerModeHero>)hero;
- (void)removeHero:(nonnull id<XPowerModeHero>)hero;

@end
