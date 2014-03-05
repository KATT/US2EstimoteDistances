//
//  US2WayFinderViewController.m
//  US2EstimoteDistances
//
//  Created by Alexander Johansson on 26/02/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#import <TransitionKit/TransitionKit.h>
#import "TKStateMachine+US2Extensions.h"

#import "US2WayFinderViewController.h"
#import "US2BeaconManager.h"

#import "US2ColorQueue.h"

#import "US2WayFinderInstruction.h"

// audios
NSString *const kExitDoorLeftAudio = @"exit-door-left.m4a";
NSString *const kTurnLeftAudio = @"turn-left.m4a";
NSString *const kTurnRightAudio = @"turn-right.m4a";
NSString *const kAlmostThereAudio = @"almost-there.m4a";


@interface US2WayFinderViewController ()<US2BeaconManagerDelegate>

@property (nonatomic) BOOL isStarted;

@property (nonatomic, weak) US2WayFinderInstruction *lastInstruction;

// instructions

@property (nonatomic, strong) US2WayFinderInstruction *firstInstruction;
@property (nonatomic, strong) US2WayFinderInstruction *secondInstruction;
@property (nonatomic, strong) US2WayFinderInstruction *thirdInstruction; // almost there
@property (nonatomic, strong) US2WayFinderInstruction *forthInstruction;

// ui
@property (nonatomic, strong) UILabel *currentStateLabel;
@property (nonatomic, strong) US2ColorQueue *colorQueue;

// beacon manager
@property (nonatomic, strong) US2BeaconManager *beaconManager;

// beacons
@property (nonatomic, strong) US2BeaconWrapper *blueBeacon2;
@property (nonatomic, strong) US2BeaconWrapper *mintBeacon2;
@property (nonatomic, strong) US2BeaconWrapper *purpleBeacon2;


@property (nonatomic, weak) US2BeaconWrapper *previouslyClosestBeacon;
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

- (void) setupInstructions
{
    self.firstInstruction = [US2WayFinderInstruction instructionWithText:@"Turn left & walk straight for ~10 meters" audioFileName:kTurnLeftAudio];
    self.secondInstruction = [US2WayFinderInstruction instructionWithText:@"Almost there!" audioFileName:kAlmostThereAudio];
    self.thirdInstruction = [US2WayFinderInstruction instructionWithText:@"Turn left" audioFileName:kTurnLeftAudio];
    self.forthInstruction = [US2WayFinderInstruction instructionWithText:@"Turn right" audioFileName:kTurnRightAudio];
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

    [self setupInstructions];
    [self setupViews];
    [self setupBeaconManager];
}
#pragma mark - start
- (void) start
{
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
    DLog(@"Step. Closest beacon: %@, previously: %@", self.beaconManager.closestBeacon.name, self.previouslyClosestBeacon.name);

    if (self.beaconManager.closestBeacon == self.blueBeacon2)
    {
        if (self.blueBeacon2.beacon.distance.floatValue < 5)
        {
            [self doInstructionOnce:self.firstInstruction];
        }
    }
    if (self.beaconManager.closestBeacon == self.mintBeacon2)
    {
        if (self.mintBeacon2.beacon.distance.floatValue > 2)
        {
            // Approaching
            [self doInstructionOnce:self.secondInstruction];
        }
        else
        {
            [self doInstructionOnce:self.thirdInstruction];
        }
    }

    if (self.beaconManager.closestBeacon == self.purpleBeacon2)
    {
        if (self.purpleBeacon2.beacon.distance.floatValue < 2)
        {
            [self doInstructionOnce:self.forthInstruction];
        }
    }
}
#pragma mark - handle step changes

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

-(void) doInstruction: (US2WayFinderInstruction *) instruction
{
    DLog(@"doInstruction %@", instruction.text);
    [instruction play];
    self.lastInstruction = instruction;

    UIView *fromView = self.currentPage;
    UIView *toView = [self viewWithText:instruction.text];

    self.currentPage = toView;

    [UIView transitionFromView:fromView toView:toView duration:1.0f options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {

        [fromView removeFromSuperview];
    }];
}

-(void) doInstructionOnce: (US2WayFinderInstruction *) instruction
{
    if (self.lastInstruction != instruction)
    {
        [self doInstruction:instruction];
    }
}
#pragma mark - US2BeaconManagerDelegate

-(void)beaconManagerDidUpdate:(US2BeaconManager *)beaconManager
{
    if (self.lastStepClosestBeacon != self.beaconManager.closestBeacon)
    {
        self.previouslyClosestBeacon = self.lastStepClosestBeacon;
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
        if (!self.lastInstruction.isPlaying)
        {
            DLog(@"play sound!");
            [self.lastInstruction play];
        }
    }
}
@end
