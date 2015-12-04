//
//  Emitter.m
//  XActivatePowerMode
//
//  Created by QFish on 12/1/15.
//  Copyright © 2015 QFish. All rights reserved.
//

#import "Emitter.h"

#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>

#import "UIEffectDesignerView.h"

NSString * const kXActivatePowerModeEffectFile = @"qfi.sh.xcodeplugin.activatepowermode.effectFile";

@interface Emitter ()
@property (atomic, assign) BOOL isEmitting;
@property (nonatomic, assign) float birthRate;
@property (nonatomic, strong) NSString * effectFile;
@property (nonatomic, strong) UIEffectDesignerView * effectView;

@property (nonatomic, strong) NSMenuItem * menuItem;
//@property (nonatomic, strong) NSTimer * timer;
@end

@implementation Emitter

- (void)dealloc
{
	self.effectFile = nil;
}

- (void)emitAtPosition:(NSPoint)position onView:(NSView *)aView
{
    [self beat];
    
    NSView * view = aView.superview;

    if ( !self.isEmitting )
    {
        [self startAtPosition:position onView:view];
    }
    
    [self updatePosition:position onView:view];
}

- (void)startAtPosition:(NSPoint)position onView:(NSView *)view
{
    if ( !self.isEmitting )
    {
        self.isEmitting = YES;
        
        self.effectView.emitter.birthRate = self.birthRate;
        
        if ( ![view.subviews containsObject:self.effectView] )
        {
            [view addSubview:self.effectView];
        }
        
//        [self.timer invalidate];
//        self.timer = [NSTimer timerWithTimeInterval:0.1
//                                             target:self
//                                           selector:@selector(remix)
//                                           userInfo:nil
//                                            repeats:YES];
//        
//        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        
    }
}

- (void)updatePosition:(NSPoint)position onView:(NSView *)view
{
    position = [self.effectView convertPoint:position fromView:view];
    [self.effectView updatePosition:position];
}

#pragma mark -

- (void)beat
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stop) object:nil];
    [self performSelector:@selector(stop) withObject:nil afterDelay:0.3];
}

- (void)stop
{
    if ( _effectView ) {
        self.effectView.emitter.birthRate = 0;
        self.isEmitting = NO;
//        [self.timer invalidate];
    }
}

- (void)remix
{
    CAEmitterCell * cell = self.effectView.emitter.emitterCells.firstObject;
    cell.emissionLongitude = arc4random_uniform(1000) / 1000.0 * M_PI;
}

#pragma mark - UIEffectDesignerView

- (UIEffectDesignerView *)effectView
{
    if ( !_effectView )
    {
        // Build your own effect with: http://www.touch-code-magazine.com/uieffectdesigner/
        _effectView = [UIEffectDesignerView effectWithFile:[self.bundle
                                                            pathForResource:[self.effectFile stringByDeletingPathExtension]
                                                            ofType:[self.effectFile pathExtension]]];
        self.birthRate = _effectView.emitter.birthRate;
    }
    
    return _effectView;
}

- (void)changeEffect:(NSString *)file
{
	if ( [self.effectFile isEqualToString:file] )
		return;
	
	if ( _effectView )
	{
		NSView * containerView = _effectView.superview;

		[_effectView removeFromSuperview];
		
		_effectView = [UIEffectDesignerView effectWithFile:[self.bundle
															pathForResource:[file stringByDeletingPathExtension]
															ofType:[file pathExtension]]];
		
		[containerView addSubview:_effectView];

		self.birthRate = _effectView.emitter.birthRate;
	}

	self.effectFile = file;
    
    [self beat];
}

#pragma mark - XPowerModeHero

- (void)onPowerModeCommand:(XPowerModeCommand *)command
{
    [self emitAtPosition:command.position onView:command.source];
}

#pragma mark - XPowerModePreferencesDelegate

- (void)didXPowerModePreferencesSetup:(XPowerModePreferences *)preferences
{
    NSString * effectFile = [[NSUserDefaults standardUserDefaults] objectForKey:kXActivatePowerModeEffectFile];
    
    if ( nil == effectFile )
    {
        effectFile = @"blood.ped";
    }
    
    self.effectFile = effectFile;
}

- (void)didXPowerModeMenusSetup:(XPowerModePreferences *)preferences
{
    NSMenuItem * menuItem = [[NSMenuItem alloc] init];
    menuItem.title = @"Effects";
    [preferences.menu addItem:menuItem];
    
    self.menuItem = menuItem;
    self.menuItem.submenu = [[NSMenu alloc] init];
    
    NSArray * files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.bundle.resourcePath
                                                                          error:NULL];
    
    for ( NSString * file in files )
    {
        if ( [file hasSuffix:@".ped"] )
        {
            NSString * effectFile = [self.bundle.resourcePath stringByAppendingFormat:@"/%@", file];
            
            if ( [[NSFileManager defaultManager] fileExistsAtPath:effectFile] )
            {
                NSMenuItem * submenuItem = [[NSMenuItem alloc] init];
                submenuItem.title = file;
                submenuItem.action = @selector(switchEffect:);
                submenuItem.target = self;
                [[menuItem submenu] addItem:submenuItem];
            }
        }
    }
}

- (void)didXPowerModeMenusUpdate:(XPowerModePreferences *)preferences
{
    [self updateMenus];
}

- (void)switchEffect:(id)sender
{
    NSString * file = ((NSMenuItem *)sender).title;
    
    [self changeEffect:file];
    
    [self updateMenus];
    
    [[NSUserDefaults standardUserDefaults] setObject:file forKey:kXActivatePowerModeEffectFile];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateMenus
{
    for ( NSMenuItem * item in self.menuItem.submenu.itemArray )
    {
        if ( [item.title isEqualToString:self.effectFile] )
        {
            item.state = NSOnState;
        }
        else
        {
            item.state = NSOffState;
        }
    }
}

@end
