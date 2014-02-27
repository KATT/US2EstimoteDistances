//
//  UIColor+US2Colors.m
//  US2EstimoteDistances
//
//  Created by Alexander Johansson on 27/02/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#import "UIColor+US2Colors.h"

@implementation UIColor (US2Colors)

+ (UIColor *)pigletColor
{
    static UIColor *pigletColor = nil;
    if (!pigletColor) {
        pigletColor = [UIColor colorWithRed: 237.0/255.0
                                     green: 0.0/255.0
                                      blue: 130.0/255.0
                                     alpha: 1.0];
    }
    return pigletColor;
}
+ (UIColor *)passionColor
{
    static UIColor *passionColor = nil;
    if (!passionColor) {
        passionColor = [UIColor colorWithRed: 230.0/255.0
                                     green: 12.0/255.0
                                      blue: 41.0/255.0
                                     alpha: 1.0];
    }
    return passionColor;
}
+ (UIColor *)ohRaColor
{
    static UIColor *ohRaColor = nil;
    if (!ohRaColor) {
        ohRaColor = [UIColor colorWithRed: 255.0/255.0
                                     green: 85.0/255.0
                                      blue: 25.0/255.0
                                     alpha: 1.0];
    }
    return ohRaColor;
}
+ (UIColor *)honeyColor
{
    static UIColor *honeyColor = nil;
    if (!honeyColor) {
        honeyColor = [UIColor colorWithRed: 255.0/255.0
                                     green: 191.0/255.0
                                      blue: 0.0/255.0
                                     alpha: 1.0];
    }
    return honeyColor;
}
+ (UIColor *)jeezzColor
{
    static UIColor *jeezzColor = nil;
    if (!jeezzColor) {
        jeezzColor = [UIColor colorWithRed: 150.0/255.0
                                     green: 204.0/255.0
                                      blue: 41.0/255.0
                                     alpha: 1.0];
    }
    return jeezzColor;
}
@end
