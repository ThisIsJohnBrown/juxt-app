//
//  PostTableCell.m
//  Juxt
//
//  Created by John Brown on 8/2/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import "PoseTableCell.h"
#import "MeldView.h"
#import "Pose.h"

@interface PoseTableCell ()

@property (strong, nonatomic) MeldView *meldView;

@end

@implementation PoseTableCell

- (Pose *)pose {
    if (!_pose) _pose = [[Pose alloc] init];
    return _pose;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initUI {
    self.meldView = [[MeldView alloc] initWithPose:self.pose inFrame:CGRectMake(0, 0, 320, 320) withInteractions:NO];
    [self addSubview: self.meldView];
    self.accessoryType = UITableViewCellAccessoryNone;
    
}

- (void)updateUI {
    NSLog(@"updateUI");
}

@end
