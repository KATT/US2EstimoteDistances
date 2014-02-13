//
//  US2ViewController.m
//  US2EstimoteDistances
//
//  Created by A on 13/02/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#import "US2ViewController.h"

#import <ESTBeaconManager.h>
#import <HexColors/HexColor.h>

#import "US2BeaconWrapper.h"
#import "US2BeaconBarView.h"

@interface US2ViewController () <ESTBeaconManagerDelegate>

@property (nonatomic, strong) ESTBeaconManager* beaconManager;

// Wrappers for our beacons
@property (nonatomic, strong) US2BeaconWrapper *mintBeacon;
@property (nonatomic, strong) US2BeaconWrapper *purpleBeacon;
@property (nonatomic, strong) US2BeaconWrapper *blueBeacon;

// Views
@property (nonatomic, strong) US2BeaconBarView *mintBeaconView;
@property (nonatomic, strong) US2BeaconBarView *purpleBeaconView;
@property (nonatomic, strong) US2BeaconBarView *blueBeaconView;

@property (nonatomic, assign) CGFloat maxDistance;

@property (nonatomic, readonly) NSArray *beacons;
@end

@implementation US2ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Setup beacon wrapper objects
    self.mintBeacon = [[US2BeaconWrapper alloc] initWithName:@"Mint"];
    self.purpleBeacon = [[US2BeaconWrapper alloc] initWithName:@"Purple"];
    self.blueBeacon = [[US2BeaconWrapper alloc] initWithName:@"Blue"];


    // Setup views
    [self setupViews];
    [self setupBeaconManager];
}

-(void) setupBeaconManager
{
    // setup Estimote beacon manager
    // create manager instance
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    self.beaconManager.avoidUnknownStateBeacons = YES;

    // create sample region object (you can additionaly pass major / minor values)
    ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
                                                                  identifier:@"EstimoteSampleRegion"];

    // start looking for estimote beacons in region
    // when beacon ranged beaconManager:didRangeBeacons:inRegion: invoked
    [self.beaconManager startRangingBeaconsInRegion:region];
}
-(void)setupViews
{
    CGFloat aThird = self.view.frame.size.width/3;
    CGFloat height = self.view.frame.size.height;

    self.mintBeaconView     = [[US2BeaconBarView alloc] initWithFrame:CGRectMake(aThird*0, 0, aThird, height) beaconWrapper:self.mintBeacon lightColor:[UIColor colorWithHexString:@"98c5a6"] darkColor:[UIColor colorWithHexString:@"5c7865"]];
    self.blueBeaconView     = [[US2BeaconBarView alloc] initWithFrame:CGRectMake(aThird*1, 0, aThird, height) beaconWrapper:self.blueBeacon lightColor:[UIColor colorWithHexString:@"9fddf9"] darkColor:[UIColor colorWithHexString:@"6f9aad"]];
    self.purpleBeaconView   = [[US2BeaconBarView alloc] initWithFrame:CGRectMake(aThird*2, 0, aThird, height) beaconWrapper:self.purpleBeacon lightColor:[UIColor colorWithHexString:@"5c59a7"] darkColor:[UIColor colorWithHexString:@"3f3d73"]];


    [self.view addSubview:self.mintBeaconView];
    [self.view addSubview:self.blueBeaconView];
    [self.view addSubview:self.purpleBeaconView];
}

-(void)mapBeacon: (ESTBeacon*)beacon {
    if ([beacon.major isEqualToNumber: @35729]) {
        // Mint
        self.mintBeacon.beacon = beacon;
    } else if ([beacon.major isEqualToNumber: @4092]) {
        // Blue
        self.blueBeacon.beacon = beacon;
    } else if ([beacon.major isEqualToNumber: @50667]) {
        // Purple
        self.purpleBeacon.beacon = beacon;
    } else {
        DLog(@"Unidentified beacon found on distance %@. Beacon: %@", beacon.distance, beacon);
    }

}


-(void)beaconManager:(ESTBeaconManager *)manager
     didRangeBeacons:(NSArray *)beacons
            inRegion:(ESTBeaconRegion *)region
{
    for (ESTBeacon* beacon in beacons)
    {
        [self mapBeacon:beacon];
    }

    [self updateMaxDistance];
    [self updateUI];


}


- (NSArray *) beacons
{
    return [NSArray arrayWithObjects:self.mintBeacon, self.purpleBeacon, self.blueBeacon, nil];
}

- (void) updateMaxDistance
{
    for (US2BeaconWrapper *beaconWrapper in self.beacons) {
        CGFloat distance = beaconWrapper.beacon.distance.floatValue;
        if (distance > self.maxDistance)
        {
            self.maxDistance = distance;
        }
    }
}
- (void) updateUI
{

    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.mintBeaconView updateUIWithMaxDistance:self.maxDistance];
        [self.blueBeaconView updateUIWithMaxDistance:self.maxDistance];
        [self.purpleBeaconView updateUIWithMaxDistance:self.maxDistance];
    } completion:nil];

}


@end
