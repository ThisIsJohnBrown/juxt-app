//
//  PostTableCell.h
//  Juxt
//
//  Created by John Brown on 8/2/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pose.h"
#import "MaskView.h"

@interface PoseTableCell : UITableViewCell

@property (nonatomic, strong) Pose *pose;

- (void)updateUI;
- (void)initUI:(BOOL)inTable;
@end
