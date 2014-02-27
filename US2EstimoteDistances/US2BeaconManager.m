//
//  US2BeaconManager.m
//  US2EstimoteDistances
//
//  Created by Alexander Johansson on 25/02/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#import "US2BeaconManager.h"


@interface US2BeaconManager () <ESTBeaconManagerDelegate>


@property (nonatomic, strong) ESTBeaconManager* beaconManager;
@property (readwrite) CGFloat maxDistance;
@property (readwrite) NSMutableArray *beaconWrappers;


@property (nonatomic, strong) NSMutableSet *discoveredBeacons;
@end

@implementation US2BeaconManager

- (id)init
{
    if (self = [super init])
    {
        [self setup];
    }
    return self;
}

- (void) setup
{
    self.beaconWrappers = [NSMutableArray array];
    self.discoveredBeacons = [NSMutableSet set];

    // Setup views
    [self setupBeaconManager];
}


-(void) setupBeaconManager
{
    // setup Estimote beacon manager
    // create manager instance
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
//    self.beaconManager.avoidUnknownStateBeacons = YES;

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
    [self addBeacons: beacons];
    [self mapBeacons:self.discoveredBeacons];

//    DLog(@"%u discovered beacons.", self.discoveredBeacons.count);
    [self updateMaxDistance];

//    DLog(@"Closest beacon: %@. Distance: %.2f", self.closestBeacon.name, self.closestBeacon.beacon.distance.floatValue);
    [self.delegate beaconManagerDidUpdate:self];
}

-(BOOL)mapBeacon: (ESTBeacon*)beacon
{
    BOOL found = false;
    for (US2BeaconWrapper *beaconWrapper in self.beaconWrappers) {
        if ([beaconWrapper.major isEqualToNumber:beacon.major])
        {
            beaconWrapper.beacon = beacon;
            found = true;
        }
    }
    return found;
}


-(void) mapBeacons: (NSSet *)beacons
{
    for (ESTBeacon *beacon in beacons)
    {
        [self mapBeacon: beacon];
    }
}

- (void) addBeacons: (NSArray *) updatedBeacons
{

    for (ESTBeacon *beacon in updatedBeacons)
    {
        if (![self.discoveredBeacons containsObject:beacon])
        {
            [self.discoveredBeacons addObject: beacon];
        }
    }
    
}
- (void) updateMaxDistance
{
    self.maxDistance = 0;

    for (US2BeaconWrapper *beaconWrapper in self.beaconWrappers)
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
    for (US2BeaconWrapper *beaconWrapper in self.beaconWrappers)
    {
        if (!beaconWrapper.isActive) continue;

        if (!closestBeacon || closestBeacon.beacon.distance.floatValue > beaconWrapper.beacon.distance.floatValue )
        {
            closestBeacon = beaconWrapper;
        }
    }

    return closestBeacon;

}

- (US2BeaconWrapper *)beaconAtIndex: (NSUInteger) index
{
    return [self.beaconWrappers objectAtIndex:index];
}


- (NSArray *) activeBeaconWrappers
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isActive == YES"];
    return [self.beaconWrappers filteredArrayUsingPredicate:predicate];
}


- (void) registerBeaconWrapper: (US2BeaconWrapper *)beaconWrapper
{
    [self.beaconWrappers addObject:beaconWrapper];
}

-(CGPoint) maxCoordinate
{
    CGFloat maxX = 0, maxY = 0;
    for (US2BeaconWrapper *beacon in self.beaconWrappers) {
        maxX = MAX(maxX, beacon.coordinate.x);
        maxY = MAX(maxY, beacon.coordinate.y);
    }
    return CGPointMake(maxX, maxY);

}
@end

