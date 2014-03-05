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

NSString *const kAwaitingState = @"kAwaitingState";
NSString *const kStartingState = @"kStartingState";
NSString *const kWalkingTowardsWP2 = @"kWalkingTowardsWP2";
NSString *const kWalkingTowardsWP3 = @"kWalkingTowardsWP3";
NSString *const kWalkingTowardsGoal = @"kWalkingTowardsGoal";

// walking events
NSString *const kFirstBeaconClosest = @"kFirstBeaconClosest";
NSString *const kSecondBeaconClose = @"kSecondBeaconClose";
NSString *const kThirdBeaconClose = @"kThirdBeaconClose";
NSString *const kGoal = @"kGoal";


// audios
NSString *const kExitDoorLeftAudio = @"exit-door-left.m4a";
NSString *const kTurnLeftAudio = @"turn-left.m4a";
NSString *const kTurnRightAudio = @"turn-right.m4a";
NSString *const kAlmostThereAudio = @"almost-there.m4a";


@interface US2WayFinderViewController ()<US2BeaconManagerDelegate>

@property (nonatomic) BOOL isStarted;

@property (nonatomic, weak) NSString *lastInstruction;

// ui
@property (nonatomic, strong) UILabel *currentStateLabel;
@property (nonatomic, strong) US2ColorQueue *colorQueue;

// audio related
@property (nonatomic) BOOL isAudioReady;

@property (nonatomic, strong) NSArray *audioFileNames;
@property (nonatomic, strong) NSMutableDictionary *audios;

// beacon manager
@property (nonatomic, strong) US2BeaconManager *beaconManager;

// beacons
@property (nonatomic, strong) US2BeaconWrapper *blueBeacon2;
@property (nonatomic, strong) US2BeaconWrapper *mintBeacon2;
@property (nonatomic, strong) US2BeaconWrapper *purpleBeacon2;


@property (nonatomic, weak) US2BeaconWrapper *previousWaypointBeacon;
@property (nonatomic, weak) US2BeaconWrapper *lastStepClosestBeacon;

// state
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

    self.audioFileNames = @[kExitDoorLeftAudio, kTurnLeftAudio, kTurnRightAudio, kAlmostThereAudio];
    self.audios = [NSMutableDictionary dictionaryWithCapacity:self.audioFileNames.count];

    dispatch_async(backgroundQueue, ^{
        for (NSString *audioFileName in self.audioFileNames) {
            AVAudioPlayer *audioPlayer = [self audioPlayerWithFileName:audioFileName];
            [self.audios setObject:audioPlayer
                            forKey:audioFileName];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isAudioReady = YES;
            DLog(@"Audio ready");
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
    textLabel.textColor = [UIColor nonWhiteColor];
    textLabel.textAlignment = NSTextAlignmentCenter;

    [view addSubview:textLabel];

    textLabel.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2);

    view.backgroundColor = self.colorQueue.nextColor;

    return view;
}

- (void) setupViews
{
    self.colorQueue = [[US2ColorQueue alloc] init];
    [self.colorQueue shuffle];

    self.currentPage = [self viewWithText:@"Awaiting beacons.."];


    [self.view addSubview:self.currentPage];
}
- (void) setup
{
    self.currentStateLabel = [[UILabel alloc] init];

    [self setupViews];
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

    self.isStarted = YES;

}

- (void) step
{
    DLog(@"Step. Closest beacon: %@, previously: %@", self.beaconManager.closestBeacon.name, self.previousWaypointBeacon.name);

    if (self.beaconManager.closestBeacon == self.blueBeacon2)
    {
        if (self.blueBeacon2.beacon.distance.floatValue < 5)
        {
            [self doInstructionOnce:@"Turn left & walk straight for ~10 meters." audioFileName:kTurnLeftAudio];
        }
    }
    if (self.beaconManager.closestBeacon == self.mintBeacon2)
    {
        if (self.mintBeacon2.beacon.distance.floatValue < 2)
        {
            [self doInstructionOnce:@"Turn left & walk straight for ~3 meters." audioFileName:kTurnLeftAudio];
        }
        else
        {
            [self doInstructionOnce:@"Almost there!" audioFileName:kAlmostThereAudio];
        }
    }

    if (self.beaconManager.closestBeacon == self.purpleBeacon2)
    {
        DLog(@"third beacon close");
        if (self.purpleBeacon2.beacon.distance.floatValue < 2)
        {
            [self doInstructionOnce:@"Turn right" audioFileName:kTurnRightAudio];
        }
    }
}
#pragma mark - handle step changes

-(void) doInstruction: (NSString*) text audioFileName:(NSString*)audioFileName
{
    DLog(@"doInstruction %@", text);
    AVAudioPlayer *audioPlayer = [self.audios objectForKey:audioFileName];
    if (audioFileName) {
        ZAssert(audioPlayer, @"No audoFileName '%@' found", audioFileName);
    }
    [audioPlayer play];
    self.lastInstruction = text;

    UIView *fromView = self.currentPage;
    UIView *toView = [self viewWithText:text];

    self.currentPage = toView;

    [UIView transitionFromView:fromView toView:toView duration:1.0f options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {

        [fromView removeFromSuperview];
    }];
}

-(void) doInstructionOnce: (NSString*) text audioFileName:(NSString*)audioFileName
{
    if (![self.lastInstruction isEqualToString:text])
    {
        [self doInstruction:text audioFileName:audioFileName];
    }
}
#pragma mark - US2BeaconManagerDelegate

-(void)beaconManagerDidUpdate:(US2BeaconManager *)beaconManager
{
    if (self.lastStepClosestBeacon != self.beaconManager.closestBeacon)
    {
        self.previousWaypointBeacon = self.lastStepClosestBeacon;
    }
    self.lastStepClosestBeacon = self.beaconManager.closestBeacon;

    if (!self.isStarted)
    {
        [self start];
    }
    else
    {
        [self step];
    }
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
//        if (!self.lastSound.isPlaying)
//        {
//            DLog(@"play sound!");
//            [self.lastSound play];
//        }
    }
}
@end
