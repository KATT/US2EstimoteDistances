//
//  US2BeaconDataSingleton.m
//  US2EstimoteDistances
//
//  Created by A on 14/02/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#import "US2BeaconDataSingleton.h"

@implementation US2BeaconDataSingleton

+ (id)sharedInstance
{
    static dispatch_once_t onceToken = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&onceToken, ^{
        _sharedObject = [[self alloc] init];
    });

    return _sharedObject;
}

@end
