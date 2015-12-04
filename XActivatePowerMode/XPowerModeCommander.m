//
//  Commander.m
//  XActivatePowerMode
//
//  Created by QFish on 12/3/15.
//  Copyright © 2015 QFish. All rights reserved.
//

#import "XPowerModeCommander.h"

#import "Emitter.h"
#import "Rocker.h"
#import "XPowerModePreferences.h"

@interface XPowerModeCommander () <XPowerModePreferencesDelegate>
@property (nonatomic, strong) Rocker * rocker;
@property (nonatomic, strong) Emitter * emitter;
@property (nonatomic, strong) NSMutableArray * heros;
@end

@implementation XPowerModeCommander

- (void)dealloc
{
    [self sleep];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.heros = [NSMutableArray array];
        [self loadHeros];
        
        self.preferences = [XPowerModePreferences new];
        self.preferences.delegate = self;
    }
    return self;
}

- (void)gogogo
{
    [self.preferences initialize];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ( self.preferences.enabled )
        {
            [self wakeup];
        }
    });
}

#pragma mark -

- (void)loadHeros
{
    // TODO: Move this out
    [self.heros addObject:(self.emitter = [Emitter new])];
    [self.heros addObject:(self.rocker  = [Rocker new])];
}

#pragma mark - Notifications

- (void)textDidChange:(NSNotification *)n
{
    if ( [n.object isKindOfClass:NSClassFromString(@"IDEConsoleTextView")])
        return;
    
    if ( [n.object isKindOfClass:NSClassFromString(@"DVTSourceTextView")] )
    {
        NSTextView * textView = n.object;
        
        NSInteger editingLocation = [[[textView selectedRanges] objectAtIndex:0] rangeValue].location;
        NSUInteger count = 0;
        NSRect targetRect = *[textView.layoutManager rectArrayForCharacterRange:NSMakeRange(editingLocation, 0)
                                                   withinSelectedCharacterRange:NSMakeRange(editingLocation, 0)
                                                                inTextContainer:textView.textContainer
                                                                      rectCount:&count];
        
        XPowerModeCommand * command = [XPowerModeCommand commandWithSource:textView position:targetRect.origin];
        
        [self.heros enumerateObjectsUsingBlock:^(id<XPowerModeHero> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ( obj && [obj respondsToSelector:@selector(onPowerModeCommand:)])
            {
                [obj onPowerModeCommand:command];
            }
        }];
    }
}

#pragma mark -

- (void)wakeup
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange:)
                                                 name:NSTextDidChangeNotification
                                               object:nil];
}

- (void)sleep
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSTextDidChangeNotification
                                                  object:nil];
}

#pragma mark - Heros

- (void)addHero:(id<XPowerModeHero>)hero
{
    [self.heros addObject:hero];
}

- (void)removeHero:(id<XPowerModeHero>)hero
{
    [self.heros removeObject:hero];
}

#pragma mark - XPowerModePreferencesDelegate

- (void)didXPowerModePreferencesUpdate:(XPowerModePreferences *)preferences
{
    if ( preferences.enabled ) {
        [self wakeup];
    } else {
        [self sleep];
    }
    
    [self.heros enumerateObjectsUsingBlock:^(id<XPowerModeHero> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ( obj && [obj respondsToSelector:@selector(didXPowerModeMenusSetup:)])
        {
            [obj didXPowerModeMenusSetup:preferences];
        }
    }];
}

- (void)didXPowerModeMenusSetup:(XPowerModePreferences *)preferences
{
    [self.heros enumerateObjectsUsingBlock:^(id<XPowerModeHero> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ( obj && [obj respondsToSelector:@selector(didXPowerModeMenusSetup:)])
        {
            [obj didXPowerModeMenusSetup:preferences];
        }
    }];
}

- (void)didXPowerModeMenusUpdate:(XPowerModePreferences *)preferences
{
    [self.heros enumerateObjectsUsingBlock:^(id<XPowerModeHero> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ( obj && [obj respondsToSelector:@selector(didXPowerModeMenusUpdate:)])
        {
            [obj didXPowerModeMenusUpdate:preferences];
        }
    }];
}

@end
