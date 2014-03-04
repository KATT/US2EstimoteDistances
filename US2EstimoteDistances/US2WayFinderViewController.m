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


@interface US2WayFinderViewController ()<US2BeaconManagerDelegate>

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

    TKState *awaitingState = [self.stateMachine addStateWithName:kAwaitingState];
    TKState *startingState = [self.stateMachine addStateWithName:kStartingState];
    TKState *walkingTowardsWP2 = [self.stateMachine addStateWithName:kWalkingTowardsWP2];
    TKState *walkingTowardsWP3 = [self.stateMachine addStateWithName:kWalkingTowardsWP3];
    TKState *walkingTowardsGoal = [self.stateMachine addStateWithName:kWalkingTowardsGoal];

    [walkingTowardsWP2 setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
        DLog(@"Previous state: %@", transition.sourceState);
        if (transition.sourceState == state) return;
        DLog(@"instruct");

        [self doInstruction:@"Exit door and head left for 10m." audioFileName:kExitDoorLeftAudio];
    }];
    //
    [walkingTowardsWP3 setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
        DLog(@"Previous state: %@", transition.sourceState);
        if (transition.sourceState == state) return;
        [self doInstruction:@"Turn left and then right in two meters." audioFileName:kTurnLeftAudio];
    }];

    [walkingTowardsGoal setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
        DLog(@"Previous state: %@", transition.sourceState);
        if (transition.sourceState == state) return;
        [self doInstruction:@"Turn right" audioFileName:kTurnRightAudio];
    }];

    TKEvent *firstBeaconClose = [TKEvent eventWithName:kFirstBeaconClosest transitioningFromStates:nil toState:walkingTowardsWP2];
    TKEvent *secondWayPointClose = [TKEvent eventWithName:kSecondBeaconClose transitioningFromStates:@[walkingTowardsWP2] toState:walkingTowardsWP3];
    TKEvent *thirdWayPointClose = [TKEvent eventWithName:kThirdBeaconClose transitioningFromStates:@[walkingTowardsWP3] toState:walkingTowardsGoal];


    [self.stateMachine addEvent:firstBeaconClose];
    [self.stateMachine addEvent:secondWayPointClose];
    [self.stateMachine addEvent:thirdWayPointClose];

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

    self.audioFileNames = @[kExitDoorLeftAudio, kTurnLeftAudio, kTurnRightAudio];
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
    textLabel.textColor = [UIColor whiteColor];
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

    [self.stateMachine activate];
    DLog(@"Starting!");

}
- (void) step
{
    DLog(@"step (%@)", self.stateMachine.currentState.name);

    if (self.beaconManager.closestBeacon == self.blueBeacon2)
    {
        if (self.blueBeacon2.beacon.distance.floatValue < 5)
        {
            [self.stateMachine fireEvent:kFirstBeaconClosest userInfo:nil error:nil];
        }
    }
    if (self.beaconManager.closestBeacon == self.mintBeacon2)
    {
        if (self.mintBeacon2.beacon.distance.floatValue < 2)
        {
            [self.stateMachine fireEvent:kSecondBeaconClose userInfo:nil error:nil];
        }
    }

    if (self.beaconManager.closestBeacon == self.purpleBeacon2)
    {
        DLog(@"third beacon close");
        if (self.purpleBeacon2.beacon.distance.floatValue < 2)
        {
            [self.stateMachine fireEvent:kThirdBeaconClose userInfo:nil error:nil];
        }
    }
}
#pragma mark - handle step changes

-(void) doInstruction: (NSString*) text audioFileName:(NSString*)audioFileName
{
    AVAudioPlayer *audioPlayer = [self.audios objectForKey:audioFileName];
    if (audioFileName) {
        ZAssert(audioPlayer, @"No audoFileName '%@' found", audioFileName);
    }
    [audioPlayer play];

    self.nextPage = [self viewWithText:text];

    [UIView transitionFromView:self.currentPage toView:self.nextPage duration:1.0f options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
        [self.currentPage removeFromSuperview];
        self.currentPage = self.nextPage;
        self.nextPage = nil;
    }];
}
#pragma mark - US2BeaconManagerDelegate

-(void)beaconManagerDidUpdate:(US2BeaconManager *)beaconManager
{
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
