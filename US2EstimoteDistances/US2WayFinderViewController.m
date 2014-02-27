//
//  US2WayFinderViewController.m
//  US2EstimoteDistances
//
//  Created by Alexander Johansson on 26/02/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <TransitionKit/TransitionKit.h>
#import "TKStateMachine+US2Extensions.h"

#import "US2WayFinderViewController.h"
#import "US2BeaconManager.h"

#import "US2ColorQueue.h"

NSString *const kStartingState = @"kStartingState";
NSString *const kWalkingLeft = @"kWalkingLeft";

NSString *const kStartingEvent = @"kWalkLeft";


@interface US2WayFinderViewController ()<US2BeaconManagerDelegate>

// ui
@property (nonatomic, strong) UILabel *currentStateLabel;
@property (nonatomic, strong) US2ColorQueue *colorQueue;

// audio related
@property (nonatomic) BOOL isAudioReady;

@property (nonatomic, strong) AVAudioPlayer *walkLeftAudio;

// beacon manager
@property (nonatomic, strong) US2BeaconManager *beaconManager;

// beacons
@property (nonatomic, strong) US2BeaconWrapper *blueBeacon2;
@property (nonatomic, strong) US2BeaconWrapper *mintBeacon2;
@property (nonatomic, strong) US2BeaconWrapper *purpleBeacon2;


// state
@property (nonatomic, strong) TKStateMachine *stateMachine;

@property (nonatomic, strong) UIView *currentPage;
@property (nonatomic, strong) UIView *nextPage;
@end

@implementation US2WayFinderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setup];
}

- (void) setupStateMachine
{
    self.stateMachine = [TKStateMachine new];

    TKState *startingState = [self.stateMachine addStateWithName:kStartingState];

    [startingState setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
        DLog(@"Previous state: %@", transition.sourceState);

        if (!transition.sourceState) {
            DLog(@"Please exit the door and walk left");
        }
    }];

    // first step, walk left
    TKState *walkingLeftState = [self.stateMachine addStateWithName:kWalkingLeft];

    [walkingLeftState setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
        DLog(@"Please walk left");
    }];




}
- (void) setupBeaconManager
{
    self.beaconManager = [[US2BeaconManager alloc] init];
    self.beaconManager.delegate = self;

    self.blueBeacon2 = [US2BeaconWrapper beaconWrapperWithMajor:@57830 name:@"Blue #2"];
    self.mintBeacon2 = [US2BeaconWrapper beaconWrapperWithMajor:@43211 name:@"Mint #2"];
    self.purpleBeacon2 = [US2BeaconWrapper beaconWrapperWithMajor:@41032 name:@"Purple #2"];

    [self.beaconManager registerBeaconWrapper:self.blueBeacon2];
    [self.beaconManager registerBeaconWrapper:self.mintBeacon2];
    [self.beaconManager registerBeaconWrapper:self.purpleBeacon2];

}
- (AVAudioPlayer *) audioPlayerWithFileName: (NSString *)fileName
{

	NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", NSBundle.mainBundle.resourcePath, fileName]];

	NSError *error;
    AVAudioPlayer *audioPlayer;

    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
	audioPlayer.numberOfLoops = 0;

    [audioPlayer prepareToPlay];
    if (error)
    {
        DLog(@":( %@ %@", error.description, url);
    }

    return audioPlayer;
}
- (void) setupAudio
{
    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.ustwo.background", 0);

    dispatch_async(backgroundQueue, ^{
        self.walkLeftAudio = [self audioPlayerWithFileName:@"walk-left.m4a"];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isAudioReady = YES;
            DLog(@"Audio ready");
            [self.walkLeftAudio play];
        });
    });
}
- (UIView *)viewWithText: (NSString *)text
{
    UIView *view;


    view = [[UIView alloc] initWithFrame:self.view.frame];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    // self.currentPage.backgroundColor = self.colorQueue.nextColor;

    UILabel *textLabel;

    textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, view.frame.size.width-20, view.frame.size.height)];
    textLabel.text = text;
    textLabel.numberOfLines = 0;
    textLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:30.0f];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.textAlignment = NSTextAlignmentCenter;

    [view addSubview:textLabel];

    textLabel.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2);

    return view;
}

- (void) setupViews
{
    self.colorQueue = [[US2ColorQueue alloc] init];
    [self.colorQueue shuffle];

    self.currentPage = [self viewWithText:@"Awaiting beacons.."];
    self.currentPage.backgroundColor = self.colorQueue.nextColor;


    [self.view addSubview:self.currentPage];
}
- (void) setup
{
    self.currentStateLabel = [[UILabel alloc] init];

    [self setupViews];
    [self setupStateMachine];
    [self setupBeaconManager];
    [self setupAudio];

}
#pragma mark - start
- (void) start
{
    if (!self.isAudioReady)
    {
        DLog(@"Audio not ready");
        return;
    }

    if (!self.blueBeacon2.isActive)
    {
        DLog(@"Start beacon is not active");
        return;
    }
    DLog(@"Starting!");
    [self.stateMachine activate];

}
- (void) step
{
    DLog(@"step");
}
#pragma mark - US2BeaconManagerDelegate

-(void)beaconManagerDidUpdate:(US2BeaconManager *)beaconManager
{
    DLog(@"beaconManagerDidUpdate");
    if (!self.stateMachine.isActive)
    {
        [self start];
    }
    else
    {
        [self step];
    }
    // make sure we have beacons around
    // find out position
    // see if state changed
        // trigger event
        // audio update
        // screen update
}
@end
