//
//  US2BeaconWrapper.m
//  US2EstimoteDistances
//
//  Created by A on 13/02/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#import "US2BeaconWrapper.h"

@interface US2BeaconWrapper()
@property (readwrite) NSNumber *major;
@property (copy, readwrite) NSNumber *distance;

@property (nonatomic, strong) ESTBeacon *beacon;
@end


@implementation US2BeaconWrapper

- (id) initWithMajor:(NSNumber *)major name:(NSString *)name lightColor:(UIColor *)lightColor darkColor:(UIColor *)darkColor
{
    if (self = [super init])
    {
        self.major = major;
        self.name = name;
        
        self.lightColor = lightColor;
        self.darkColor = darkColor;
    }
    return self;
}


-(BOOL) isActive
{
    return (self.beacon && self.beacon.distance.floatValue > 0.0);
}

+(instancetype)beaconWrapperWithMajor:(NSNumber *)major name:(NSString *)name
{
    US2BeaconWrapper *beaconWrapper = [[self alloc] init];
    beaconWrapper.major = major;
    beaconWrapper.name = name;

    return beaconWrapper;
}

-(BOOL)mapUpdatedBeacon:(ESTBeacon *)beacon
{
    if (![self.major isEqualToNumber:beacon.major])
    {
        return false;
    }
    self.beacon = beacon;
    if (self.isActive) {
        self.distance = beacon.distance;
    }
    return true;
}

@end
