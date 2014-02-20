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

    [self makeCircle:self.mintBeaconView];
    [self makeCircle:self.blueBeaconView];
    [self makeCircle:self.purpleBeaconView];

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


    

//
//    CGFloat aThird = self.view.frame.size.width/3;
//    CGFloat height = self.view.frame.size.height;
    //
    self.mintBeaconView     = [US2BeaconAnnotationView beaconAnnotationViewWithBeacon:BEACONDATA.mintBeacon pixelRatio:self.pixelsPerMeter];
    self.blueBeaconView     = [US2BeaconAnnotationView beaconAnnotationViewWithBeacon:BEACONDATA.blueBeacon pixelRatio:self.pixelsPerMeter];
    self.purpleBeaconView     = [US2BeaconAnnotationView beaconAnnotationViewWithBeacon:BEACONDATA.purpleBeacon pixelRatio:self.pixelsPerMeter];
//    self.blueBeaconView     = [[US2BeaconBarView alloc] initWithFrame:CGRectMake(aThird*1, 0, aThird, height) beaconWrapper:BEACONDATA.blueBeacon];
//    self.purpleBeaconView   = [[US2BeaconBarView alloc] initWithFrame:CGRectMake(aThird*2, 0, aThird, height) beaconWrapper:BEACONDATA.purpleBeacon];
//
    //
    [self.mapView addSubview:self.mintBeaconView];
    [self.mapView addSubview:self.blueBeaconView];
    [self.mapView addSubview:self.purpleBeaconView];


    
//
//    UIView *statusBarBackgroundView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
//    statusBarBackgroundView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
//    [self.view addSubview:statusBarBackgroundView];
}

#pragma mark - draw circle

- (void)makeCircle: (US2BeaconAnnotationView*)annotationView
{
    CGFloat distance = annotationView.beaconWrapper.beacon.distance.floatValue;
    CGFloat radius = distance*self.pixelsPerMeter;
    if (distance <= 0.0)
    {
        return;
    }


    CAShapeLayer *circle = [CAShapeLayer layer];
    // Make a circular shape
    circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*radius, 2.0*radius)
                                             cornerRadius:radius].CGPath;
    // Center the shape in self.view
    circle.position = CGPointMake(annotationView.center.x-radius,
                                  annotationView.center.y-radius);

    // Configure the apperence of the circle
    circle.fillColor = [UIColor clearColor].CGColor;
    circle.strokeColor = [UIColor blackColor].CGColor;
    circle.lineWidth = 5;

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:annotationView.center
                    radius:radius
                startAngle:0.0
                  endAngle:M_PI * 2.0
                 clockwise:YES];
    // Add to parent layer
    [self.mapView.layer addSublayer:circle];
    
}

@end
