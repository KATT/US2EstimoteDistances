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


+(instancetype)beaconAnnotationViewWithBeacon: (US2BeaconWrapper*) beaconWrapper pixelRatio:(CGFloat) pixelsPerMeter {
    US2BeaconAnnotationView *annotationView = [[self alloc] initWithFrame:CGRectMake(0, 0, 20.0f, 20.0f)];
    annotationView.pixelsPerMeter = pixelsPerMeter;
    annotationView.beaconWrapper = beaconWrapper;

    [annotationView setup];
    [annotationView updateUI];

    return annotationView;
}


-(void) setup
{
    self.backgroundColor = self.beaconWrapper.darkColor;
//    self.layer.cornerRadius = self.frame.size.width / 2.0;

}

-(void) updateUI
{
    CGFloat x = self.pixelsPerMeter * self.beaconWrapper.coordinate.x;
    CGFloat y = self.pixelsPerMeter * self.beaconWrapper.coordinate.y;

    self.center = CGPointMake(x, y);

    DLog(@"Place %@ at (%.0f,%.0f)", self.beaconWrapper.name, x, y);
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    [self updateUI];
}


@end
