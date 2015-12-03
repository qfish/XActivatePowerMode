//
//  Emitter.h
//  XActivatePowerMode
//
//  Created by QFish on 12/1/15.
//  Copyright © 2015 QFish. All rights reserved.
//

#define kXActivatePowerModeShouldRandomEffect @"qfi.sh.xcodeplugin.activatepowermode.shouldRandomEffect" //-zyn-12.03
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface Emitter : NSObject

@property (nonatomic, strong) NSString * effectFile;

- (void)emitAtPosition:(NSPoint)position onView:(NSView *)view;
- (void)changeEffectFile:(NSString *)file;

@end
