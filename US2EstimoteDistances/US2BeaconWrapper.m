//
//  US2BeaconWrapper.m
//  US2EstimoteDistances
//
//  Created by A on 13/02/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#import "US2BeaconWrapper.h"

@implementation US2BeaconWrapper
- (id) initWithName:(NSString *)name lightColor:(UIColor *) lightColor darkColor:(UIColor *) darkColor
{
    if (self = [super init])
    {
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
