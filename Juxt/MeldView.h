//
//  MeldView.h
//  Juxt
//
//  Created by John Brown on 7/29/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MaskView.h"

@interface MeldView : UIView

@property (nonatomic, strong) UIImage *before;
@property (nonatomic, strong) UIImage *after;
@property (weak, nonatomic) UIImageView *imageViewBefore;
@property (weak, nonatomic) UIImageView *imageViewAfter;
@property (weak, nonatomic) MaskView *masker;

- (void)meld;
- (void)trace;

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer;
- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer;

@end
