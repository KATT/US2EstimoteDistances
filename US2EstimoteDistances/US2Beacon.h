//
//  US2Beacon.h
//  US2EstimoteDistances
//
//  Created by A on 13/02/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ESTBeacon;
@interface US2Beacon : NSObject

- (id) initWithColor: (UIColor *) color;


@property (nonatomic, strong) ESTBeacon *beacon;
@property (nonatomic, strong) UIColor *color;

@end
