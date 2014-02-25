//
//  US2TriliterationViewController.m
//  US2EstimoteDistances
//
//  Created by Alexander Johansson on 14/02/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import <HexColors/HexColor.h>

#import "US2TriliterationViewController.h"
#import "US2BeaconAnnotationView.h"

@interface US2TriliterationViewController ()
@property (nonatomic, weak) CAShapeLayer *circleLayer;

@property (nonatomic, strong) NSMutableArray *beaconViews;
@property (nonatomic, strong) UIView *deviceAnnotationView;

@end

@implementation US2TriliterationViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.beaconViews = [NSMutableArray array];
    // Setup views
    [self setupViews];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUI) name:US2BeaconDataSingletonUpdate object:nil];

    self.view.autoresizesSubviews = NO;
}

-(void)updateUI
{
    for (US2BeaconAnnotationView *beaconAnnotationView in self.beaconViews) {
        [beaconAnnotationView updateUI];
    }

    [UIView animateWithDuration:0.6f delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
        [self updateTriliterlation];
    } completion:nil];

}
-(void)updateMapViewSize
{
    CGRect frame = CGRectMake(20.0, 30.0, self.view.frame.size.width-40.0, self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height - 50);
    self.mapView.frame = frame;

    // let's figure out the meter to px ratio
    // (TODO would be different if we had different w/h ratio)
    DLog(@"maxCoordinate %.f", BEACONDATA.maxCoordinate.x);
    self.pixelsPerMeter = frame.size.width / BEACONDATA.maxCoordinate.x;
    DLog(@"pixelsPerMeter: %.2f", self.pixelsPerMeter);
}

-(void) setupMapView
{
    self.mapView.autoresizingMask = UIViewAutoresizingNone;

    [self updateMapViewSize];
    
    
}
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    DLog(@"viewDidLayoutSubviews");

    [self updateMapViewSize];
    [self updateUI];

}
-(void)setupViews
{
    [self setupMapView];
    for (US2BeaconWrapper *beaconWrapper in BEACONDATA.beacons) {
        US2BeaconAnnotationView *beaconAnnotationView = [US2BeaconAnnotationView beaconAnnotationViewWithBeacon:beaconWrapper delegate:self];
        [self.beaconViews addObject:beaconAnnotationView];
        [self.mapView addSubview:beaconAnnotationView];

    }

    self.deviceAnnotationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    self.deviceAnnotationView.layer.cornerRadius = self.deviceAnnotationView.bounds.size.width /2;
    self.deviceAnnotationView.backgroundColor = [UIColor colorWithHexString:@"ffbf02"];
    self.deviceAnnotationView.center = CGPointMake(self.mapView.frame.size.width/2, self.mapView.frame.size.height/2);

    [self.mapView addSubview:self.deviceAnnotationView];

}

