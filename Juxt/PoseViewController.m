//
//  MeldViewController.m
//  Juxt
//
//  Created by John Brown on 7/28/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import "PoseViewController.h"
#import "MeldViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface PoseViewController ()
@property (nonatomic) CGPoint slideStart;
@end

@implementation PoseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    //[self.masker setHidden:NO];
    //[self meld];
}

- (IBAction)meldAction:(id)sender {
    UIImage *oldBefore = self.imageViewBefore.image;
    UIImage *oldAfter = self.imageViewAfter.image;
    
    self.imageViewBefore.image = oldAfter;
    self.imageViewAfter.image = oldBefore;
}

- (void)meld {
    if (!self.imageViewAfter.layer.mask) {
        self.imageViewAfter.layer.mask = self.masker.layer;
    } else {
        self.imageViewAfter.layer.mask = nil;
    }
}

- (IBAction)switchImages:(id)sender {
    for (int i= 0; i < self.childViewControllers.count; i++) {
        if ([(UIViewController *)self.childViewControllers[i] isKindOfClass:[MeldViewController class]]) {
            [(MeldViewController *)self.childViewControllers[i] switchImages];
        }
    }
}

- (IBAction)slide:(id)sender {
    for (int i= 0; i < self.childViewControllers.count; i++) {
        if ([(UIViewController *)self.childViewControllers[i] isKindOfClass:[MeldViewController class]]) {
            ((MeldViewController *)self.childViewControllers[i]).masker.alpha = [(UISlider *)sender value];
        }
    }
}


- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer {
    self.imageViewAfter.transform = CGAffineTransformScale(self.imageViewAfter.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
}

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {

    CGPoint translation = [recognizer translationInView:self.view];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.slideStart = CGPointMake(translation.x, translation.y);
    }
    self.masker.perc = ([recognizer locationInView:recognizer.view].x-[recognizer locationInView:recognizer.view].y)/ recognizer.view.bounds.size.width;
    [self.masker redraw];
    
    
}




@end
