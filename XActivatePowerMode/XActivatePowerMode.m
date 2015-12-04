//
//  XActivatePowerMode.m
//  XActivatePowerMode
//
//  Created by QFish on 12/1/15.
//  Copyright © 2015 QFish. All rights reserved.
//

#import "XActivatePowerMode.h"
#import "XPowerModeCommander.h"

static XActivatePowerMode * __sharedPlugin = nil;

@interface XActivatePowerMode()

@property (nonatomic, weak) NSMenuItem * enabledMenuItem;

@property (nonatomic, strong) NSBundle * bundle;
@property (nonatomic, strong) XPowerModeCommander * commander;

@end

@implementation XActivatePowerMode

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    __sharedPlugin = [[XActivatePowerMode alloc] initWithBundle:plugin];
}

+ (instancetype)sharedPlugin
{
    return __sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init])
    {
        self.commander = [[XPowerModeCommander alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    
    [self.commander gogogo];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
