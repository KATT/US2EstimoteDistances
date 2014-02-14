//
//  US2BeaconDataSingleton.m
//  US2EstimoteDistances
//
//  Created by A on 14/02/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#import "US2BeaconDataSingleton.h"


#import <HexColors/HexColor.h>

#import "US2BeaconBarView.h"

@interface US2BeaconDataSingleton () <ESTBeaconManagerDelegate>

@property (nonatomic, strong) ESTBeaconManager* beaconManager;

@property (readwrite) US2BeaconWrapper *mintBeacon;
@property (readwrite) US2BeaconWrapper *purpleBeacon;
@property (readwrite) US2BeaconWrapper *blueBeacon;

@property (readwrite) CGFloat maxDistance;

@property (readwrite) NSMutableArray *beacons;

@end

@implementation US2BeaconDataSingleton

- (id)init
{
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

+ (US2BeaconDataSingleton *)sharedInstance
{
    static dispatch_once_t onceToken = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&onceToken, ^{
        _sharedObject = [[self alloc] init];
    });

    return _sharedObject;
}
- (void) setup
{
    // Setup known beacons
    self.mintBeacon = [[US2BeaconWrapper alloc] initWithName:@"Mint"];
    self.purpleBeacon = [[US2BeaconWrapper alloc] initWithName:@"Purple"];
    self.blueBeacon = [[US2BeaconWrapper alloc] initWithName:@"Blue"];

    self.beacons = [NSMutableArray array];
    [self.beacons addObject:self.mintBeacon];
    [self.beacons addObject:self.blueBeacon];
    [self.beacons addObject:self.purpleBeacon];

    // Setup views
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

    [[NSNotificationCenter defaultCenter] postNotificationName:US2BeaconDataSingletonUpdate object:self];
}


- (void) updateMaxDistance
{
    self.maxDistance = 0;

    for (US2BeaconWrapper *beaconWrapper in self.beacons) {
        CGFloat distance = beaconWrapper.beacon.distance.floatValue;
        if (distance > self.maxDistance)
        {
            self.maxDistance = distance;
        }
    }
}

@end
