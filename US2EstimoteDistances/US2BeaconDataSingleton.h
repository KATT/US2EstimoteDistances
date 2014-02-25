//
//  US2BeaconDataSingleton.h
//  US2EstimoteDistances
//
//  Created by A on 14/02/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//
#import <ESTBeaconManager.h>

#import "US2BeaconWrapper.h"
#import "US2BeaconManager.h"

#define US2BeaconDataSingletonUpdate @"US2BeaconDataSingletonUpdate"

@interface US2BeaconDataSingleton : NSObject


+ (US2BeaconDataSingleton *)sharedInstance;

@property (nonatomic, strong, readonly) US2BeaconManager* beaconManager;

@end
