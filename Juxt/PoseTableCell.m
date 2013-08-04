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

- (void)initUI:(BOOL)inTable {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    if (!self.pose.createdDate && inTable) {
        CGRect frame = self.frame;
        frame.size.height = 104;
        self.frame = frame;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 120, 40)];
        label.text = @"Add new pose";
        [label setCenter:self.center];
        [self addSubview:label];
    } else {
        self.meldView = [[MeldView alloc] initWithPose:self.pose inFrame:CGRectMake(40, 40, 240, 240) withInteractions:NO];
        [self addSubview: self.meldView];
    }
    self.accessoryType = UITableViewCellAccessoryNone;
    
}

- (void)updateUI {
    NSLog(@"updateUI");
}

@end
