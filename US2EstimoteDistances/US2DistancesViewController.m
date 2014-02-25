//
//  US2ViewController.m
//  US2EstimoteDistances
//
//  Created by A on 13/02/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#import "US2DistancesViewController.h"

#import <ESTBeaconManager.h>

#import "US2BeaconWrapper.h"
#import "US2BeaconBarView.h"

@interface US2DistancesViewController ()

@property (nonatomic, strong) NSMutableArray *beaconViews;

@end

@implementation US2DistancesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.beaconViews = [NSMutableArray array];

    // Setup views
    [self setupViews];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beaconDataUpdated) name:US2BeaconDataSingletonUpdate object:nil];

}
-(void)setupViews
{
    self.view.autoresizesSubviews = YES;
    CGFloat height = self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height;

    for (US2BeaconWrapper *beaconWrapper in BEACONDATA.beacons) {
        US2BeaconBarView *beaconBarView = [[US2BeaconBarView alloc] initWithFrame:CGRectMake(0, 0, 0, height) beaconWrapper:beaconWrapper];
        [self.beaconViews addObject:beaconBarView];
        [self.view addSubview:beaconBarView];
    }

    [self updateBarViews];
}

- (void) updateBarViews
{
    CGFloat maxDistance = ceilf(BEACONDATA.maxDistance);

    NSUInteger numberOfActive = 0;

    for (US2BeaconBarView *beaconBarView in self.beaconViews) {
        BOOL isActiveOrVisible = beaconBarView.frame.size.width > 0.0 || beaconBarView.beaconWrapper.isActive;
        if (isActiveOrVisible)
        {
            numberOfActive++;
        }
    }

    CGFloat activeBarWidth = self.view.frame.size.width/numberOfActive;

    CGFloat xOffset = 0;
    for (US2BeaconBarView *beaconBarView in self.beaconViews) {
        BOOL isActiveOrVisible = beaconBarView.frame.size.width > 0.0 || beaconBarView.beaconWrapper.isActive;
        CGFloat barWidth = isActiveOrVisible ? activeBarWidth : 0;

        beaconBarView.frame = CGRectMake(xOffset, beaconBarView.frame.origin.y, barWidth, beaconBarView.frame.size.height);
        xOffset += barWidth;

        [beaconBarView updateUIWithMaxDistance:maxDistance];
    }
}


-(void)beaconDataUpdated
{
    [self updateUI];
}
- (void) updateUI
{
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
        [self updateBarViews];
    } completion:nil];

}



@end
