//
//  Emitter.h
//  XActivatePowerMode
//
//  Created by QFish on 12/1/15.
//  Copyright © 2015 QFish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface Emitter : NSObject

- (void)emitAtPosition:(NSPoint)position onView:(NSView *)view;

@end
