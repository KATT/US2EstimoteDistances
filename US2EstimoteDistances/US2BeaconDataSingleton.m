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
@property (readwrite) CGFloat maxX;
@property (readwrite) CGFloat maxY;

@property (readwrite) NSMutableArray *beacons;

@end

@implementation US2BeaconDataSingleton

- (id)init
{
    if (self = [super init])
    {
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
    self.mintBeacon = [[US2BeaconWrapper alloc] initWithName:@"Mint" lightColor:[UIColor colorWithHexString:@"98c5a6"] darkColor:[UIColor colorWithHexString:@"5c7865"]];
    self.purpleBeacon = [[US2BeaconWrapper alloc] initWithName:@"Purple" lightColor:[UIColor colorWithHexString:@"5c59a7"] darkColor:[UIColor colorWithHexString:@"3f3d73"]];
    self.blueBeacon = [[US2BeaconWrapper alloc] initWithName:@"Blue" lightColor:[UIColor colorWithHexString:@"9fddf9"] darkColor:[UIColor colorWithHexString:@"6f9aad"]];

    self.blueBeacon.coordinate = CGPointMake(3.7, 0.0);
    self.purpleBeacon.coordinate = CGPointMake(6.2, 8.0);
    self.mintBeacon.coordinate = CGPointMake(0.0, 8.0);

    self.beacons = [NSMutableArray array];
    [self.beacons addObject:self.mintBeacon];
    [self.beacons addObject:self.blueBeacon];
    [self.beacons addObject:self.purpleBeacon];

    for (US2BeaconWrapper *beacon in self.beacons) {
        self.maxX = MAX(self.maxX, beacon.coordinate.x);
        self.maxY = MAX(self.maxY, beacon.coordinate.y);
    }
    self.maxCoordinate = CGPointMake(self.maxX, self.maxY);

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


#pragma mark - ESTBeaconManagerDelegate


-(void)beaconManager:(ESTBeaconManager *)manager
     didRangeBeacons:(NSArray *)beacons
            inRegion:(ESTBeaconRegion *)region
{
    for (ESTBeacon* beacon in beacons)
    {
        [self mapBeacon:beacon];
    }

    [self updateMaxDistance];

    DLog(@"Closest beacon: %@. Distance: %.2f", self.closestBeacon.name, self.closestBeacon.beacon.distance.floatValue);
    [[NSNotificationCenter defaultCenter] postNotificationName:US2BeaconDataSingletonUpdate object:self];
}


-(void)mapBeacon: (ESTBeacon*)beacon
{
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
- (void) updateMaxDistance
{
    self.maxDistance = 0;

    for (US2BeaconWrapper *beaconWrapper in self.beacons)
    {
        CGFloat distance = beaconWrapper.beacon.distance.floatValue;
        if (distance > self.maxDistance)
        {
            self.maxDistance = distance;
        }
    }
}
#pragma mark - Public methods

-(US2BeaconWrapper*)closestBeacon
{
    US2BeaconWrapper *closestBeacon;
    for (US2BeaconWrapper *beaconWrapper in self.beacons)
    {
        if (beaconWrapper.beacon.distance.floatValue < 0) continue;
        
        if (!closestBeacon || closestBeacon.beacon.distance.floatValue > beaconWrapper.beacon.distance.floatValue )
        {
            closestBeacon = beaconWrapper;
        }
    }

    return closestBeacon;

}


@end
