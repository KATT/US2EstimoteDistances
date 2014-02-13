//
//  US2ViewController.m
//  US2EstimoteDistances
//
//  Created by A on 13/02/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#import "US2ViewController.h"

#import <ESTBeaconManager.h>

#import "US2BeaconWrapper.h"

@interface US2ViewController () <ESTBeaconManagerDelegate>

@property (nonatomic, strong) ESTBeaconManager* beaconManager;

// Wrappers for our beacons
@property (nonatomic, strong) US2BeaconWrapper *mintBeacon;
@property (nonatomic, strong) US2BeaconWrapper *purpleBeacon;
@property (nonatomic, strong) US2BeaconWrapper *blueBeacon;

// Views
@property (nonatomic, strong) UIView *mintBeaconView;
@property (nonatomic, strong) UIView *purpleBeaconView;
@property (nonatomic, strong) UIView *blueBeaconView;

@property (nonatomic, assign) CGFloat maxDistance;

@property (nonatomic, readonly) NSArray *beacons;
@end

@implementation US2ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Setup beacon wrapper objects
    self.mintBeacon = [[US2BeaconWrapper alloc] initWithColor:[UIColor colorWithRed:152.0/255.0 green:197.0/255.0 blue:166.0/255.0 alpha:1] andName:@"Mint"];
    self.purpleBeacon = [[US2BeaconWrapper alloc] initWithColor:[UIColor colorWithRed:92.0/255.0 green:89.0/255.0 blue:167.0/255.0 alpha:1] andName:@"Purple"];
    self.blueBeacon = [[US2BeaconWrapper alloc] initWithColor:[UIColor colorWithRed:159.0/255.0 green:221.0/255.0 blue:249.0/255.0 alpha:1] andName:@"Blue"];

    // Setup views
    [self setupViews];

    [self setupBeaconManager];
}

-(void) setupBeaconManager
{
    // setup Estimote beacon manager
    // create manager instance
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    self.beaconManager.avoidUnknownStateBeacons = YES;

    // create sample region object (you can additionaly pass major / minor values)
    ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
                                                                  identifier:@"EstimoteSampleRegion"];

    // start looking for estimote beacons in region
    // when beacon ranged beaconManager:didRangeBeacons:inRegion: invoked
    [self.beaconManager startRangingBeaconsInRegion:region];
}
-(void)setupViews
{
    CGFloat aThird = self.view.frame.size.width/3;
    CGFloat height = self.view.frame.size.height;

    self.mintBeaconView     = [[UIView alloc] initWithFrame:CGRectMake(aThird*0, 0, aThird, height)];
    self.blueBeaconView     = [[UIView alloc] initWithFrame:CGRectMake(aThird*1, 0, aThird, height)];
    self.purpleBeaconView   = [[UIView alloc] initWithFrame:CGRectMake(aThird*2, 0, aThird, height)];

    self.mintBeaconView.backgroundColor     = self.mintBeacon.color;
    self.blueBeaconView.backgroundColor     = self.blueBeacon.color;
    self.purpleBeaconView.backgroundColor   = self.purpleBeacon.color;

    self.mintBeaconView.autoresizingMask    = UIViewAutoresizingFlexibleHeight;
    self.blueBeaconView.autoresizingMask    = UIViewAutoresizingFlexibleHeight;
    self.purpleBeaconView.autoresizingMask  = UIViewAutoresizingFlexibleHeight;


    [self.view addSubview:self.mintBeaconView];
    [self.view addSubview:self.blueBeaconView];
    [self.view addSubview:self.purpleBeaconView];
}

-(void)mapBeacon: (ESTBeacon*)beacon {
    if ([beacon.major isEqualToNumber: @35729]) {
        // Mint
        self.mintBeacon.beacon = beacon;
    } else if ([beacon.major isEqualToNumber: @4092]) {
        // Blue
        self.blueBeacon.beacon = beacon;
    } else if ([beacon.major isEqualToNumber: @50667]) {
        // Purple
        self.purpleBeacon.beacon = beacon;
    } else {
        DLog(@"Unidentified beacon found on distance %@. Beacon: %@", beacon.distance, beacon);
    }

}


-(void)beaconManager:(ESTBeaconManager *)manager
     didRangeBeacons:(NSArray *)beacons
            inRegion:(ESTBeaconRegion *)region
{
    for (ESTBeacon* beacon in beacons)
    {
        [self mapBeacon:beacon];
    }

    [self updateMaxDistance];
    [self updateUI];


}


- (NSArray *) beacons
{
    return [NSArray arrayWithObjects:self.mintBeacon, self.purpleBeacon, self.blueBeacon, nil];
}
- (void) updateBeacon: (US2BeaconWrapper *) beaconWrapper withView: (UIView *) view
{

    CGFloat distance = beaconWrapper.beacon.distance.floatValue;

    if (distance < 0)
    {
        DLog(@"WHAT?");
    }

    CGFloat fill = 1.0 - distance/(self.maxDistance * 1.1);

    CGFloat newHeight = self.view.frame.size.height*fill;
    CGFloat newY = self.view.frame.size.height - newHeight;
    CGRect newRect = CGRectMake(view.frame.origin.x, newY, view.frame.size.width, newHeight);
    view.frame = newRect;




    
    DLog(@"%@: %.2f", beaconWrapper.name, beaconWrapper.beacon.distance.floatValue);
}

- (void) updateMaxDistance
{
    for (US2BeaconWrapper *beaconWrapper in self.beacons) {
        CGFloat distance = beaconWrapper.beacon.distance.floatValue;
        if (distance > self.maxDistance)
        {
            self.maxDistance = distance;
        }
    }
}
- (void) updateUI
{

    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
        [self updateBeacon:self.mintBeacon withView:self.mintBeaconView];
        [self updateBeacon:self.purpleBeacon withView:self.purpleBeaconView];
        [self updateBeacon:self.blueBeacon withView:self.blueBeaconView];

    } completion:nil];

}


@end
