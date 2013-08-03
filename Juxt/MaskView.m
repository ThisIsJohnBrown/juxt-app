//
//  MeldView.m
//  Juxt
//
//  Created by John Brown on 7/28/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import "MaskView.h"

@interface MaskView()

@property (nonatomic, strong) NSArray *directions;

@end

@implementation MaskView

-(id)initWithPerc:(float)perc andDirection:(NSString *)direction {
    if ((self = [super init])) {
        self.perc = perc;
        self.direction = direction;
    }
    return self;
}

- (NSArray *)directions {
    if (!_directions) {
        _directions = @[@"left", @"vertical", @"right", @"horizontal"];
    }
    return _directions;
}

- (NSString *)direction {
    if (!_direction) {
        _direction = @"left";
    }
    return _direction;
}

- (void)nextDirection {
    int index = [self.directions indexOfObject:self.direction] + 1;
    self.direction = self.directions[index < self.directions.count ? index : 0];
    [self redraw:self.perc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    [self setNeedsDisplay];
    return self;
}

@synthesize perc = _perc;

- (CGFloat)perc {
    if (!_perc) {
        _perc = .5;
    }
    return _perc;
}

- (void)setPerc:(CGFloat)perc {
    if (_perc != perc) {

    }
    _perc = perc;
    
}

- (void)redraw:(float)maskPercentage {
    self.perc = maskPercentage;
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect {
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];

    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);

    CGMutablePathRef a_path = CGPathCreateMutable();
    
    
    
    
    
    //Add a polygon to the path
    if ([self.direction isEqualToString:@"left"]) {
        CGPathMoveToPoint(a_path, NULL, self.frame.size.width*(self.perc) - self.frame.size.width*(1-self.perc), 0);
        CGPathAddLineToPoint(a_path, NULL, self.frame.size.width*(self.perc) - self.frame.size.width*(1-self.perc), 0);
        CGPathAddLineToPoint(a_path, NULL,self.frame.size.width, 0);
        CGPathAddLineToPoint(a_path, NULL,self.frame.size.width, self.bounds.size.height);
        CGPathAddLineToPoint(a_path, NULL,self.frame.size.width*(self.perc*2), self.bounds.size.height);
    } else if ([self.direction isEqualToString:@"right"]) {
        CGPathMoveToPoint(a_path, NULL, self.frame.size.width*(self.perc*2), 0);
        CGPathAddLineToPoint(a_path, NULL, self.frame.size.width*(self.perc*2), 0);
        CGPathAddLineToPoint(a_path, NULL,self.frame.size.width*(self.perc) - self.frame.size.width*(1-self.perc), self.bounds.size.height);
        CGPathAddLineToPoint(a_path, NULL,self.frame.size.width*(self.perc) - self.frame.size.width*(1*self.perc), self.bounds.size.height);
        CGPathAddLineToPoint(a_path, NULL,self.frame.size.width*(self.perc) - self.frame.size.width*(1*self.perc), 0);
        //CGPathAddLineToPoint(a_path, NULL,self.frame.size.width, self.bounds.size.height);
        //CGPathAddLineToPoint(a_path, NULL,self.frame.size.width*(self.perc*2), self.bounds.size.height);
        //CGPathAddLineToPoint(a_path, NULL,self.frame.size.width, 0);
    } else if ([self.direction isEqualToString:@"horizontal"]) {
        CGPathMoveToPoint(a_path, NULL, 0, 0);
        CGPathAddLineToPoint(a_path, NULL,0, 0);
        CGPathAddLineToPoint(a_path, NULL,self.frame.size.width, 0);
        CGPathAddLineToPoint(a_path, NULL,self.frame.size.width, self.frame.size.height*(self.perc));
        CGPathAddLineToPoint(a_path, NULL,0, self.frame.size.height*(self.perc));
    } else if ([self.direction isEqualToString:@"vertical"]) {
        CGPathMoveToPoint(a_path, NULL, 0, 0);
        CGPathAddLineToPoint(a_path, NULL,0, 0);
        CGPathAddLineToPoint(a_path, NULL,self.frame.size.width*(self.perc), 0);
        CGPathAddLineToPoint(a_path, NULL,self.frame.size.width*(self.perc), self.frame.size.height);
        CGPathAddLineToPoint(a_path, NULL,0, self.frame.size.height);
    }
    
    
    

    CGContextAddPath(context, a_path);

    // Fill the path
    
    CGContextFillPath(context);
    CGPathRelease(a_path);
}

@end
