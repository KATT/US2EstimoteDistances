//
//  US2BeaconDataSingleton.h
//  US2EstimoteDistances
//
//  Created by Alexander Johansson on 14/03/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#define US2BeaconDataSingletonUpdate @"US2BeaconDataSingletonUpdate"

@interface US2BeaconDataSingleton : NSObject


+ (US2BeaconDataSingleton *)sharedInstance;

@property (nonatomic, strong, readonly) NSSet *beacons;

@end
