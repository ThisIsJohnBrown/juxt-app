//
//  MeldView.h
//  Juxt
//
//  Created by John Brown on 7/28/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MaskView : UIView
@property (nonatomic, strong) UIImage *image;
@property (nonatomic) CGFloat perc;
@property (nonatomic) NSString *type;
- (void)redraw;
@end
