//
//  NavigationBar.m
//  Juxt
//
//  Created by John Brown on 8/4/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import "NavigationBar.h"

@interface NavigationBar()
@property (nonatomic, strong) UIView *pulldown;
@property (nonatomic, strong) UIView *pulldownMasker;
@end

@implementation NavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pulldownGesture:)];
        [self addGestureRecognizer:panGesture];
        
        //self.tintColor = [UIColor blackColor];
        //self.translucent = YES;
        self.alpha = 1;
        
        self.pulldownMasker = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, 480)];
        self.pulldownMasker.clipsToBounds = YES;
        self.pulldownMasker.userInteractionEnabled = YES;
        [self addSubview:self.pulldownMasker];
        
        self.pulldown = [[UIView alloc] initWithFrame:CGRectMake(0, -480, self.frame.size.width, 480)];
        self.pulldown.userInteractionEnabled = YES;
//        [self addSubview:self.pulldown];
        self.pulldown.backgroundColor = [UIColor greenColor];
        [self.pulldownMasker addSubview:self.pulldown];
        
        UIPanGestureRecognizer *panGesture2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pulldownGesture:)];
        [self.pulldown addGestureRecognizer:panGesture2];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:tapGesture];
        
        UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"juxt-logo.png"]];
        logo.frame = CGRectMake(self.frame.size.width/2-53/2, 0, 53, 41);
        [self addSubview:logo];
        
//        UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"Login"];
//        [self pushNavigationItem:item animated:NO];
//        UIBarButtonItem *leftBarButtonItem =[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(logout)];
//        self.navigationItem.leftBarButtonItem = leftBarButtonItem;
//        self.navigationItem.leftItemsSupplementBackButton = YES;
        
    }
    return self;
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (void)logout {
    
}

- (void)tap:(UITapGestureRecognizer *)recognizer {
    //NSLog(@"Asdf");
}

- (void)pulldownGesture:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        float endPoint = -240;
        if ((self.pulldown.frame.size.height/2 - self.pulldown.center.y)/480 < .6) {
            endPoint = 240;
        }
        [UIView animateWithDuration:0.6f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [self.pulldown setCenter:CGPointMake(self.pulldown.center.x, endPoint)];
                         }
                         completion:^(BOOL finished){
                             
                         }
         ];
    } else {
        CGPoint translation = [recognizer translationInView:self];
        float newY = self.pulldown.center.y + translation.y;
        self.pulldown.center = CGPointMake(self.pulldown.center.x, newY);
        [recognizer setTranslation:CGPointMake(0, 0) inView:self.pulldown];
    }
}

- (void)drawRect:(CGRect)rect {
    UIColor *color = [self colorFromHexString:@"#df473d"];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColor(context, CGColorGetComponents( [color CGColor]));
    CGContextFillRect(context, rect);
}

@end
