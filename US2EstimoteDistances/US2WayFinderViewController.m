//
//  US2WayFinderViewController.m
//  US2EstimoteDistances
//
//  Created by Alexander Johansson on 26/02/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#import <TransitionKit/TransitionKit.h>
#import <AudioToolbox/AudioServices.h>

#import "TKStateMachine+US2Extensions.h"

#import "US2WayFinderViewController.h"
#import "US2BeaconManager.h"

#import "US2ColorQueue.h"

#import "US2WayFinderInstruction.h"

// audios
NSString *const kWalkStraightAudio = @"walk-straight.m4a";
NSString *const kExitDoorLeftAudio = @"exit-door-left.m4a";
NSString *const kTurnLeftAudio = @"turn-left.m4a";
NSString *const kTurnRightAudio = @"turn-right.m4a";
NSString *const kAlmostThereAudio = @"almost-there.m4a";
NSString *const kGoalAudio = @"goal.m4a";


@interface US2WayFinderViewController ()<US2BeaconManagerDelegate>

@property (nonatomic, strong) NSTimer *checkNextFireTimer;
@property (nonatomic) BOOL isStarted;

@property (nonatomic, weak) US2WayFinderInstruction *lastInstruction;

// instructions

@property (nonatomic, strong) US2WayFinderInstruction *walkStraightInstruction;
@property (nonatomic, strong) US2WayFinderInstruction *turnLeftInstruction;
@property (nonatomic, strong) US2WayFinderInstruction *turnRightInstruction; // almost there

@property (nonatomic, strong) US2WayFinderInstruction *almostThereInstruction;

@property (nonatomic, strong) US2WayFinderInstruction *startingWaypointInstruction;

@property (nonatomic, strong) US2WayFinderInstruction *firstWaypointInstruction; // almost there
@property (nonatomic, strong) US2WayFinderInstruction *secondWaypointInstruction;
@property (nonatomic, strong) US2WayFinderInstruction *thirdWaypointInstruction;
@property (nonatomic, strong) US2WayFinderInstruction *forthWaypointInstruction;


@property (nonatomic, strong) US2WayFinderInstruction *goalWaypointInstruction;


// ui
@property (nonatomic, strong) UILabel *currentStateLabel;
@property (nonatomic, strong) US2ColorQueue *colorQueue;

// beacon manager
@property (nonatomic, strong) US2BeaconManager *beaconManager;

// beacons
@property (nonatomic, strong) US2BeaconWrapper *startingWaypoint;

@property (nonatomic, strong) US2BeaconWrapper *firstWaypoint;
@property (nonatomic, strong) US2BeaconWrapper *secondWaypoint;
@property (nonatomic, strong) US2BeaconWrapper *thirdWaypoint;
@property (nonatomic, strong) US2BeaconWrapper *forthWaypoint;
//@property (nonatomic, strong) US2BeaconWrapper *fifthWaypoint;

@property (nonatomic, strong) US2BeaconWrapper *nextWaypoint;


@property (nonatomic, strong) US2BeaconWrapper *blueBeacon;
@property (nonatomic, strong) US2BeaconWrapper *mintBeacon;
@property (nonatomic, strong) US2BeaconWrapper *purpleBeacon;

@property (nonatomic, strong) US2BeaconWrapper *blueBeacon2;
@property (nonatomic, strong) US2BeaconWrapper *mintBeacon2;
@property (nonatomic, strong) US2BeaconWrapper *purpleBeacon2;


@property (nonatomic, weak) US2BeaconWrapper *previouslyClosestBeacon;
@property (nonatomic, weak) US2BeaconWrapper *lastStepClosestBeacon;

// state
@property (nonatomic, strong) UIView *currentPage;
@property (nonatomic, strong) UIView *nextPage;

// vibrate feedback
@property (nonatomic) CGFloat vibrateIntensity;
@property (nonatomic) NSTimeInterval lastFire;

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


    self.mintBeacon = [US2BeaconWrapper beaconWrapperWithMajor:@35729 name:@"Mint"];
//    self.purpleBeacon = [US2BeaconWrapper beaconWrapperWithMajor:@50667 name:@"Purple"];
    self.blueBeacon = [US2BeaconWrapper beaconWrapperWithMajor:@4092 name:@"Blue"];

    self.blueBeacon2 = [US2BeaconWrapper beaconWrapperWithMajor:@57830 name:@"Blue #2"];
    self.mintBeacon2 = [US2BeaconWrapper beaconWrapperWithMajor:@43211 name:@"Mint #2"];
    self.purpleBeacon2 = [US2BeaconWrapper beaconWrapperWithMajor:@41032 name:@"Purple #2"];

    [self.beaconManager registerBeaconWrapper:self.mintBeacon];
    [self.beaconManager registerBeaconWrapper:self.blueBeacon];
    [self.beaconManager registerBeaconWrapper:self.purpleBeacon];
    [self.beaconManager registerBeaconWrapper:self.blueBeacon2];
    [self.beaconManager registerBeaconWrapper:self.mintBeacon2];
    [self.beaconManager registerBeaconWrapper:self.purpleBeacon2];

    [self setupWaypoints];
}

-(void) setupWaypoints
{
    self.startingWaypoint = self.mintBeacon;

    self.firstWaypoint = self.purpleBeacon2; // 6
    self.secondWaypoint = self.blueBeacon; // 6
    self.thirdWaypoint = self.mintBeacon2; // 6
    self.forthWaypoint = self.blueBeacon2; // 6
}

