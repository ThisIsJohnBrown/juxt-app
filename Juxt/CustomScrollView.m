//
//  CustomScrollView.m
//  Juxt
//
//  Created by John Brown on 7/31/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import "CustomScrollView.h"

@implementation CustomScrollView

- (id)initWithFrame:(CGRect)frame
{
    return [super initWithFrame:frame];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {

    return [super hitTest:point withEvent:event];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //    NSLog(@"AppScrollView touchesBegan:withEvent:");
    
    [[self.nextResponder nextResponder] touchesBegan:touches withEvent:event];
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
//        NSLog(@"AppScrollView touchesCancelled:withEvent:");
    
    [[self.nextResponder nextResponder] touchesCancelled:touches withEvent:event];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"AppScrollView touchesEnded:withEvent:");
    
    [[self.nextResponder nextResponder] touchesMoved:touches withEvent:event];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"--%c", self.dragging);
    //NSLog(@"AppScrollView touchesMoved:withEvent:");
    
    [[self.nextResponder nextResponder] touchesMoved:touches withEvent:event];
}

@end
