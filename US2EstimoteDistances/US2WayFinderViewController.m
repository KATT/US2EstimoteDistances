//
//  US2WayFinderViewController.m
//  US2EstimoteDistances
//
//  Created by Alexander Johansson on 26/02/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#import "US2WayFinderViewController.h"
#import "US2BeaconManager.h"

@interface US2WayFinderViewController ()<US2BeaconManagerDelegate>

@property (nonatomic, strong) US2BeaconManager *beaconManager;

@end

@implementation US2WayFinderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    DLog(@"Hello from %@", NSStringFromClass([self class]));
}

- (void) setupBeaconManager
{

    self.beaconManager = [[US2BeaconManager alloc] init];
}

- (void) setup
{
    [self setupBeaconManager];
}
#pragma mark - US2BeaconManagerDelegate

-(void)beaconManagerDidUpdate:(US2BeaconManager *)beaconManager
{
    
}
@end
