//
//  US2WayFinderInstruction.h
//  US2EstimoteDistances
//
//  Created by Alexander Johansson on 05/03/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface US2WayFinderInstruction : NSObject

+ (instancetype)instructionWithText: (NSString *)text audioFileName: (NSString *)audioFileName;


@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) NSString *audioFileName;


@property (nonatomic, readonly) BOOL isPlaying;

- (BOOL) play;

@end
