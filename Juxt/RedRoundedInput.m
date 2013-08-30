//
//  RedRoundedInput.m
//  Juxt
//
//  Created by John Brown on 8/22/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import "RedRoundedInput.h"
#import <QuartzCore/QuartzCore.h>

@implementation RedRoundedInput

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
//    //self.borderStyle = UITextBorderStyleRoundedRect;
//    self.background = [UIImage imageNamed:@"input-background.png"];
//    self.opaque = NO;
//    self.textColor  = [UIColor whiteColor];
//    self.borderStyle = UITextBorderStyleLine;
//    
//    self.layer.borderColor = [[UIColor blackColor]CGColor];
    
    self.layer.cornerRadius=8.0f;
    self.layer.masksToBounds=YES;
    self.layer.borderColor=[[UIColor whiteColor]CGColor];
    self.layer.borderWidth= 1.0f;
    
    self.textColor  = [UIColor whiteColor];
    self.layer.backgroundColor = [[[UIColor alloc] initWithRed:0.77 green:0.223 blue:0.188 alpha:0.8] CGColor];
    self.font = [UIFont fontWithName:@"Avenir Next Regular" size:52];
}


@end
