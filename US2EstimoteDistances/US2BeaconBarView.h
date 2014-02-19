//
//  US2BeaconBarView.h
//  US2EstimoteDistances
//
//  Created by A on 13/02/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "US2BeaconWrapper.h"


@interface US2BeaconBarView : UIView

- (id)initWithFrame:(CGRect)frame beaconWrapper:(US2BeaconWrapper *)beacon;

-(void) updateUIWithMaxDistance: (CGFloat )maxDistance;
@end
