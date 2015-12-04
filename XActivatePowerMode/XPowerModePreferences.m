//
//  XPowerModePreferences.m
//  XActivatePowerMode
//
//  Created by QFish on 12/3/15.
//  Copyright © 2015 QFish. All rights reserved.
//

#import "XPowerModePreferences.h"

NSString * const kXActivatePowerModeEnabled = @"qfi.sh.xcodeplugin.activatepowermode.enabled";

@interface XPowerModePreferences ()
@property (nullable, readwrite) NSMenu * menu;
@property (nonnull, strong) NSMenuItem * enabledMenuItem;
@property (nonatomic, assign) BOOL shouldShake;
@property (nonatomic, strong) NSMutableDictionary * config;
@end

@implementation XPowerModePreferences

@synthesize enabled = _enabled;

+ (instancetype)standardPrefreneces
{
    static XPowerModePreferences * c = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        c = [[self alloc] init];
    });
    return c;
}

- (void)setEnabled:(BOOL)enabled
{
    if ( _enabled == enabled )
        return;
    
    _enabled = enabled;
    
    if ( self.delegate && [self.delegate respondsToSelector:@selector(didXPowerModePreferencesUpdate:)] ) {
        [self.delegate didXPowerModePreferencesUpdate:self];
    }
    
    [self updateUserDefaultsWithEnabled:enabled];
    [self updateMenus];
}

- (void)updateUserDefaultsWithEnabled:(BOOL)enabled
{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kXActivatePowerModeEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)initialize
{
    NSNumber * value = [[NSUserDefaults standardUserDefaults] objectForKey:kXActivatePowerModeEnabled];
    
    if ( value == nil )
    {
        [self updateUserDefaultsWithEnabled:YES];
        _enabled = YES;
    }
    else
    {
        _enabled = [value boolValue];
    }
    
    [self setupMenu];
}

#pragma mark - Menus

- (void)setupMenu
{
    NSMenuItem * mainItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    
    if ( mainItem )
    {
        [[mainItem submenu] addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem * menuItem = [[NSMenuItem alloc] init];
        menuItem.title = @"Activate Power Mode";
        [[mainItem submenu] addItem:menuItem];
        
        NSMenu * menu = [[NSMenu alloc] init];
        menuItem.submenu = menu;
        
        NSMenuItem * enabledMenuItem = [[NSMenuItem alloc] init];
        enabledMenuItem.title = @"Enable";
        enabledMenuItem.action = @selector(toggleEnabled:);
        enabledMenuItem.target = self;
        [menu addItem:enabledMenuItem];
        self.enabledMenuItem = enabledMenuItem;

        self.menu = menu;
        
        if ( self.delegate && [self.delegate respondsToSelector:@selector(didXPowerModeMenusSetup:)] ) {
            [self.delegate didXPowerModeMenusSetup:self];
        }
    }
}

- (void)toggleEnabled:(id)sender
{
    self.enabled = !self.enabled;
}

- (void)updateMenus
{
    self.enabledMenuItem.state = self.enabled;
    
    if ( self.delegate && [self.delegate respondsToSelector:@selector(didXPowerModeMenusUpdate:)] ) {
        [self.delegate didXPowerModeMenusUpdate:self];
    }
}

- (nullable id)objectForKeyedSubscript:(id)key
{
    return self.config[key];
}

- (void)setObject:(nullable id)obj forKeyedSubscript:(id <NSCopying>)key
{
    
}

@end
