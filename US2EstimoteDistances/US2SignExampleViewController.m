//
//  US2SignExampleViewController.m
//  US2EstimoteDistances
//
//  Created by Alexander Johansson on 16/04/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#import "US2SignExampleViewController.h"

#import <AudioToolbox/AudioServices.h>
#import <HexColors/HexColor.h>

#import <TransitionKit/TransitionKit.h>
#import "US2BeaconManager.h"


#import "US2ColorQueue.h"
#import "US2WayFinderInstruction.h"

// audios
NSString *const kSignAudio = @"sign.m4a";


@interface US2SignExampleViewController ()<US2BeaconManagerDelegate>


@property (nonatomic, weak) UIView *currentView;

@property (nonatomic, strong) US2WayFinderInstruction *signInstruction;
@property (nonatomic, strong) US2WayFinderInstruction *signInstruction2;

@property (nonatomic, strong) US2ColorQueue *colorQueue;

@property (nonatomic, strong) US2BeaconManager *beaconManager;


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
- (BOOL) isActive {
    return (self.tabBarController.selectedViewController == self);
}
- (void)viewDidLoad
{
	// Do any additional setup after loading the view.
    [self setup];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

#if TARGET_IPHONE_SIMULATOR
    [self performSelector:@selector(playInstruction1) withObject:nil afterDelay:1.0f];
    [self performSelector:@selector(playInstruction2) withObject:nil afterDelay:2.0f];
#endif

}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self restart];
}

- (void) setupBeaconManager
{
    self.beaconManager = [[US2BeaconManager alloc] init];
    self.beaconManager.delegate = self;

    // FIXME clean this up
    [self.beaconManager registerBeaconWrapper: [[US2BeaconWrapper alloc] initWithMajor:@35729 name:@"Mint" lightColor:[UIColor colorWithHexString:@"98c5a6"] darkColor:[UIColor colorWithHexString:@"5c7865"]]];
    [self.beaconManager registerBeaconWrapper: [[US2BeaconWrapper alloc] initWithMajor:@50667 name:@"Purple" lightColor:[UIColor colorWithHexString:@"5c59a7"] darkColor:[UIColor colorWithHexString:@"3f3d73"]]];
    [self.beaconManager registerBeaconWrapper: [[US2BeaconWrapper alloc] initWithMajor: @4092 name:@"Blue" lightColor:[UIColor colorWithHexString:@"9fddf9"] darkColor:[UIColor colorWithHexString:@"6f9aad"]]];

    [self.beaconManager registerBeaconWrapper: [[US2BeaconWrapper alloc] initWithMajor:@43211 name:@"Mint #2" lightColor:[UIColor colorWithHexString:@"98c5a6"] darkColor:[UIColor colorWithHexString:@"5c7865"]]];
    [self.beaconManager registerBeaconWrapper: [[US2BeaconWrapper alloc] initWithMajor:@41032 name:@"Purple #2" lightColor:[UIColor colorWithHexString:@"5c59a7"] darkColor:[UIColor colorWithHexString:@"3f3d73"]]];
    [self.beaconManager registerBeaconWrapper: [[US2BeaconWrapper alloc] initWithMajor: @57830 name:@"Blue #2" lightColor:[UIColor colorWithHexString:@"9fddf9"] darkColor:[UIColor colorWithHexString:@"6f9aad"]]];
}
- (void) setupInstructions
{
    self.signInstruction = [US2WayFinderInstruction instructionWithText:@"Welcome to Kings Cross Station.\n\nThe Gates are straight ahead, please mind the step." audioFileName:@"b1.m4a"];
    self.signInstruction2 = [US2WayFinderInstruction instructionWithText:@"Turn left for the Northern Line,\nor Turn right for the Victoria Line\n\nTap your screen twice if you need any assistance." audioFileName:@"b2.m4a"];
}

- (void) setupViews
{
    self.colorQueue = [[US2ColorQueue alloc] init];
    [self.colorQueue shuffle];

    [self.signView removeFromSuperview];

    self.awaitingView = [self viewWithText:@"Looking for signs.."small:NO];
    [self.view addSubview:self.awaitingView];

    self.signView = [self viewWithText:self.signInstruction.text small:YES];
    self.signView2 = [self viewWithText:self.signInstruction2.text small:YES];


    self.currentView = self.awaitingView;

}
- (void) setup
{
    self.isStarted = NO;

    [self setupInstructions];
    [self setupViews];
    [self setupBeaconManager];

}

- (void) transitionToView: (UIView *) view andInstruction: (US2WayFinderInstruction *) instruction {
    if (self.currentView == view) return;
    [UIView transitionFromView:self.currentView toView:view duration:0.6f options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
        DLog(@"Meow!");
    }];

    [self vibrate];
    self.currentView = view;

    [instruction play];
}

- (void) playInstruction1 {
    [self transitionToView:self.signView andInstruction:self.signInstruction];
    
}
- (void) playInstruction2 {
    [self transitionToView:self.signView2 andInstruction:self.signInstruction2];
    
}

- (void) restart {
    [self transitionToView:self.awaitingView andInstruction:nil];
}

#pragma mark - US2BeaconManagerDelegate

-(void)beaconManagerDidUpdate:(US2BeaconManager *)beaconManager
{

    DLog(@"Closest beacon: %@, distance: %.2f", self.beaconManager.closestBeacon.name, self.beaconManager.closestBeacon.distance.floatValue);

    if (self.beaconManager.closestBeacon.isActive && self.beaconManager.closestBeacon.distance.floatValue < 1.0) {
        if (self.currentView == self.awaitingView) {
            [self playInstruction1];
        }
        if (self.currentView == self.signView) {
            [self playInstruction2];
        }
    }

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
    textLabel.textColor = [UIColor blackColor];
    textLabel.textAlignment = NSTextAlignmentCenter;


    if (isSmall) {
        textLabel.font =  [UIFont fontWithName:@"FuturaLTPro-XBold" size:30.0f ];
        textLabel.textAlignment = NSTextAlignmentLeft;
    }

    [view addSubview:textLabel];

    textLabel.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2);

    view.backgroundColor = [UIColor nonWhiteColor];
    
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
        if (!self.signInstruction.isPlaying && self.isStarted)
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
