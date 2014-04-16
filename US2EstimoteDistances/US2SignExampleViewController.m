//
//  US2SignExampleViewController.m
//  US2EstimoteDistances
//
//  Created by Alexander Johansson on 16/04/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#import "US2SignExampleViewController.h"

#import <AudioToolbox/AudioServices.h>

#import <TransitionKit/TransitionKit.h>
#import "US2BeaconManager.h"


#import "US2ColorQueue.h"
#import "US2WayFinderInstruction.h"

// audios
NSString *const kSignAudio = @"sign.m4a";


@interface US2SignExampleViewController ()<US2BeaconManagerDelegate>



@property (nonatomic, strong) US2WayFinderInstruction *signInstruction;

@property (nonatomic, strong) US2ColorQueue *colorQueue;

@property (nonatomic, strong) US2BeaconManager *beaconManager;

// beacons
@property (nonatomic, strong) US2BeaconWrapper *blueBeacon;


@property (nonatomic) BOOL isStarted;



@end

@implementation US2SignExampleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
	// Do any additional setup after loading the view.
    [self setup];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    UIApplication.sharedApplication.idleTimerDisabled = YES;
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidAppear:animated];
    UIApplication.sharedApplication.idleTimerDisabled = NO;
}

- (void) setupBeaconManager
{
    self.beaconManager = [[US2BeaconManager alloc] init];
    self.beaconManager.delegate = self;

    self.blueBeacon = [US2BeaconWrapper beaconWrapperWithMajor:@4092 name:@"Blue"];
    [self.beaconManager registerBeaconWrapper:self.blueBeacon];
}
- (void) setupInstructions
{
    self.signInstruction = [US2WayFinderInstruction instructionWithText:@"Turn left for the Northern Line.\n\nTurn right for the Central line.\n\nContinue to walk straight for The Victoria line." audioFileName:kSignAudio];
}

- (void) setupViews
{
    self.colorQueue = [[US2ColorQueue alloc] init];
    [self.colorQueue shuffle];

    [self.signView removeFromSuperview];

    self.awaitingView = [self viewWithText:@"Looking for signs.."small:NO];
    [self.view addSubview:self.awaitingView];

    self.signView = [self viewWithText:self.signInstruction.text small:YES];

}
- (void) setup
{
    self.isStarted = NO;

    [self setupInstructions];
    [self setupViews];
    [self setupBeaconManager];

#if TARGET_IPHONE_SIMULATOR
    [self performSelector:@selector(start) withObject:nil afterDelay:1.0f];
#endif

}

- (void) start {
    if (self.isStarted) {
        DLog(@"Already started");
        return;
    }
    self.isStarted = YES;

    [UIView transitionFromView:self.awaitingView toView:self.signView duration:0.6f options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
        DLog(@"Meow!");
    }];
    [self.signInstruction play];

    [self vibrate];

}


#pragma mark - US2BeaconManagerDelegate

-(void)beaconManagerDidUpdate:(US2BeaconManager *)beaconManager
{

    DLog(@"Closest beacon: %@, distance: %.2f", self.beaconManager.closestBeacon.name, self.beaconManager.closestBeacon.distance.floatValue);

    [self start];

}

#pragma mark - view shizzle

- (UIView *)viewWithText: (NSString *)text small:(BOOL)isSmall
{
    UIView *view;


    view = [[UIView alloc] initWithFrame:self.view.frame];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    // self.currentPage.backgroundColor = self.colorQueue.nextColor;

    UILabel *textLabel;

    textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, view.frame.size.width-20, view.frame.size.height)];
    textLabel.text = text.uppercaseString;
    textLabel.numberOfLines = 0;
    textLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    textLabel.font = [UIFont fontWithName:@"FuturaLTPro-XBold" size:42.0f ];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = [UIColor nonWhiteColor];
    textLabel.textAlignment = NSTextAlignmentCenter;


    if (isSmall) {
        textLabel.font =  [UIFont fontWithName:@"FuturaLTPro-XBold" size:30.0f ];
        textLabel.textAlignment = NSTextAlignmentLeft;
    }

    [view addSubview:textLabel];

    textLabel.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2);

    view.backgroundColor = self.colorQueue.nextColor;
    
    return view;
}


#pragma mark - shake
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        DLog(@"Shake!");
        if (!self.signInstruction.isPlaying)
        {
            DLog(@"play sound!");
            [self.signInstruction play];
        }
    }
}


#pragma mark - vibrate shizzle

- (void) vibrate
{
    AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
}


@end
