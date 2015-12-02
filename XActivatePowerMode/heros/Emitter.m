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

#import "XActivatePowerMode.h"
#import "UIEffectDesignerView.h"

@interface Emitter ()
@property (atomic, assign) BOOL isEmitting;
@property (nonatomic, assign) float birthRate;
@property (nonatomic, strong) NSTimer * timer;
@property (nonatomic, strong) NSString * effectFile;
@property (nonatomic, strong) UIEffectDesignerView * effectView;
@end

@implementation Emitter

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
        _effectView = [UIEffectDesignerView effectWithFile:[[XActivatePowerMode sharedPlugin].bundle
                                                            pathForResource:@"default"
                                                            ofType:@"ped"]];
        self.birthRate = _effectView.emitter.birthRate;
    }
    
    return _effectView;
}

@end
