//
//  Utilities.h
//  Juxt
//
//  Created by John Brown on 8/25/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utilities : NSObject
-(NSString *) genRandStringLength: (int) len;
-(UIImage *)resizeImage:(UIImage *)image
                  width:(CGFloat)resizedWidth
                 height:(CGFloat)resizedHeight
                offsetX:(CGFloat)offsetX
                offsetY:(CGFloat)offsetY
                  scale:(CGFloat)scale;
@end
