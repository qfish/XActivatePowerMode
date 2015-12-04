//
//  Player.m
//  XActivatePowerMode
//
//  Created by QFish on 12/4/15.
//  Copyright © 2015 QFish. All rights reserved.
//

#import "Player.h"

#import <AVFoundation/AVFoundation.h>

NSString * const kXActivatePowerModePlayerEnabled = @"qfi.sh.xcodeplugin.activatepowermode.player.enabled";
NSString * const kXActivatePowerModePlayerMusicFile = @"qfi.sh.xcodeplugin.activatepowermode.player.music";

@interface Player ()
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, strong) NSMenuItem * menuItem;
@property (nonatomic, strong) NSMenuItem * enabledMenuItem;
@property (nonatomic, strong) NSString * musicFile;
@property (nonatomic, strong) NSSound * music;
@end

@implementation Player

- (void)makeSomeNosie
{
    if ( self.enabled && self.music ) {
        [self.music play];
    }
}

- (void)loadMusic:(NSString *)file
{
    NSString * path = [self.bundle
                       pathForResource:[file stringByDeletingPathExtension]
                       ofType:[file pathExtension]];
    
    self.music = [[NSSound alloc] initWithContentsOfFile:path byReference:YES];
}

- (void)changeMusic:(NSString *)file
{
    if ([self.musicFile isEqualToString:file])
        return;
    
    self.musicFile = file;
    
    [self loadMusic:file];
    
    [self makeSomeNosie];
}

#pragma mark - XPowerModeHero

- (void)onPowerModeCommand:(XPowerModeCommand *)command
{
    [self makeSomeNosie];
}

#pragma mark - XPowerModePreferencesDelegate

- (void)didXPowerModePreferencesSetup:(XPowerModePreferences *)preferences
{
    NSNumber * value = [[NSUserDefaults standardUserDefaults] objectForKey:kXActivatePowerModePlayerEnabled];
    
    if ( value == nil )
    {
        _enabled = YES;
    }
    else
    {
        _enabled = [value boolValue];
    }
     
    NSString * musicFile = [[NSUserDefaults standardUserDefaults] objectForKey:kXActivatePowerModePlayerMusicFile];
    
    if ( nil == musicFile )
    {
        musicFile = @"keyboard1.wav";
    }
    
    self.musicFile = musicFile;
    
    [self loadMusic:musicFile];
}

- (void)didXPowerModePreferencesUpdate:(XPowerModePreferences *)preferences
{
    [self updateEnabledMenuItem:preferences.enabled];
}

- (void)didXPowerModeMenusSetup:(XPowerModePreferences *)preferences
{
    NSMenuItem * menuItem = [[NSMenuItem alloc] init];
    menuItem.title = @"BGMs";
    [preferences.menu addItem:menuItem];
    
    self.menuItem = menuItem;
    self.menuItem.submenu = [[NSMenu alloc] init];

    NSMenuItem * enabledMenuItem = [[NSMenuItem alloc] init];
    enabledMenuItem.title = @"Enabled";
    enabledMenuItem.action = @selector(toggleEnabled:);
    enabledMenuItem.target = self;
    [[menuItem submenu] addItem:enabledMenuItem];
    
    self.enabledMenuItem = enabledMenuItem;
    
    [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
    
    NSArray * files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.bundle.resourcePath error:NULL];
    
    for ( NSString * file in files )
    {
        if ( [file hasSuffix:@".wav"] )
        {
            NSString * musicFile = [self.bundle.resourcePath stringByAppendingFormat:@"/%@", file];
            
            if ( [[NSFileManager defaultManager] fileExistsAtPath:musicFile] )
            {
                NSMenuItem * submenuItem = [[NSMenuItem alloc] init];
                submenuItem.title = file;
                submenuItem.action = @selector(switchMusic:);
                submenuItem.target = self;
                [menuItem.submenu addItem:submenuItem];
            }
        }
    }
    
    [self updateEnabledMenuItem:preferences.enabled];
}

- (void)didXPowerModeMenusUpdate:(XPowerModePreferences *)preferences
{
    [self updateMenus];
    [self updateEnabledMenuItem:preferences.enabled];
}

#pragma mark -

- (void)updateMenus
{
    for ( NSMenuItem * item in self.menuItem.submenu.itemArray )
    {
        if ( [item.title isEqualToString:self.musicFile] )
        {
            item.state = NSOnState;
        }
        else
        {
            item.state = NSOffState;
        }
    }
}

- (void)updateEnabledMenuItem:(BOOL)enabled
{
    if ( !enabled )
    {
        self.enabledMenuItem.target = nil;
        self.enabledMenuItem.state = NSOffState;
    }
    else
    {
        self.enabledMenuItem.target = self;
        self.enabledMenuItem.state = self.enabled;
    }
}

- (void)switchMusic:(NSMenuItem *)sender
{
    NSString * file = sender.title;
    
    [self changeMusic:file];
    
    [self updateMenus];
    
    [[NSUserDefaults standardUserDefaults] setObject:file forKey:kXActivatePowerModePlayerMusicFile];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)toggleEnabled:(id)sender
{
    self.enabled = !self.enabled;
}

- (void)setEnabled:(BOOL)enabled
{
    if ( !self.preferences.enabled )
        return;
    
    if ( _enabled == enabled )
        return;
    
    _enabled = enabled;
    
    [self updateUserDefaultsWithEnabled:enabled];
    [self updateEnabledMenuItem:enabled];
}

- (void)updateUserDefaultsWithEnabled:(BOOL)shaked
{
    [[NSUserDefaults standardUserDefaults] setBool:shaked forKey:kXActivatePowerModePlayerEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
