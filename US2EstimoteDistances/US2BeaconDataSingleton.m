//
//  US2BeaconDataSingleton.m
//  US2EstimoteDistances
//
//  Created by Alexander Johansson on 14/03/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#import "US2BeaconDataSingleton.h"

@interface US2BeaconDataSingleton () <ESTBeaconManagerDelegate>

@property (nonatomic, strong) ESTBeaconManager* beaconManager;

@property (nonatomic, strong) NSMutableSet *discoveredBeacons;
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
    self.discoveredBeacons = [NSMutableSet set];
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


-(NSSet *)beacons
{
    return self.discoveredBeacons;
}

#pragma mark - ESTBeaconManagerDelegate


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

-(void)beaconManager:(ESTBeaconManager *)manager
     didRangeBeacons:(NSArray *)beacons
            inRegion:(ESTBeaconRegion *)region
{
    [self addBeacons: beacons];

    [[NSNotificationCenter defaultCenter] postNotificationName:US2BeaconDataSingletonUpdate object:self];
}



@end