- (void) setupInstructions
{
    self.startingWaypointInstruction = [US2WayFinderInstruction instructionWithText:@"Walk straight" audioFileName:kWalkStraightAudio];

    self.firstWaypointInstruction = [US2WayFinderInstruction instructionWithText:@"Turn right" audioFileName:kTurnRightAudio];
    self.secondWaypointInstruction = [US2WayFinderInstruction instructionWithText:@"Turn left" audioFileName:kTurnLeftAudio];
    self.thirdWaypointInstruction = [US2WayFinderInstruction instructionWithText:@"Turn left" audioFileName:kTurnLeftAudio];
    self.forthWaypointInstruction = [US2WayFinderInstruction instructionWithText:@"Turn left" audioFileName:kTurnLeftAudio];

    self.goalWaypointInstruction = [US2WayFinderInstruction instructionWithText:@"Goal!!" audioFileName:kGoalAudio];

    self.almostThereInstruction = [US2WayFinderInstruction instructionWithText:@"Almost there!" audioFileName:kAlmostThereAudio];
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
    if (self.beaconManager.closestBeacon == self.forthWaypoint)
    {
        DLog(@"We're at the goal already");
        return;
    }

    if (self.beaconManager.closestBeacon != self.startingWaypoint)
    {
        DLog(@"Start beacon is not closest");
    }


    DLog(@"Starting!");

    [self doInstructionOnce:self.startingWaypointInstruction];
    self.nextWaypoint = self.firstWaypoint;

    self.isStarted = YES;
    self.checkNextFireTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(checkNextFireVibration
                                                                                ) userInfo:nil repeats:YES];
}

- (void) setVibrateIntensityFromBeacon: (US2BeaconWrapper*)beaconWrapper andBaseDistance:(CGFloat)baseDistance
{
    if (!beaconWrapper.isActive) {
        self.vibrateIntensity = 0;
        return;
    }
    self.vibrateIntensity = (baseDistance - beaconWrapper.beacon.distance.floatValue + 1.0)/baseDistance;
    DLog(@"vibrate intensity: %.2f. Distance: %.2f", self.vibrateIntensity, beaconWrapper.beacon.distance.floatValue);
    if (self.vibrateIntensity < 0.0) {
        self.vibrateIntensity = 0;
    }
}


- (void) step
{
    DLog(@"Step. Closest beacon: %@, previously: %@, distance: %.2f", self.beaconManager.closestBeacon.name, self.previouslyClosestBeacon.name, self.beaconManager.closestBeacon.beacon.distance.floatValue);

    US2BeaconWrapper *closestBeacon = self.beaconManager.closestBeacon;

    if (closestBeacon == self.firstWaypoint)
    {
        if (self.firstWaypoint.beacon.distance.floatValue > 2)
        {
            if (self.lastInstruction == self.startingWaypointInstruction) {
                // Approaching
                [self doInstructionOnce:self.almostThereInstruction];
            }
        }
        else
        {
            [self doInstructionOnce:self.firstWaypointInstruction];
            self.nextWaypoint = self.secondWaypoint;
        }
    }


    if (closestBeacon == self.secondWaypoint)
    {

        if (self.secondWaypoint.beacon.distance.floatValue > 2)
        {
            if (self.lastInstruction == self.firstWaypointInstruction) {
                // Approaching
                [self doInstructionOnce:self.almostThereInstruction];
            }
        }
        else
        {
            [self doInstructionOnce:self.secondWaypointInstruction];
            self.nextWaypoint = self.thirdWaypoint;
        }
    }

    if (closestBeacon == self.thirdWaypoint)
    {

        if (self.thirdWaypoint.beacon.distance.floatValue > 2)
        {
            if (self.lastInstruction == self.secondWaypointInstruction) {
                // Approaching
                [self doInstructionOnce:self.almostThereInstruction];
            }
        }
        else
        {
            [self doInstructionOnce:self.thirdWaypointInstruction];
            self.nextWaypoint = self.forthWaypoint;
        }
    }

    if (closestBeacon == self.forthWaypoint)
    {

        if (self.forthWaypoint.beacon.distance.floatValue > 2)
        {
            if (self.lastInstruction == self.secondWaypointInstruction) {
                // Approaching
                [self doInstructionOnce:self.almostThereInstruction];
            }
        }
        else
        {
            [self doInstructionOnce:self.goalWaypointInstruction];
            self.nextWaypoint = nil;
            self.isStarted = NO;
            [self.checkNextFireTimer invalidate];
        }
    }

    self.vibrateIntensity = 0;

    // vibrate intensity
    if (self.nextWaypoint)
    {
        // 1.0 = 0 meters distance
        // base value = 8
        [self setVibrateIntensityFromBeacon:self.nextWaypoint andBaseDistance:6.0];
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
    textLabel.text = text.uppercaseString;
    textLabel.numberOfLines = 0;
    textLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    textLabel.font = [UIFont fontWithName:@"FuturaLTPro-XBold" size:42.0f ];
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
#pragma mark - vibrate shizzle

- (void) vibrate
{
    AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    self.lastFire =  NSDate.date.timeIntervalSince1970;
}

- (void) checkNextFireVibration
{
    CGFloat heartbeat = 3;
    CGFloat maxIntensity = 0.2;

    CGFloat intensityInSeconds = heartbeat;

    if (self.vibrateIntensity > 0) {
        self.vibrateIntensity = MIN(1.0, self.vibrateIntensity);
        intensityInSeconds = (1.0-self.vibrateIntensity)*(heartbeat-maxIntensity) + maxIntensity;
    }
//    DLog(@"vibrate every %.2f seconds", intensityInSeconds);
    CGFloat timeDiff = (CGFloat)(NSDate.date.timeIntervalSince1970 - self.lastFire);
    if (timeDiff > intensityInSeconds)
    {
        [self vibrate];
    }

}
@end
