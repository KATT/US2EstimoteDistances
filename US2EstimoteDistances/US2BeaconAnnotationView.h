//
//  US2BeaconAnnotationView.h
//  US2EstimoteDistances
//
//  Created by A on 20/02/2014.
//  Copyright (c) 2014 ustwo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "US2BeaconWrapper.h"

@interface US2BeaconAnnotationView : UIView

+(instancetype)beaconAnnotationViewWithBeacon: (US2BeaconWrapper*) beaconWrapper pixelRatio:(CGFloat) pixelsPerMeter;
-(void) updateUI;


@property (nonatomic) CGFloat pixelsPerMeter;
@property (nonatomic, strong) US2BeaconWrapper *beaconWrapper;

@end
