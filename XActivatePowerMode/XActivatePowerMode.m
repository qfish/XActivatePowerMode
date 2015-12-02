//
//  XActivatePowerMode.m
//  XActivatePowerMode
//
//  Created by QFish on 12/1/15.
//  Copyright © 2015 QFish. All rights reserved.
//

#import "XActivatePowerMode.h"
#import "Emitter.h"
#import "Rocker.h"

NSString * const kXActivatePowerModeEnabled = @"qfi.sh.xcodeplugin.activatepowermode.enabled";
NSString * const kXActivatePowerModeShouldShake = @"qfi.sh.xcodeplugin.activatepowermode.shouldshake";
NSString * const kXActivatePowerModeEffectFile = @"qfi.sh.xcodeplugin.activatepowermode.effectFile";

static XActivatePowerMode * __sharedPlugin = nil;

@interface XActivatePowerMode()

@property (nonatomic, weak, readwrite) NSMenuItem * enabledMenuItem;
@property (nonatomic, weak, readwrite) NSMenuItem * shakedMenuItem;
@property (nonatomic, weak, readwrite) NSMenuItem * effectsMenuItem;

@property (nonatomic, strong, readwrite) NSBundle * bundle;

@property (nonatomic, strong, readwrite) Rocker * rocker;
@property (nonatomic, strong, readwrite) Emitter * emitter;

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL shouldShake;

@end

@implementation XActivatePowerMode

@synthesize enabled = _enabled;
@synthesize shouldShake = _shouldShake;

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
		NSString * effectFile = [[NSUserDefaults standardUserDefaults] objectForKey:kXActivatePowerModeEffectFile];
		
		if ( nil == effectFile )
		{
			effectFile = @"blood.ped";
		}

        self.bundle = plugin;
        self.emitter = [Emitter new];
		self.emitter.effectFile = effectFile;
		
        self.rocker = [Rocker new];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
    return self;
}

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti
{
    //removeObserver
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    
    [self loadConfig];
    
    [self setupMenu];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setActivatePowerModeEnabled:self.enabled];
    });
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - NSTextView

- (void)textDidChange:(NSNotification *)n
{
    if ( [n.object isKindOfClass:NSClassFromString(@"IDEConsoleTextView")])
        return;

    if ( [n.object isKindOfClass:NSClassFromString(@"DVTSourceTextView")] )
    {
        NSTextView * textView = (NSTextView *)n.object;
        
        NSInteger editingLocation = [[[textView selectedRanges] objectAtIndex:0] rangeValue].location;
        NSUInteger count = 0;
        NSRect targetRect = *[textView.layoutManager rectArrayForCharacterRange:NSMakeRange(editingLocation, 0)
                                                    withinSelectedCharacterRange:NSMakeRange(editingLocation, 0)
                                                                 inTextContainer:textView.textContainer
                                                                       rectCount:&count];
        
        [self.emitter emitAtPosition:targetRect.origin onView:textView];
        
        if ( self.shouldShake )
        {
            [self.rocker roll:textView];
        }
    }
}

#pragma mark -

- (void)setActivatePowerModeEnabled:(BOOL)enabled
{
    if ( enabled )
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textDidChange:)
                                                     name:NSTextDidChangeNotification
                                                   object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSTextDidChangeNotification
                                                      object:nil];
        self.shouldShake = NO;
    }
}

#pragma mark - Config (TODO: move to config)

- (void)setEnabled:(BOOL)enabled
{
    if ( _enabled == enabled )
        return;
    
    _enabled = enabled;
    
    [self updateUserDefaultsWithEnabled:enabled];
    [self updateMenuTitles];
    [self setActivatePowerModeEnabled:enabled];
}

- (void)setShouldShake:(BOOL)shouldShake
{
    if ( !self.enabled )
        return;
    
    if ( _shouldShake == shouldShake )
        return;
    
    _shouldShake = shouldShake;
    
    [self updateUserDefaultsWithShaked:shouldShake];
    [self updateMenuTitles];
}

- (void)updateUserDefaultsWithEnabled:(BOOL)enabled
{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kXActivatePowerModeEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateUserDefaultsWithShaked:(BOOL)shaked
{
    [[NSUserDefaults standardUserDefaults] setBool:shaked forKey:kXActivatePowerModeShouldShake];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadConfig
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
    
    value = [[NSUserDefaults standardUserDefaults] objectForKey:kXActivatePowerModeShouldShake];
    
    if ( value == nil )
    {
        [self updateUserDefaultsWithEnabled:NO];
        _shouldShake = NO;
    }
    else
    {
        _shouldShake = [value boolValue];
    }
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
        
        NSMenuItem * shakedMenuItem = [[NSMenuItem alloc] init];
        shakedMenuItem.title = @"Shake😂?";
        shakedMenuItem.action = @selector(toggleShaked:);
        shakedMenuItem.target = self;
        [menu addItem:shakedMenuItem];
        self.shakedMenuItem = shakedMenuItem;

		NSMenuItem * effectsMenuItem = [[NSMenuItem alloc] init];
		effectsMenuItem.title = @"Effects";
		[menu addItem:effectsMenuItem];
		self.effectsMenuItem = effectsMenuItem;
		self.effectsMenuItem.submenu = [[NSMenu alloc] init];
		
		NSArray * effectFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.bundle.resourcePath error:NULL];
		
		for ( NSString * file in effectFiles )
		{
			if ( [file hasSuffix:@".ped"] )
			{
				NSString * effectFile = [self.bundle.resourcePath stringByAppendingFormat:@"/%@", file];
				
				if ( [[NSFileManager defaultManager] fileExistsAtPath:effectFile] )
				{
					NSMenuItem * effectSubMenuItem = [[NSMenuItem alloc] init];
					effectSubMenuItem.title = file;
					effectSubMenuItem.action = @selector(toggleEffect:);
					effectSubMenuItem.target = self;
					[[effectsMenuItem submenu] addItem:effectSubMenuItem];
				}
			}
		}
		
        [self updateMenuTitles];
		[self updateMenuEffectSelection];
    }
}

- (void)toggleEnabled:(id)sender
{
    self.enabled = !self.enabled;
    [self setActivatePowerModeEnabled:self.enabled];
}

- (void)toggleShaked:(id)sender
{
    self.shouldShake = !self.shouldShake;
}

- (void)toggleEffect:(id)sender
{
	NSString * file = ((NSMenuItem *)sender).title;
	
	[self.emitter changeEffectFile:file];
	
	[self updateMenuEffectSelection];
	
	[[NSUserDefaults standardUserDefaults] setObject:file forKey:kXActivatePowerModeEffectFile];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateMenuEffectSelection
{
	for ( NSMenuItem * item in self.effectsMenuItem.submenu.itemArray )
	{
		if ( [item.title isEqualToString:self.emitter.effectFile] )
		{
			item.state = NSOnState;
		}
		else
		{
			item.state = NSOffState;
		}
	}
}

- (void)updateMenuTitles
{
    self.enabledMenuItem.state = self.enabled;

    if ( !self.enabled )
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

@end
