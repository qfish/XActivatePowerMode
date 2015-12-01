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

static XActivatePowerMode * __sharedPlugin = nil;

@interface XActivatePowerMode()

@property (nonatomic, weak, readwrite) NSMenuItem * menuItem;

@property (nonatomic, strong, readwrite) NSBundle * bundle;

@property (nonatomic, strong, readwrite) Rocker * rocker;
@property (nonatomic, strong, readwrite) Emitter * emitter;

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
        self.bundle = plugin;
        self.emitter = [Emitter new];
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
    
    // Create menu items, initialize UI, etc.
    // Sample Menu Item:
    [self setupMenu];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setActivatePowerModeEnabled:[self isActivatePowerModeEnabled]];
    });
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - NSTextView

- (void)textDidChange:(NSNotification *)n
{
    id firstResponder = [[NSApp keyWindow] firstResponder];
    if (![firstResponder isKindOfClass:NSClassFromString(@"DVTSourceTextView")]) return;

    if ( [n.object isKindOfClass:NSTextView.class] )
    {
        NSTextView *textView = (NSTextView *)n.object;
        
        NSInteger editingLocation = [[[textView selectedRanges] objectAtIndex:0] rangeValue].location;
        NSUInteger count = 0;
        NSRect targetRect = *[textView.layoutManager rectArrayForCharacterRange:NSMakeRange(editingLocation, 0)
                                                    withinSelectedCharacterRange:NSMakeRange(editingLocation, 0)
                                                                 inTextContainer:textView.textContainer
                                                                       rectCount:&count];
        
        [self.emitter emitAtPosition:targetRect.origin onView:textView];
        [self.rocker roll:textView];
    }
}

#pragma mark - Methods

- (void)setActivatePowerModeEnabled:(BOOL)enabled
{
    [self updateUserDefaultsWithEnabled:enabled];
    [self updateMenuTitles];
    
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
    }
}

#pragma mark - UserDefaults

- (BOOL)isActivatePowerModeEnabled
{
    NSNumber * enabled = [[NSUserDefaults standardUserDefaults] objectForKey:kXActivatePowerModeEnabled];
    
    if ( enabled == nil )
    {
        [self updateUserDefaultsWithEnabled:YES];
        return YES;
    }
    
    return [enabled boolValue];
}

- (void)updateUserDefaultsWithEnabled:(BOOL)enabled
{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kXActivatePowerModeEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Menus

- (void)setupMenu
{
    NSMenuItem * mainItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    
    if ( mainItem )
    {
        [[mainItem submenu] addItem:[NSMenuItem separatorItem]];

        NSMenuItem * menuItem = [[NSMenuItem alloc] init];
        menuItem.action = @selector(toggleEnabled:);
        menuItem.target = self;
        menuItem.title = @"Activate Power Mode";
        [[mainItem submenu] addItem:menuItem];
        
        self.menuItem = menuItem;
        
        [self updateMenuTitles];
    }
}

- (void)toggleEnabled:(id)sender
{
    [self setActivatePowerModeEnabled:![self isActivatePowerModeEnabled]];
}

- (void)updateMenuTitles
{
    self.menuItem.state = [self isActivatePowerModeEnabled];
}

@end
