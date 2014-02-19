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

#import "US2BeaconWrapper.h"
#import "US2BeaconBarView.h"

@interface US2DistancesViewController () <ESTBeaconManagerDelegate>

// Views
@property (nonatomic, strong) US2BeaconBarView *mintBeaconView;
@property (nonatomic, strong) US2BeaconBarView *purpleBeaconView;
@property (nonatomic, strong) US2BeaconBarView *blueBeaconView;
@end

@implementation US2DistancesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Setup views
    [self setupViews];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beaconDataUpdated) name:US2BeaconDataSingletonUpdate object:nil];

}
-(void)setupViews
{
    self.view.autoresizesSubviews = YES;

    CGFloat aThird = self.view.frame.size.width/3;
    CGFloat height = self.view.frame.size.height;

    self.mintBeaconView     = [[US2BeaconBarView alloc] initWithFrame:CGRectMake(aThird*0, 0, aThird, height) beaconWrapper:BEACONDATA.mintBeacon];
    self.blueBeaconView     = [[US2BeaconBarView alloc] initWithFrame:CGRectMake(aThird*1, 0, aThird, height) beaconWrapper:BEACONDATA.blueBeacon];
    self.purpleBeaconView   = [[US2BeaconBarView alloc] initWithFrame:CGRectMake(aThird*2, 0, aThird, height) beaconWrapper:BEACONDATA.purpleBeacon];


    [self.view addSubview:self.mintBeaconView];
    [self.view addSubview:self.blueBeaconView];
    [self.view addSubview:self.purpleBeaconView];

    UIView *statusBarBackgroundView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    statusBarBackgroundView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    [self.view addSubview:statusBarBackgroundView];
}

-(void)beaconDataUpdated
{
    [self updateUI];
}
- (void) updateUI
{
    CGFloat maxDistance = ceilf(BEACONDATA.maxDistance);
    
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.mintBeaconView updateUIWithMaxDistance:maxDistance];
        [self.blueBeaconView updateUIWithMaxDistance:maxDistance];
        [self.purpleBeaconView updateUIWithMaxDistance:maxDistance];
    } completion:nil];

}


@end
