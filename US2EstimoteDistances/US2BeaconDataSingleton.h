//
//  US2BeaconDataSingleton.h
//  US2EstimoteDistances
//
//  Created by A on 14/02/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//
#import <ESTBeaconManager.h>

#import "US2BeaconWrapper.h"

#define US2BeaconDataSingletonUpdate @"US2BeaconDataSingletonUpdate"

@interface US2BeaconDataSingleton : NSObject


+ (US2BeaconDataSingleton *)sharedInstance;


// Wrappers for our beacons
@property (nonatomic, strong, readonly) US2BeaconWrapper *mintBeacon;
@property (nonatomic, strong, readonly) US2BeaconWrapper *purpleBeacon;
@property (nonatomic, strong, readonly) US2BeaconWrapper *blueBeacon;

@property (nonatomic, assign, readonly) CGFloat maxDistance;

@property (nonatomic, strong, readonly) NSMutableArray *beacons;

@end
