//
//  MeldViewController.m
//  Juxt
//
//  Created by John Brown on 7/30/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import "MeldViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface MeldViewController ()
@property (nonatomic) CGFloat lastScale;
@property (nonatomic) CGPoint lastPoint;
@property (nonatomic) UIImageView *currentScaling;
@end

@implementation MeldViewController

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
//	// Do any additional setup after loading the view.
//    if (!self.before) {
//        self.before = [UIImage imageNamed:@"hh2.jpg"];
//    }
//    if (!self.after) {
//        self.after = [UIImage imageNamed:@"hh1.jpg"];
//    }
//    
//    NSLog(@"qwer");
}

- (void)viewDidAppear:(BOOL)animated {
    self.imageViewBefore.image = self.pose.before;
    self.imageViewAfter.image = self.pose.after;
    [self.masker setHidden:NO];
    [self meld];
}

- (void)meld {
    if (!self.afterHolderView.layer.mask) {
        self.afterHolderView.layer.mask = self.masker.layer;
    } else {
        self.afterHolderView.layer.mask = nil;
    }
}

- (void)switchImages {
    UIImage *oldBefore = self.imageViewBefore.image;
    UIImage *oldAfter = self.imageViewAfter.image;
    
    self.imageViewBefore.image = oldAfter;
    self.imageViewAfter.image = oldBefore;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pan:(UIPanGestureRecognizer *)recognizer {
    NSLog(@"asdf");
    CGPoint translation = [recognizer translationInView:self.view];
    self.masker.perc = ([recognizer locationInView:recognizer.view].x-[recognizer locationInView:recognizer.view].y)/ recognizer.view.bounds.size.width;
    [self.masker redraw];
    
    
}
- (IBAction)pinch:(UIPinchGestureRecognizer *)recognizer {
    if([recognizer state] == UIGestureRecognizerStateBegan) {
        // Reset the last scale, necessary if there are multiple objects with different scales
        self.lastScale = [recognizer scale];
        CGPoint point = [recognizer locationInView:self.imageViewAfter];
        if (self.masker.perc + .25 > point.x/280) {
            self.currentScaling = self.imageViewBefore;
        } else {
            self.currentScaling = self.imageViewAfter;
        }
    }
    
    if ([recognizer state] == UIGestureRecognizerStateBegan ||
        [recognizer state] == UIGestureRecognizerStateChanged) {
        
        CGFloat currentScale = [[self.currentScaling.layer valueForKeyPath:@"transform.scale"] floatValue];
        
        // Constants to adjust the max/min values of zoom
        const CGFloat kMaxScale = 1.5;
        const CGFloat kMinScale = .5;
        
        CGFloat newScale = 1 -  (self.lastScale - [recognizer scale]);
        newScale = MIN(newScale, kMaxScale / currentScale);
        newScale = MAX(newScale, kMinScale / currentScale);
        CGAffineTransform transform = CGAffineTransformScale([self.currentScaling transform], newScale, newScale);
        self.currentScaling.transform = transform;
        
        self.lastScale = [recognizer scale];  // Store the previous scale factor for the next pinch gesture call
        
        CGPoint point = [recognizer locationInView:self.currentScaling];
        //NSLog(@"%f, %f", point.x, point.y);
//        [self.imageViewAfter.layer setAffineTransform:CGAffineTransformTranslate([self.imageViewAfter.layer affineTransform], point.x - self.lastPoint.x, point.y - self.lastPoint.y)];
//        self.lastPoint = [recognizer locationInView:self.imageViewAfter];
    }
    [self.masker redraw];
}

@end
