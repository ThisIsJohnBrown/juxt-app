//
//  MeldViewController.h
//  Juxt
//
//  Created by John Brown on 7/28/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MaskView.h"

@interface PoseViewController : UIViewController

@property (nonatomic, strong) UIImage *before;
@property (nonatomic, strong) UIImage *after;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewBefore;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewAfter;
@property (weak, nonatomic) IBOutlet MaskView *masker;
@property (weak, nonatomic) IBOutlet UIView *imageContainer;
@property (weak, nonatomic) IBOutlet UISlider *slider;

- (void)meld;

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer;
- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer;

@end
