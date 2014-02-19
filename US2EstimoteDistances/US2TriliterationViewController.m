//
//  US2TriliterationViewController.m
//  US2EstimoteDistances
//
//  Created by A on 14/02/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#import "US2TriliterationViewController.h"

@interface US2TriliterationViewController ()

@end

@implementation US2TriliterationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beaconDataUpdated) name:US2BeaconDataSingletonUpdate object:nil];
}


-(void)beaconDataUpdated
{
    [self updateUI];
}

-(void)updateUI
{

}
@end
