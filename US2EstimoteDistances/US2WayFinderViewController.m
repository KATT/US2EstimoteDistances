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

NSString *const kStartingState = @"kStartingState";
NSString *const kWalkingLeft = @"kWalkingLeft";

NSString *const kStartingEvent = @"kWalkLeft";


@interface US2WayFinderViewController ()<US2BeaconManagerDelegate>

// ui
@property (nonatomic, strong) UILabel *currentStateLabel;

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

- (void) setup
{
    self.currentStateLabel = [[UILabel alloc] init];

    [self setupStateMachine];
    [self setupBeaconManager];
    [self setupAudio];

}
#pragma mark - start
- (void) start
{
    [self.stateMachine activate];
}
#pragma mark - US2BeaconManagerDelegate

-(void)beaconManagerDidUpdate:(US2BeaconManager *)beaconManager
{
    // make sure we have beacons around
    // find out position
    // see if state changed
        // trigger event
        // audio update
        // screen update

}
@end
