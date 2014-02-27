//
//  TKStateMachine+US2Extensions.m
//  US2EstimoteDistances
//
//  Created by Alexander Johansson on 26/02/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#import "TKStateMachine+US2Extensions.h"

@implementation TKStateMachine (US2Extensions)

-(TKState*) addStateWithName:(NSString *)name
{
    if (! [name isKindOfClass:[NSString class]]) [NSException raise:NSInvalidArgumentException format:@"Expected a `NSString` object, instead got a `%@` (%@)", [name class], name];

    TKState *state = [TKState stateWithName:name];

    [self addState:state];

    return state;
}
@end
