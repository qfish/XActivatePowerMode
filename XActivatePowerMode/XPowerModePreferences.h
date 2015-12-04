//
//  XPowerModePreferences.h
//  XActivatePowerMode
//
//  Created by QFish on 12/3/15.
//  Copyright © 2015 QFish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@class XPowerModePreferences;

@protocol XPowerModePreferencesDelegate <NSObject>
@optional
- (void)didXPowerModePreferencesSetup:(nonnull XPowerModePreferences *)preferences;
- (void)didXPowerModePreferencesUpdate:(nonnull XPowerModePreferences *)preferences;
- (void)didXPowerModeMenusSetup:(nonnull XPowerModePreferences *)preferences;
- (void)didXPowerModeMenusUpdate:(nonnull XPowerModePreferences *)preferences;
@end

@interface XPowerModePreferences : NSObject

@property (nullable, readonly) NSMenu * menu;
@property (nullable, weak) id<XPowerModePreferencesDelegate> delegate;

@property (nonatomic, assign) BOOL enabled;

+ (nonnull instancetype)standardPrefreneces;

- (void)initialize;

- (nullable id)objectForKeyedSubscript:(nonnull id)key;
- (void)setObject:(nullable id)obj forKeyedSubscript:(nonnull id <NSCopying>)key;

@end
