//
//  US2BeaconManager.h
//  US2EstimoteDistances
//
//  Created by Alexander Johansson on 25/02/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class US2BeaconManager;
@protocol US2BeaconManagerDelegate

-(void)beaconManagerDidUpdate:(US2BeaconManager *)beaconManager;

@end
@interface US2BeaconManager : NSObject

- (US2BeaconWrapper *)beaconAtIndex: (NSUInteger) index;

@property (nonatomic, weak) id<US2BeaconManagerDelegate> delegate;

// Get the current max distance
@property (nonatomic, readonly) CGFloat maxDistance;

// get the currently closest beacon
@property (nonatomic, strong, readonly) US2BeaconWrapper *closestBeacon;

// Get all the attached beacons
@property (nonatomic, strong, readonly) NSMutableArray *beaconWrappers;
@property (nonatomic, readonly) NSArray *activeBeaconWrappers;


@property (nonatomic, readonly) CGPoint maxCoordinate;

// register beacon 
- (void) registerBeaconWrapper: (US2BeaconWrapper *)beaconWrapper;

@end
