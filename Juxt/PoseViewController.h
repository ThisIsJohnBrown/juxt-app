//
//  MeldViewController.h
//  Juxt
//
//  Created by John Brown on 7/28/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pose.h"
#import "MeldView.h"

@interface PoseViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) UIImage *before;
@property (nonatomic, strong) UIImage *after;

@property (nonatomic, strong) Pose *pose;
- (IBAction)sliderMoved:(UISlider *)sender;
- (IBAction)switchImages:(UIButton *)sender;
- (IBAction)changeDirection:(UIButton *)sender;
- (IBAction)save:(UIButton *)sender;

@property (strong, nonatomic) MeldView *meldView;

@end
