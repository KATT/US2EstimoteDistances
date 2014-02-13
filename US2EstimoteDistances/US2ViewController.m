//
//  US2ViewController.m
//  US2EstimoteDistances
//
//  Created by A on 13/02/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#import "US2ViewController.h"

#import <ESTBeaconManager.h>

#import "US2Beacon.h"

@interface US2ViewController () <ESTBeaconManagerDelegate>

@property (nonatomic, strong) ESTBeaconManager* beaconManager;

// Wrappers for our beacons
@property (nonatomic, strong) US2Beacon *mintBeacon;
@property (nonatomic, strong) US2Beacon *purpleBeacon;
@property (nonatomic, strong) US2Beacon *blueBeacon;

@end

@implementation US2ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Setup beacon wrapper objects
    self.mintBeacon = [[US2Beacon alloc] initWithColor:[UIColor colorWithRed:92.0 green:89.0 blue:167.0 alpha:1]];
    self.purpleBeacon = [[US2Beacon alloc] initWithColor:[UIColor colorWithRed:152.0 green:197.0 blue:166.0 alpha:1]];
    self.blueBeacon = [[US2Beacon alloc] initWithColor:[UIColor colorWithRed:159.0 green:221.0 blue:249.0 alpha:1]];
    


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


-(void)beaconManager:(ESTBeaconManager *)manager
     didRangeBeacons:(NSArray *)beacons
            inRegion:(ESTBeaconRegion *)region
{
    for (ESTBeacon* beacon in beacons)
    {
        DLog(@"Beacon update from %@/%@", beacon.major, beacon.minor);
    }

}


@end
