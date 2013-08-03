//
//  MeldView.h
//  Juxt
//
//  Created by John Brown on 8/2/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pose.h"

@interface MeldView : UIView

@property (strong, nonatomic) Pose *pose;

-(id)initWithPose:(Pose *)pose inFrame:(CGRect)frame withInteractions:(BOOL)interactions;

- (void)afterOpacity:(float)opacity;
- (void)nextDirection;
- (void)switchImages;

- (void)savePose;
@end
