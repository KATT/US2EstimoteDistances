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
    return (self.beacon && self.beacon.distance.floatValue >= 0);
}
@end
