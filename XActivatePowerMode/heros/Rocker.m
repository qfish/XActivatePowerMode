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
@property (nonatomic, assign) BOOL shouldShake;
@property (nonatomic, strong) NSMenuItem * shakedMenuItem;
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

- (void)xpm_didTextChange:(NSTextView *)textView
{
    if ( self.shouldShake )
    {
        [self roll:textView];
    }
}

- (void)setupMenus
{
    NSMenuItem * shakedMenuItem = [[NSMenuItem alloc] init];
    shakedMenuItem.title = @"Shake😂?";
    shakedMenuItem.action = @selector(toggleShaked:);
    shakedMenuItem.target = self;
    [self.mainMenu addItem:shakedMenuItem];
    self.shakedMenuItem = shakedMenuItem;
}

#pragma mark -

- (void)load
{
    NSNumber * value = [[NSUserDefaults standardUserDefaults] objectForKey:kXActivatePowerModeShouldShake];
    
    if ( value == nil )
    {
//        [self updateUserDefaultsWithEnabled:NO];
        _shouldShake = NO;
    }
    else
    {
        _shouldShake = [value boolValue];
    }
}

- (void)updateMenu
{
    if ( !self.preferences.enabled )
    {
        self.shakedMenuItem.target = nil;
        self.shakedMenuItem.state = NSOffState;
    }
    else
    {
        self.shakedMenuItem.target = self;
        self.shakedMenuItem.state = self.shouldShake;
    }
}

- (void)toggleShaked:(id)sender
{
    self.shouldShake = !self.shouldShake;
}

- (void)updateUserDefaultsWithShaked:(BOOL)shaked
{
    [[NSUserDefaults standardUserDefaults] setBool:shaked forKey:kXActivatePowerModeShouldShake];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setShouldShake:(BOOL)shouldShake
{
    if ( !self.preferences.enabled )
        return;
    
    if ( _shouldShake == shouldShake )
        return;
    
    _shouldShake = shouldShake;
    
//    [self updateUserDefaultsWithShaked:shouldShake];
    self.preferences[@"shouldShake"] = @(shouldShake);
//    [self updateMenuTitles];
}

@end
