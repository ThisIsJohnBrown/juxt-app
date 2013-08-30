//
//  Utilities.m
//  Juxt
//
//  Created by John Brown on 8/25/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

-(NSString *) genRandStringLength: (int) len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    
    return randomString;
}

-(UIImage *)resizeImage:(UIImage *)image
                  width:(CGFloat)resizedWidth
                 height:(CGFloat)resizedHeight
                offsetX:(CGFloat)offsetX
                offsetY:(CGFloat)offsetY
                  scale:(CGFloat)scale
{
    NSLog(@"%f, %f", resizedWidth, resizedHeight);
    float startX = (image.size.width * -offsetX) * scale;
    float startY = resizedHeight * -offsetY * scale;
    float width = resizedWidth / scale;
    UIGraphicsBeginImageContext(CGSizeMake(resizedWidth,resizedHeight));
    [image drawInRect:CGRectMake(startX/scale, startY/scale, width, width/(image.size.width/image.size.height))];
    UIImage *resized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resized;
}

@end
