//
//  MeldViewController.h
//  Juxt
//
//  Created by John Brown on 7/30/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MaskView.h"

@interface MeldViewController : UIViewController

@property (nonatomic, strong) UIImage *before;
@property (nonatomic, strong) UIImage *after;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewBefore;
@property (weak, nonatomic) IBOutlet UIView *afterHolderView;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewAfter;
@property (weak, nonatomic) IBOutlet MaskView *masker;

@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *pan;
@property (strong, nonatomic) IBOutlet UIPinchGestureRecognizer *pinch;

- (void)meld;
- (void)switchImages;

@end
