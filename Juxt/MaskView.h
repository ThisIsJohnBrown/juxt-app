//
//  MeldView.h
//  Juxt
//
//  Created by John Brown on 7/28/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MaskView : UIView

@property (nonatomic) CGFloat perc;
@property (nonatomic) NSNumber *direction;

@property (nonatomic, strong) UIImage *image;
- (void)redraw:(float)maskPercentage;
- (void)nextDirection;

-(id)initWithPerc:(float)perc andDirection:(NSNumber *)direction;

@end
