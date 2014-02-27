//
//  TKStateMachine+US2Extensions.h
//  US2EstimoteDistances
//
//  Created by Alexander Johansson on 26/02/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#import <TransitionKit/TransitionKit.h>

@interface TKStateMachine (US2Extensions)


/**
 Creates a state and adds it to the receiver.

 @param state The name of the state to be added.
 @see addState:
 */
- (TKState *)addStateWithName:(NSString *)name;


@end
