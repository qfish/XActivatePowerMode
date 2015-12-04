//
//  Rocker.m
//  XActivatePowerMode
//
//  Created by QFish on 12/1/15.
//  Copyright © 2015 QFish. All rights reserved.
//

#import "Rocker.h"

NSString * const kXActivatePowerModeShouldShake = @"qfi.sh.xcodeplugin.activatepowermode.shouldshake";

@interface Rocker ()
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, strong) NSMenuItem * enabledMenuItem;
@end

@implementation Rocker

- (void)roll:(NSView *)aView
{
    // TODO: Find the best view to shake more gracefuly 😂
    NSView * view = aView.superview.superview;
    
    // https://github.com/JoelBesada/activate-power-mode/blob/master/lib/activate-power-mode.coffee#L51
    
    CGFloat intensity = 1 + 2 * arc4random_uniform(11) / 10.0;
    CGFloat x = intensity * (arc4random_uniform(2) == 0 ? -1 : 1);
    CGFloat y = intensity * (arc4random_uniform(2) == 0 ? -1 : 1);
    
    CGPoint position = view.frame.origin;
    position.x += x;
    position.y += y;
    
    [self roll:view withStep:position];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(75 / 1000.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self calmdown:view];
    });
}

- (void)roll:(NSView *)view withStep:(CGPoint)position
{
    CGRect frame = view.frame;
    frame.origin = position;
    view.frame = frame;
}

- (void)calmdown:(NSView *)view
{
    [self roll:view withStep:CGPointZero];
}

#pragma mark - Be a XPowerModeHero


- (void)didXPowerModePreferencesUpdate:(XPowerModePreferences *)preferences
{
    
}

- (void)didXPowerModeMenusSetup:(XPowerModePreferences *)preferences
{
    NSMenuItem * enabledMenuItem = [[NSMenuItem alloc] init];
    enabledMenuItem.title = @"Shake😂?";
    enabledMenuItem.action = @selector(toggleEnabled:);
    enabledMenuItem.target = self;
    [preferences.menu addItem:enabledMenuItem];
    
    self.enabledMenuItem = enabledMenuItem;
}

- (void)didXPowerModeMenusUpdate:(XPowerModePreferences *)preferences
{
    [self updateMenus:preferences.enabled];
}

- (void)onPowerModeCommand:(XPowerModeCommand *)command
{
    if ( self.enabled )
    {
        [self roll:command.source];
    }
}

#pragma mark -

- (void)didXPowerModePreferencesSetup:(XPowerModePreferences *)preferences
{
    NSNumber * value = [[NSUserDefaults standardUserDefaults] objectForKey:kXActivatePowerModeShouldShake];
    
    if ( value == nil )
    {
        _enabled = NO;
    }
    else
    {
        _enabled = [value boolValue];
    }
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
    [self updateMenus:enabled];
}

- (void)updateMenus:(BOOL)enabled
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

- (void)updateUserDefaultsWithEnabled:(BOOL)shaked
{
    [[NSUserDefaults standardUserDefaults] setBool:shaked forKey:kXActivatePowerModeShouldShake];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
