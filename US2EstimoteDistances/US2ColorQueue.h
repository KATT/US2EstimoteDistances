//
//  US2ColorQueue.h
//  US2EstimoteDistances
//
//  Created by Alexander Johansson on 27/02/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface US2ColorQueue : NSObject

@property (nonatomic, readonly) UIColor *nextColor;

// shuffle the color order
- (void)shuffle;
@end
