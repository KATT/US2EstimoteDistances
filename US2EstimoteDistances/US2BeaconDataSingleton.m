//
//  US2BeaconDataSingleton.m
//  US2EstimoteDistances
//
//  Created by A on 14/02/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#import "US2BeaconDataSingleton.h"

#import <HexColors/HexColor.h>

@interface US2BeaconDataSingleton () <US2BeaconManagerDelegate>

@property (readwrite) US2BeaconManager* beaconManager;


// Wrappers for our beacons
@property (nonatomic, strong) US2BeaconWrapper *mintBeacon;
@property (nonatomic, strong) US2BeaconWrapper *purpleBeacon;
@property (nonatomic, strong) US2BeaconWrapper *blueBeacon;
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
    // Setup views
    [self setupBeaconManager];
    [self setupBeaconWrappers];

}


-(void) setupBeaconManager
{
    self.beaconManager = [[US2BeaconManager alloc] init];
    self.beaconManager.delegate = self;

}

-(void)setupBeaconWrappers
{
    // Setup known beacons
    // TODO read this from a plist or something
    self.mintBeacon = [[US2BeaconWrapper alloc] initWithMajor:@35729 name:@"Mint" lightColor:[UIColor colorWithHexString:@"98c5a6"] darkColor:[UIColor colorWithHexString:@"5c7865"]];
    self.purpleBeacon = [[US2BeaconWrapper alloc] initWithMajor:@50667 name:@"Purple" lightColor:[UIColor colorWithHexString:@"5c59a7"] darkColor:[UIColor colorWithHexString:@"3f3d73"]];
    self.blueBeacon = [[US2BeaconWrapper alloc] initWithMajor: @4092 name:@"Blue" lightColor:[UIColor colorWithHexString:@"9fddf9"] darkColor:[UIColor colorWithHexString:@"6f9aad"]];

    self.blueBeacon.coordinate = CGPointMake(3.7, 0.0);
    self.purpleBeacon.coordinate = CGPointMake(6.2, 8.0);
    self.mintBeacon.coordinate = CGPointMake(0.0, 8.0);

    [self.beaconManager registerBeaconWrapper:self.mintBeacon];
    [self.beaconManager registerBeaconWrapper:self.blueBeacon];
    [self.beaconManager registerBeaconWrapper:self.purpleBeacon];
}

#pragma - US2BeaconManagerDelegate
-(void) beaconManagerDidUpdate:(US2BeaconManager *)beaconManager
{
    [[NSNotificationCenter defaultCenter] postNotificationName:US2BeaconDataSingletonUpdate object:self];
}

@end
