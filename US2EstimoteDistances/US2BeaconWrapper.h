//
//  US2BeaconWrapper.h
//  US2EstimoteDistances
//
//  Created by A on 13/02/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ESTBeacon;
@interface US2BeaconWrapper : NSObject


+(instancetype)beaconWrapperWithMajor:(NSNumber*)major name:(NSString*)name;
- (id) initWithMajor:(NSNumber*)major name:(NSString*)name lightColor:(UIColor *) lightColor darkColor:(UIColor *) darkColor;

-(BOOL)mapUpdatedBeacon: (ESTBeacon*)beacon;


@property (nonatomic, readonly) NSNumber *major;
@property (nonatomic, copy, readonly) NSNumber *distance;

@property (nonatomic, copy) NSString *name;


@property (nonatomic, strong) UIColor *lightColor;
@property (nonatomic, strong) UIColor *darkColor;

@property (nonatomic, assign) CGPoint coordinate;

@property (nonatomic, readonly) BOOL isActive;


@end
