//
//  CollectionCell.m
//  Juxt
//
//  Created by John Brown on 8/7/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import "CollectionViewController.h"
#import "CollectionCell.h"
#import "DRNRealTimeBlurView.h"
#import "MeldView.h"
#import "Pose.h"

@interface CollectionCell()
@property (nonatomic, strong) MeldView *meldView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) DRNRealTimeBlurView *blurView;
@end

@implementation CollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        UIPanGestureRecognizer *tapRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:tapRecognizer];
        self.clipsToBounds = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGRect dim = [self getFrame:2];
    self.meldView = [[MeldView alloc] initWithPose:self.pose inFrame:dim withInteractions:NO];
    [self addSubview: self.meldView];
}

- (void)tap:(UIPanGestureRecognizer *)recognizer {
    //[(CollectionViewController *)self.superview performSegueWithIdentifier:@"editPose" sender:self];
}

- (BOOL)canBecomeFirstResponder { return YES; }

-(CGRect) getFrame:(int) newSize {
    int div = 4;
    int offset = 2;
    if (newSize == 1) {
        div = 2;
    } else if (newSize == 2) {
        div = 1;
        offset=0;
    }
    CGRect newFrame;
    if ([self.pose.ratio intValue] == 1) {
        newFrame = CGRectMake(0, 0, 320/div - offset, 320/div);
    } else if ([self.pose.ratio intValue] == 2) {
        newFrame = CGRectMake(0, 0, 320/div - offset, 240/div);
    } else if ([self.pose.ratio intValue] == 3) {
        newFrame = CGRectMake(0, 0, 320/div - offset, 427/div);
    }
    return newFrame;
}

-(void) updateUI {
    [self.meldView removeFromSuperview];
    [self setNeedsDisplay];
//    self.blurView = [[DRNRealTimeBlurView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
//    [self addSubview:self.blurView];
}

-(void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    // apply custom attributes...
    [self.meldView setNeedsDisplay]; // force drawRect:
}

-(void) changeViewSize:(int) newSize {
    CGRect newFrame = [self getFrame:newSize];
    self.imageView.frame = newFrame;
    // [UIView animateWithDuration:0.3f
    //                  animations:^
    //  {
    //      [self.imageView setFrame:newFrame];
    //  }
    //                  completion:^(BOOL finished)
    //  {
    //  }
    //  ];
}


@end
