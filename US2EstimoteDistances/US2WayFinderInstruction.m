//
//  US2WayFinderInstruction.m
//  US2EstimoteDistances
//
//  Created by Alexander Johansson on 05/03/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "US2WayFinderInstruction.h"

@interface US2WayFinderInstruction()

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end


@implementation US2WayFinderInstruction


+ (instancetype)instructionWithText: (NSString *)text audioFileName: (NSString *)audioFileName
{
    US2WayFinderInstruction *instance = [[self alloc] init];

    instance.audioFileName = audioFileName;
    instance.text = text;

    return instance;
}

- (void)setAudioFileName:(NSString *)audioFileName
{
    _audioFileName = audioFileName;


	NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", NSBundle.mainBundle.resourcePath, audioFileName]];

	NSError *error;

    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
	self.audioPlayer.numberOfLoops = 0;

    ZAssert(self.audioPlayer, @"Couldn't find audioFileName '%@'", audioFileName);

    [self.audioPlayer prepareToPlay];


}

- (BOOL)isPlaying
{
    return self.audioPlayer.isPlaying;
}

- (BOOL)play
{
    return [self.audioPlayer play];
}
@end
