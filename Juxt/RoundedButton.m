//
//  RoundedButton.m
//  Juxt
//
//  Created by John Brown on 8/22/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import "RoundedButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation RoundedButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    self.layer.cornerRadius=8.0f;
    self.layer.masksToBounds=YES;
    self.layer.borderColor=[[UIColor whiteColor]CGColor];
    self.layer.borderWidth= 1.0f;
    
    //self.textColor  = [UIColor whiteColor];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.layer.backgroundColor = [[[UIColor alloc] initWithRed:0.77 green:0.223 blue:0.188 alpha:0.8] CGColor];
    self.font = [UIFont fontWithName:@"Avenir Next Regular" size:52];
}

@end
