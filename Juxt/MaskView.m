//
//  MeldView.m
//  Juxt
//
//  Created by John Brown on 7/28/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import "MaskView.h"

@implementation MaskView

- (NSString *)type {
    if (!_type) {
        _type = @"left";
    }
    return _type;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (CGFloat)perc {
    if (!_perc) {
        _perc = .05;
    }
    return _perc;
}

- (void)redraw {
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect {

    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);

    CGMutablePathRef a_path = CGPathCreateMutable();
    
    
    
    
    
    //Add a polygon to the path
    if ([self.type isEqualToString:@"left"]) {
        CGPathMoveToPoint(a_path, NULL, self.frame.size.width*self.perc, 0);
        CGPathAddLineToPoint(a_path, NULL,self.frame.size.width*self.perc, 0);
        CGPathAddLineToPoint(a_path, NULL,self.frame.size.width, 0);
        CGPathAddLineToPoint(a_path, NULL,self.frame.size.width, self.bounds.size.height);
        CGPathAddLineToPoint(a_path, NULL,self.frame.size.width*self.perc+self.frame.size.width*.5, self.bounds.size.height);
    } else {
        CGPathMoveToPoint(a_path, NULL, self.frame.size.width*self.perc+self.frame.size.width*.5, 0);
        CGPathAddLineToPoint(a_path, NULL,self.frame.size.width*self.perc+self.frame.size.width*.5, 0);
        CGPathAddLineToPoint(a_path, NULL,self.frame.size.width, 0);
        CGPathAddLineToPoint(a_path, NULL,self.frame.size.width, self.bounds.size.height);
        CGPathAddLineToPoint(a_path, NULL,self.frame.size.width*self.perc, self.bounds.size.height);
    }
    

    CGContextAddPath(context, a_path);

    // Fill the path
    
    CGContextFillPath(context);
    CGPathRelease(a_path);
}

@end
