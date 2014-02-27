//
//  US2ViewController.m
//  US2EstimoteDistances
//
//  Created by A on 13/02/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#import "US2DistancesViewController.h"

#import <ESTBeaconManager.h>
#import <HexColors/HexColor.h>

#import "US2BeaconManager.h"
#import "US2BeaconWrapper.h"
#import "US2BeaconBarView.h"

@interface US2DistancesViewController ()<US2BeaconManagerDelegate>

@property (nonatomic, strong) NSMutableArray *beaconViews;
@property (nonatomic, strong) US2BeaconManager *beaconManager;

@property (nonatomic) CGFloat maxDistance;
@end

@implementation US2DistancesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.beaconViews = [NSMutableArray array];

    // Setup views
    [self setupBeaconManager];
    [self setupViews];
}

- (void) setupBeaconManager
{
    self.beaconManager = [[US2BeaconManager alloc] init];
    self.beaconManager.delegate = self;

    // FIXME clean this up
    [self.beaconManager registerBeaconWrapper: [[US2BeaconWrapper alloc] initWithMajor:@35729 name:@"Mint" lightColor:[UIColor colorWithHexString:@"98c5a6"] darkColor:[UIColor colorWithHexString:@"5c7865"]]];
    [self.beaconManager registerBeaconWrapper: [[US2BeaconWrapper alloc] initWithMajor:@50667 name:@"Purple" lightColor:[UIColor colorWithHexString:@"5c59a7"] darkColor:[UIColor colorWithHexString:@"3f3d73"]]];
    [self.beaconManager registerBeaconWrapper: [[US2BeaconWrapper alloc] initWithMajor: @4092 name:@"Blue" lightColor:[UIColor colorWithHexString:@"9fddf9"] darkColor:[UIColor colorWithHexString:@"6f9aad"]]];

    [self.beaconManager registerBeaconWrapper: [[US2BeaconWrapper alloc] initWithMajor:@43211 name:@"Mint #2" lightColor:[UIColor colorWithHexString:@"98c5a6"] darkColor:[UIColor colorWithHexString:@"5c7865"]]];
    [self.beaconManager registerBeaconWrapper: [[US2BeaconWrapper alloc] initWithMajor:@41032 name:@"Purple #2" lightColor:[UIColor colorWithHexString:@"5c59a7"] darkColor:[UIColor colorWithHexString:@"3f3d73"]]];
    [self.beaconManager registerBeaconWrapper: [[US2BeaconWrapper alloc] initWithMajor: @57830 name:@"Blue #2" lightColor:[UIColor colorWithHexString:@"9fddf9"] darkColor:[UIColor colorWithHexString:@"6f9aad"]]];
}

-(void)setupViews
{
    self.view.autoresizesSubviews = YES;
    CGFloat height = self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height;

    for (US2BeaconWrapper *beaconWrapper in self.beaconManager.beaconWrappers) {
        US2BeaconBarView *beaconBarView = [[US2BeaconBarView alloc] initWithFrame:CGRectMake(0, 0, 0, height) beaconWrapper:beaconWrapper];
        [self.beaconViews addObject:beaconBarView];
        [self.view addSubview:beaconBarView];
    }

    [self updateBarViews];
}

- (void) updateBarViews
{
    self.maxDistance = MAX(ceilf(self.beaconManager.maxDistance), self.maxDistance);

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

        [beaconBarView updateUIWithMaxDistance:self.maxDistance];
    }
}


-(void)beaconManagerDidUpdate:(US2BeaconManager *)beaconManager;
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
