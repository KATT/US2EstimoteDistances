//
//  US2BeaconBarView.m
//  US2EstimoteDistances
//
//  Created by A on 13/02/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#import <ESTBeaconManager.h>

#import "US2BeaconBarView.h"

@interface US2BeaconBarView()

@property (nonatomic, strong) UIView *barView;
@property (nonatomic, strong) UILabel *metricLabel;
@property (nonatomic, strong) US2BeaconWrapper *beaconWrapper;
@end

@implementation US2BeaconBarView

- (id)initWithFrame:(CGRect)frame beaconWrapper:(US2BeaconWrapper *)beaconWrapper
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.beaconWrapper = beaconWrapper;

        [self setup];
    }
    return self;
}


-(void) setup
{
    self.autoresizesSubviews = YES;
    self.barView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight;

    self.barView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, 0)];
    self.metricLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 100, self.frame.size.width, 50)];

    self.metricLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;

    self.backgroundColor = self.beaconWrapper.lightColor;
    self.barView.backgroundColor = self.beaconWrapper.darkColor;



    [self addSubview:self.barView];
    [self addSubview:self.metricLabel];
}

-(void) updateUIWithMaxDistance: (CGFloat) maxDistance
{
    CGFloat distance = self.beaconWrapper.beacon.distance.floatValue;

    if (distance <= 0.0)
    {
        self.alpha = 0.3;
        return;
    }
    self.alpha = 1.0;
//    DLog(@"frame: %@", NSStringFromCGRect(self.frame));
    CGFloat fill = distance/(maxDistance * 1.1);

    CGFloat newHeight = self.frame.size.height*fill;
    CGFloat newY = self.frame.size.height - newHeight;
    CGRect newRect = CGRectMake(0, newY, self.barView.frame.size.width, newHeight);
    self.barView.frame = newRect;


    self.metricLabel.text = [NSString stringWithFormat:@"%.2f m", self.beaconWrapper.beacon.distance.floatValue];
    self.metricLabel.numberOfLines = 1;
    self.metricLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    self.metricLabel.adjustsFontSizeToFitWidth = YES;
    self.metricLabel.minimumScaleFactor = 10.0f/12.0f;
    self.metricLabel.font = [UIFont fontWithName:@"Helvetica" size:20.0f];
    self.metricLabel.clipsToBounds = YES;
    self.metricLabel.backgroundColor = [UIColor clearColor];
    self.metricLabel.textColor = [UIColor whiteColor];
    self.metricLabel.textAlignment = NSTextAlignmentCenter;


//    self.metricLabel.shadowColor = [UIColor darkTextColor];
//    self.metricLabel.shadowOffset = CGSizeMake(0, 1.0);
}


@end
