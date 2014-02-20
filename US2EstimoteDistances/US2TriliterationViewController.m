//
//  US2TriliterationViewController.m
//  US2EstimoteDistances
//
//  Created by A on 14/02/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "US2TriliterationViewController.h"
#import "US2BeaconAnnotationView.h"

@interface US2TriliterationViewController ()
@property (nonatomic, weak) CAShapeLayer *circleLayer;


@property (nonatomic, strong) US2BeaconAnnotationView *mintBeaconView;
@property (nonatomic, strong) US2BeaconAnnotationView *purpleBeaconView;
@property (nonatomic, strong) US2BeaconAnnotationView *blueBeaconView;

@property (nonatomic) CGFloat pixelsPerMeter;
@end

@implementation US2TriliterationViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Setup views
    [self setupViews];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUI) name:US2BeaconDataSingletonUpdate object:nil];

}

-(void)updateUI
{
    [self.purpleBeaconView updateUI];
    [self.mintBeaconView updateUI];
    [self.blueBeaconView updateUI];

}

-(void) setupMapView
{
    DLog(@"Mapview: %@", self.mapView);

    CGRect frame = CGRectMake(10, 10, self.view.frame.size.width-20, self.view.frame.size.height-20);
    self.mapView.autoresizingMask = UIViewAutoresizingNone;
    self.mapView.frame = frame;

    // let's figure out the meter to px ratio
    // (TODO would be different if we had different w/h ratio)
    self.pixelsPerMeter = frame.size.width / BEACONDATA.maxCoordinate.x;
    DLog(@"pixelsPerMeter: %.2f", self.pixelsPerMeter);
    
    
}
-(void)setupViews
{
    [self setupMapView];

    self.mintBeaconView     = [US2BeaconAnnotationView beaconAnnotationViewWithBeacon:BEACONDATA.mintBeacon pixelRatio:self.pixelsPerMeter];
    self.blueBeaconView     = [US2BeaconAnnotationView beaconAnnotationViewWithBeacon:BEACONDATA.blueBeacon pixelRatio:self.pixelsPerMeter];
    self.purpleBeaconView     = [US2BeaconAnnotationView beaconAnnotationViewWithBeacon:BEACONDATA.purpleBeacon pixelRatio:self.pixelsPerMeter];
    //
    [self.mapView addSubview:self.mintBeaconView];
    [self.mapView addSubview:self.blueBeaconView];
    [self.mapView addSubview:self.purpleBeaconView];
}
@end