-(void) updateTriliterlation
{
    if (BEACONDATA.activeBeacons.count < 3) {
        self.deviceAnnotationView.alpha = 0.3;
        return;
    }
    self.deviceAnnotationView.alpha = 1;
    // TODO
    // rewrite interpolate
    // below is code taken straight from http://stackoverflow.com/a/20967649/590396, not ideal
    //P1,P2,P3 is the point and 2-dimension vector
    NSMutableArray *P1 = [[NSMutableArray alloc] initWithCapacity:0];

    [P1 addObject:[NSNumber numberWithDouble:[BEACONDATA beaconAtIndex:0].coordinate.x]];
    [P1 addObject:[NSNumber numberWithDouble:[BEACONDATA beaconAtIndex:0].coordinate.y]];


    NSMutableArray *P2 = [[NSMutableArray alloc] initWithCapacity:0];
    [P2 addObject:[NSNumber numberWithDouble:[BEACONDATA beaconAtIndex:1].coordinate.x]];
    [P2 addObject:[NSNumber numberWithDouble:[BEACONDATA beaconAtIndex:1].coordinate.y]];

    NSMutableArray *P3 = [[NSMutableArray alloc] initWithCapacity:0];
    [P3 addObject:[NSNumber numberWithDouble:[BEACONDATA beaconAtIndex:2].coordinate.x]];
    [P3 addObject:[NSNumber numberWithDouble:[BEACONDATA beaconAtIndex:2].coordinate.y]];

    //this is the distance between all the points and the unknown point
    double DistA = [BEACONDATA beaconAtIndex:0].beacon.distance.doubleValue;
    double DistB = [BEACONDATA beaconAtIndex:1].beacon.distance.doubleValue;
    double DistC = [BEACONDATA beaconAtIndex:2].beacon.distance.doubleValue;

    // ex = (P2 - P1)/(numpy.linalg.norm(P2 - P1))
    NSMutableArray *ex = [[NSMutableArray alloc] initWithCapacity:0];
    double temp = 0;
    for (int i = 0; i < [P1 count]; i++) {
        double t1 = [[P2 objectAtIndex:i] doubleValue];
        double t2 = [[P1 objectAtIndex:i] doubleValue];
        double t = t1 - t2;
        temp += (t*t);
    }
    for (int i = 0; i < [P1 count]; i++) {
        double t1 = [[P2 objectAtIndex:i] doubleValue];
        double t2 = [[P1 objectAtIndex:i] doubleValue];
        double exx = (t1 - t2)/sqrt(temp);
        [ex addObject:[NSNumber numberWithDouble:exx]];
    }

    // i = dot(ex, P3 - P1)
    NSMutableArray *p3p1 = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i < [P3 count]; i++) {
        double t1 = [[P3 objectAtIndex:i] doubleValue];
        double t2 = [[P1 objectAtIndex:i] doubleValue];
        double t3 = t1 - t2;
        [p3p1 addObject:[NSNumber numberWithDouble:t3]];
    }

    double ival = 0;
    for (int i = 0; i < [ex count]; i++) {
        double t1 = [[ex objectAtIndex:i] doubleValue];
        double t2 = [[p3p1 objectAtIndex:i] doubleValue];
        ival += (t1*t2);
    }

    // ey = (P3 - P1 - i*ex)/(numpy.linalg.norm(P3 - P1 - i*ex))
    NSMutableArray *ey = [[NSMutableArray alloc] initWithCapacity:0];
    double p3p1i = 0;
    for (int  i = 0; i < [P3 count]; i++) {
        double t1 = [[P3 objectAtIndex:i] doubleValue];
        double t2 = [[P1 objectAtIndex:i] doubleValue];
        double t3 = [[ex objectAtIndex:i] doubleValue] * ival;
        double t = t1 - t2 -t3;
        p3p1i += (t*t);
    }
    for (int i = 0; i < [P3 count]; i++) {
        double t1 = [[P3 objectAtIndex:i] doubleValue];
        double t2 = [[P1 objectAtIndex:i] doubleValue];
        double t3 = [[ex objectAtIndex:i] doubleValue] * ival;
        double eyy = (t1 - t2 - t3)/sqrt(p3p1i);
        [ey addObject:[NSNumber numberWithDouble:eyy]];
    }


    // ez = numpy.cross(ex,ey)
    // if 2-dimensional vector then ez = 0
    NSMutableArray *ez = [[NSMutableArray alloc] initWithCapacity:0];
    double ezx;
    double ezy;
    double ezz;
    if ([P1 count] !=3){
        ezx = 0;
        ezy = 0;
        ezz = 0;

    }else{
        ezx = ([[ex objectAtIndex:1] doubleValue]*[[ey objectAtIndex:2]doubleValue]) - ([[ex objectAtIndex:2]doubleValue]*[[ey objectAtIndex:1]doubleValue]);
        ezy = ([[ex objectAtIndex:2] doubleValue]*[[ey objectAtIndex:0]doubleValue]) - ([[ex objectAtIndex:0]doubleValue]*[[ey objectAtIndex:2]doubleValue]);
        ezz = ([[ex objectAtIndex:0] doubleValue]*[[ey objectAtIndex:1]doubleValue]) - ([[ex objectAtIndex:1]doubleValue]*[[ey objectAtIndex:0]doubleValue]);

    }

    [ez addObject:[NSNumber numberWithDouble:ezx]];
    [ez addObject:[NSNumber numberWithDouble:ezy]];
    [ez addObject:[NSNumber numberWithDouble:ezz]];


    // d = numpy.linalg.norm(P2 - P1)
    double d = sqrt(temp);

    // j = dot(ey, P3 - P1)
    double jval = 0;
    for (int i = 0; i < [ey count]; i++) {
        double t1 = [[ey objectAtIndex:i] doubleValue];
        double t2 = [[p3p1 objectAtIndex:i] doubleValue];
        jval += (t1*t2);
    }

    // x = (pow(DistA,2) - pow(DistB,2) + pow(d,2))/(2*d)
    double xval = (pow(DistA,2) - pow(DistB,2) + pow(d,2))/(2*d);

    // y = ((pow(DistA,2) - pow(DistC,2) + pow(i,2) + pow(j,2))/(2*j)) - ((i/j)*x)
    double yval = ((pow(DistA,2) - pow(DistC,2) + pow(ival,2) + pow(jval,2))/(2*jval)) - ((ival/jval)*xval);

    // z = sqrt(pow(DistA,2) - pow(x,2) - pow(y,2))
    // if 2-dimensional vector then z = 0
    double zval;
    if ([P1 count] !=3){
        zval = 0;
    }else{
        zval = sqrt(pow(DistA,2) - pow(xval,2) - pow(yval,2));
    }

    // triPt = P1 + x*ex + y*ey + z*ez
    NSMutableArray *triPt = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i < [P1 count]; i++) {
        double t1 = [[P1 objectAtIndex:i] doubleValue];
        double t2 = [[ex objectAtIndex:i] doubleValue] * xval;
        double t3 = [[ey objectAtIndex:i] doubleValue] * yval;
        double t4 = [[ez objectAtIndex:i] doubleValue] * zval;
        double triptx = t1+t2+t3+t4;
        [triPt addObject:[NSNumber numberWithDouble:triptx]];
    }

//    NSLog(@"ex %@",ex);
//    NSLog(@"i %f",ival);
//    NSLog(@"ey %@",ey);
//    NSLog(@"d %f",d);
//    NSLog(@"j %f",jval);
//    NSLog(@"x %f",xval);
//    NSLog(@"y %f",yval);
//    NSLog(@"y %f",yval);
//    NSLog(@"final result %@",triPt);


    NSNumber *x = [triPt objectAtIndex:0];
    NSNumber *y = [triPt objectAtIndex:1];
    self.deviceAnnotationView.center = CGPointMake(x.floatValue*self.pixelsPerMeter, y.floatValue*self.pixelsPerMeter);
}
@end
