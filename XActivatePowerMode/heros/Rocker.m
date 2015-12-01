//
//  Rocker.m
//  XActivatePowerMode
//
//  Created by QFish on 12/1/15.
//  Copyright © 2015 QFish. All rights reserved.
//

#import "Rocker.h"

@interface Rocker ()
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

@end
