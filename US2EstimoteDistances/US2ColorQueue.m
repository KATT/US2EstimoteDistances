//
//  US2ColorQueue.m
//  US2EstimoteDistances
//
//  Created by Alexander Johansson on 27/02/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#import "US2ColorQueue.h"
#import <UIColor+US2Colors/UIColor+US2Colors.h>

@interface US2ColorQueue()

@property (nonatomic, strong) NSArray *colors;

@property (nonatomic) NSUInteger cursor;
@end

@implementation US2ColorQueue
- (id)init
{
    if (self = [super init])
    {
        [self setup];
    }
    return self;
}
- (void)setup
{
    self.cursor = 0;
    self.colors = @[UIColor.pigletColor, UIColor.passionColor, UIColor.ohRaColor, UIColor.honeyColor, UIColor.jeezzColor, UIColor.potColor, UIColor.mareColor, UIColor.bluColor, UIColor.rainColor];
}

- (UIColor *)nextColor
{
    if (self.cursor >= self.colors.count)
    {
        self.cursor = 0;
    }
    return [self.colors objectAtIndex: self.cursor++];
}

- (void)shuffle
{
    NSMutableArray *shuffledArray = [NSMutableArray arrayWithArray:self.colors];

    NSUInteger count = shuffledArray.count;
    for (uint i = 0; i < count; ++i)
    {
        int nElements = count - i;
        int n = arc4random_uniform(nElements) + i;
        [shuffledArray exchangeObjectAtIndex:i withObjectAtIndex:n];
    }

    self.colors = shuffledArray;
}
@end
