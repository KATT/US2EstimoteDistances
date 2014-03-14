//
//  US2BeaconAnnotationView.m
//  US2EstimoteDistances
//
//  Created by A on 20/02/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#import "US2BeaconAnnotationView.h"
#import <QuartzCore/QuartzCore.h>


@interface US2BeaconAnnotationView ()


@property (nonatomic, strong) CAShapeLayer *circle;
@property (nonatomic, readonly) CGFloat circleRadius;
@end

@implementation US2BeaconAnnotationView

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}


+(instancetype)beaconAnnotationViewWithBeacon: (US2BeaconWrapper*) beaconWrapper delegate:(US2TriliterationViewController *)delegate{
    US2BeaconAnnotationView *annotationView = [[self alloc] initWithFrame:CGRectMake(0, 0, 20.0f, 20.0f)];
    annotationView.delegate = delegate;
    annotationView.beaconWrapper = beaconWrapper;

    [annotationView setup];
    [annotationView updateUI];

    return annotationView;
}


-(void) setup
{
    self.backgroundColor = self.beaconWrapper.darkColor;
    self.layer.cornerRadius = self.bounds.size.width/2;


    [self setupCircle];
}
- (CGFloat) circleRadius
{
    CGFloat distance = self.beaconWrapper.distance.floatValue;

    if (distance <= 0.0)
    {
#ifdef DEBUG
        // if plugged in, just show a random value
        UIDeviceBatteryState batteryState = [UIDevice currentDevice].batteryState;
        if (batteryState == UIDeviceBatteryStateCharging || batteryState == UIDeviceBatteryStateFull) {
            return arc4random() % 200;
        }
#endif
        return 0;
    }

    return distance*self.delegate.pixelsPerMeter;
}
- (void)setupCircle
{
    CGFloat radius = self.circleRadius;

    CAShapeLayer *circle = [CAShapeLayer layer];
    // Make a circular shape
    // Center the shape in self.view
    self.circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius) cornerRadius:radius].CGPath;
    self.circle.position = CGPointMake(self.center.x-radius, self.center.y-radius);

    // Configure the apperence of the circle
    circle.fillColor = [self.beaconWrapper.lightColor colorWithAlphaComponent:0.3].CGColor;
    circle.strokeColor = self.beaconWrapper.darkColor.CGColor;
    circle.lineWidth = 2;

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:self.center
                    radius:radius
                startAngle:0.0
                  endAngle:M_PI * 2.0
                 clockwise:YES];

    self.circle = circle;
}


-(void) updateUI
{
    CGFloat x = self.delegate.pixelsPerMeter * self.beaconWrapper.coordinate.x;
    CGFloat y = self.delegate.pixelsPerMeter * self.beaconWrapper.coordinate.y;

    self.center = CGPointMake(x, y);

    DLog(@"Place %@ at (%.0f,%.0f)", self.beaconWrapper.name, x, y);

    // position circle
    CGFloat radius = self.circleRadius;

    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue
                     forKey:kCATransactionDisableActions];

    self.circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius) cornerRadius:radius].CGPath;
    self.circle.position = CGPointMake(self.center.x-radius, self.center.y-radius);

    [CATransaction commit];
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    [self updateUI];
    // Add to parent layer
    [self.superview.layer addSublayer:self.circle];
}

-(void) dealloc
{
    [self.circle removeFromSuperlayer];
}


@end
