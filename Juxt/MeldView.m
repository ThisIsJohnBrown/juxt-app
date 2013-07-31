//
//  MeldView.m
//  Juxt
//
//  Created by John Brown on 7/29/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import "MeldView.h"
#import <QuartzCore/QuartzCore.h>

@interface MeldView ()

@end

@implementation MeldView

#pragma mark - Initialization

- (void)setup {
    
}

- (void)awakeFromNib {
    [self setup];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setup];
    return self;
}

- (void)trace {
    NSLog(@"sdf");
    if (!self.before) {
        self.before = [UIImage imageNamed:@"hh2.jpg"];
    }
    if (!self.after) {
        self.after = [UIImage imageNamed:@"hh1.jpg"];
    }
    self.imageViewBefore.image = self.before;
    self.imageViewAfter.image = self.after;
    //[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    NSLog(@"draw");
//    if (!self.before) {
//        self.before = [UIImage imageNamed:@"hh2.jpg"];
//    }
//    if (!self.after) {
//        self.after = [UIImage imageNamed:@"hh1.jpg"];
//    }
//    self.imageViewBefore.image = self.before;
//    self.imageViewAfter.image = self.after;
    
    UIImage *test = [UIImage imageNamed:@"hh2.jpg"];
    CGRect imageRect = CGRectInset(self.bounds, self.bounds.size.width, self.bounds.size.height);
    [test drawInRect:imageRect];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.masker setHidden:NO];
    [self meld];
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

- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer {
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
//    ((UIImageView *)recognizer.view).layer.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
}

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint translation = [recognizer translationInView:self];
    
    self.masker.perc = ([recognizer locationInView:recognizer.view].x-[recognizer locationInView:recognizer.view].y)/ recognizer.view.bounds.size.width;
    [self.masker redraw];
    
    
}


@end
