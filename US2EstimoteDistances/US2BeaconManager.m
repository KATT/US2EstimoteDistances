//
//  US2BeaconManager.m
//  US2EstimoteDistances
//
//  Created by Alexander Johansson on 25/02/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#import "US2BeaconManager.h"
#import "US2BeaconDataSingleton.h"

@interface US2BeaconManager () <ESTBeaconManagerDelegate>


@property (nonatomic, strong) ESTBeaconManager* beaconManager;
@property (readwrite) CGFloat maxDistance;
@property (readwrite) NSMutableArray *beaconWrappers;


@property (readonly) US2BeaconDataSingleton *beaconData;
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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beaconDataDidUpdate) name:US2BeaconDataSingletonUpdate object:self.beaconData];
}

-(US2BeaconDataSingleton*) beaconData
{
    return [US2BeaconDataSingleton sharedInstance];
}




-(void)beaconDataDidUpdate
{
    [self mapBeacons:self.beaconData.beacons];

    DLog(@"%u discovered beacons.", self.beaconData.beacons.count);
    [self updateMaxDistance];

//    DLog(@"Closest beacon: %@. Distance: %.2f", self.closestBeacon.name, self.closestBeacon.beacon.distance.floatValue);
    [self.delegate beaconManagerDidUpdate:self];
}

-(void)mapBeacon: (ESTBeacon*)beacon
{
    for (US2BeaconWrapper *beaconWrapper in self.beaconWrappers) {
        [beaconWrapper mapUpdatedBeacon:beacon];
    }
}


-(void) mapBeacons: (NSSet *)beacons
{
    for (ESTBeacon *beacon in beacons)
    {
        [self mapBeacon: beacon];
    }
}

- (void) updateMaxDistance
{
    self.maxDistance = 0;

    for (US2BeaconWrapper *beaconWrapper in self.beaconWrappers)
    {
        CGFloat distance = beaconWrapper.distance.floatValue;
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

        if (!closestBeacon || closestBeacon.distance.floatValue > beaconWrapper.distance.floatValue )
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
    if (beaconWrapper)
    {
        [self.beaconWrappers addObject:beaconWrapper];
    }
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

