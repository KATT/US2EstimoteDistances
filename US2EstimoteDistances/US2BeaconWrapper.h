//
//  US2BeaconWrapper.h
//  US2EstimoteDistances
//
//  Created by A on 13/02/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ESTBeacon;
@interface US2BeaconWrapper : NSObject

- (id) initWithName:(NSString*)name;


@property (nonatomic, strong) ESTBeacon *beacon;
@property (nonatomic, copy) NSString *name;

@end
