//
//  XPowerModeHero.m
//  XActivatePowerMode
//
//  Created by QFish on 12/3/15.
//  Copyright © 2015 QFish. All rights reserved.
//

#import "XPowerModeHero.h"
#import "XActivatePowerMode.h"

@implementation XPowerModeHero

- (NSBundle *)bundle
{
    return [XActivatePowerMode sharedPlugin].bundle;
}

- (XPowerModePreferences *)preferences
{
    return [XPowerModePreferences standardPrefreneces];
}

@end
