//
//  MeldView.m
//  Juxt
//
//  Created by John Brown on 8/2/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import "CollectionViewController.h"
#import "GPUImage.h"
#import "MeldView.h"
#import "MaskView.h"
#import "Pose.h"
#import <QuartzCore/QuartzCore.h>
#import "Utilities.h"

@interface MeldView ()

@property (strong, nonatomic) UIView *beforeHolderView;
@property (strong, nonatomic) UIImageView *beforeImageView;

@property (nonatomic, strong) UIView *afterHolderView;
@property (nonatomic, strong) UIImageView *afterImageView;

@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) MaskView *masker;
@property (nonatomic) float maskPercentage;

@property (nonatomic, strong) UIView *meldOverlayView;
@property (nonatomic, strong) UIImageView *selectedImage;

@property (nonatomic) BOOL hasInteractions;
@property (nonatomic) int ratio;

@end

@implementation MeldView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithPose:(Pose *)pose inFrame:(CGRect)frame withInteractions:(BOOL)interactions {
    if ((self = [super initWithFrame:frame])) {
        self.pose = pose;
        self.hasInteractions = interactions;
        self.opaque = NO;
        self.clipsToBounds = YES;
        self.ratio = [self.pose.ratio intValue];
        self.needsRedraw = YES;
    }
    return self;
}

- (void)afterOpacity:(float)opacity {
    self.afterHolderView.alpha = opacity;
}

- (void)nextDirection {
    [self.masker nextDirection];
    [self centerLine];
}

- (int)ratio {
    if (!_ratio) _ratio = [self.pose.ratio floatValue];
    return _ratio;
}

- (void)changeRatio {
    self.ratio++;
    if (self.ratio > 3) {
        self.ratio = 1;
    }
    if (self.ratio == 1) {
        self.frame = CGRectMake(0, 0, 320, 320);
    } else if (self.ratio == 2) {
        self.frame = CGRectMake(0, 40, 320, 240);
    } else if (self.ratio == 3) {
        self.frame = CGRectMake(40, 0, 240, 320);
    }
    
    self.masker.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self.masker redraw:self.maskPercentage];
    
    self.beforeHolderView.frame = CGRectMake(0,0,self.frame.size.width,self.frame.size.height);
    UIImage *tempBeforeImage = [UIImage imageWithContentsOfFile:self.pose.beforePath];
    self.beforeImageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=tempBeforeImage.size};
    
    self.afterHolderView.frame = CGRectMake(0,0,self.frame.size.width,self.frame.size.height);
    UIImage *tempAfterImage = [UIImage imageWithContentsOfFile:self.pose.afterPath];
    self.afterImageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=tempAfterImage.size};
    
    [self setInitScale:self.pose.beforeScale
                 image:self.beforeImageView
                  path:self.pose.beforePath
               offsetX:self.pose.beforeOffsetX
               offsetY:self.pose.beforeOffsetY];
    
    [self setInitScale:self.pose.afterScale
                 image:self.afterImageView
                  path:self.pose.afterPath
               offsetX:self.pose.afterOffsetX
               offsetY:self.pose.afterOffsetY];
    
    self.meldOverlayView.frame = CGRectMake(0,0,self.frame.size.width,self.frame.size.height);
    
    self.selectedImage = self.beforeImageView;
    [self centerSelectedImage:CGPointMake(0, 0)];
    
    self.selectedImage = self.afterImageView;
    [self centerSelectedImage:CGPointMake(0, 0)];
    
    [self centerLine];
}

- (Pose *)savePose {
    self.pose.perc = [NSNumber numberWithFloat:self.maskPercentage];
    self.pose.direction = self.masker.direction;
    self.pose.ratio = [NSNumber numberWithFloat:self.ratio];
    
    CGRect frame = self.beforeImageView.frame;
    self.pose.beforeScale = [NSNumber numberWithFloat:
                       self.frame.size.width/frame.size.width];
    self.pose.beforeOffsetX = [NSNumber numberWithFloat:
                               -(self.beforeImageView.center.x - self.beforeImageView.frame.size.width/2)/self.frame.size.width];
    self.pose.beforeOffsetY = [NSNumber numberWithFloat:
                               -(self.beforeImageView.center.y - self.beforeImageView.frame.size.height/2)/self.frame.size.width];
    
    frame = self.afterImageView.frame;
    self.pose.afterScale = [NSNumber numberWithFloat:
                             self.frame.size.width/frame.size.width];
    self.pose.afterOffsetX = [NSNumber numberWithFloat:
                              -(self.afterImageView.center.x - self.afterImageView.frame.size.width/2)/self.frame.size.width];
    self.pose.afterOffsetY = [NSNumber numberWithFloat:
                              -(self.afterImageView.center.y - self.afterImageView.frame.size.height/2)/self.frame.size.width];
    
//    [self.beforeImageView setHidden:YES];
//    [self.afterImageView setHidden:YES];
//    [self.masker setHidden:NO];
//    
//    MaskView *maskerTemp = [[MaskView alloc] initWithPerc:self.maskPercentage andDirection:self.masker.direction];
//    maskerTemp.frame = self.afterHolderView.frame;
//    [self addSubview:maskerTemp];
//    [maskerTemp redraw:self.maskPercentage];
//    
//    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
//    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
//    CGImageRef mask = CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());
//    UIGraphicsEndImageContext();
//    
//    [maskerTemp setHidden:YES];
//    [self.afterImageView setHidden:NO];
//    
//    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 1);
//    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0, self.bounds.size.height);
//    CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
//    CGContextClipToMask(UIGraphicsGetCurrentContext(), self.meldOverlayView.frame, mask);
//    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0, self.bounds.size.height);
//    CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
//    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage *imageMasked = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//
//    [self.afterImageView setHidden:YES];
//    [self.beforeImageView setHidden:NO];
//    
//    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
//    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
//    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0, self.bounds.size.height);
//    CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
//    CGContextDrawImage(UIGraphicsGetCurrentContext(), self.meldOverlayView.frame, imageMasked.CGImage);
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    [self.afterImageView setHidden:NO];
//    [self.beforeImageView setHidden:NO];
    
//    NSData *imageData = UIImagePNGRepresentation(image);
//    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    
//    NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@.png",self.pose.identifier, @"t"]];
//    
//    if (![imageData writeToFile:imagePath atomically:NO])
//    {
//        NSLog(@"Failed to cache image data to disk");
//    }
//    else
//    {
//                   //NSLog(@"the cachedImagedPath is %@",imagePath);
//    }

    
    return self.pose;
}
//
//- (UIImage*) blur:(UIImage*)theImage
//{
//    // create our blurred image
//    CIContext *context = [CIContext contextWithOptions:nil];
//    CIImage *inputImage = [CIImage imageWithCGImage:theImage.CGImage];
//    
//    // setting up Gaussian Blur (we could use one of many filters offered by Core Image)
//    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
//    [filter setValue:inputImage forKey:kCIInputImageKey];
//    [filter setValue:[NSNumber numberWithFloat:15.0f] forKey:@"inputRadius"];
//    CIImage *result = [filter valueForKey:kCIOutputImageKey];
//    
//    // CIGaussianBlur has a tendency to shrink the image a little,
//    // this ensures it matches up exactly to the bounds of our original image
//    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
//    
//    return [UIImage imageWithCGImage:cgImage];
//    
//    // if you need scaling
//    // return [[self class] scaleIfNeeded:cgImage];
//}
//
//+(UIImage*) scaleIfNeeded:(CGImageRef)cgimg {
//    bool isRetina = [[[UIDevice currentDevice] systemVersion] intValue] >= 4 && [[UIScreen mainScreen] scale] == 2.0;
//    if (isRetina) {
//        return [UIImage imageWithCGImage:cgimg scale:2.0 orientation:UIImageOrientationUp];
//    } else {
//        return [UIImage imageWithCGImage:cgimg];
//    }
//}

- (void)switchImages {
    NSString *oldBefore = self.pose.beforePath;
    NSNumber *oldBeforeOffsetX = self.pose.beforeOffsetX;
    NSNumber *oldBeforeOffsetY = self.pose.beforeOffsetY;
    NSNumber *oldBeforeScale = self.pose.beforeScale;
    NSString *oldAfter = self.pose.afterPath;
    NSNumber *oldAfterOffsetX = self.pose.afterOffsetX;
    NSNumber *oldAfterOffsetY = self.pose.afterOffsetY;
    NSNumber *oldAfterScale = self.pose.afterScale;
    
    self.pose.beforePath = oldAfter;
    self.pose.beforeOffsetX = oldAfterOffsetX;
    self.pose.beforeOffsetY = oldAfterOffsetY;
    self.pose.beforeScale = oldAfterScale;
    self.pose.afterPath = oldBefore;
    self.pose.afterOffsetX = oldBeforeOffsetX;
    self.pose.afterOffsetY = oldBeforeOffsetY;
    self.pose.afterScale = oldBeforeScale;
    
    MeldView *newMeld = [self initWithPose:self.pose inFrame:self.frame withInteractions:self.hasInteractions];
    NSLog(@"%@", newMeld);
    
    [self setNeedsDisplay];
    
    //[NSTimer scheduledTimerWithTimeInterval:.03 target:self selector:@selector(runScheduledTask) userInfo:nil repeats:YES];
}

- (void)runScheduledTask {
    if ([self.pose.perc floatValue] > self.maskPercentage + .003) {
        self.maskPercentage = self.maskPercentage + .003;
    }
    [self.masker redraw:self.maskPercentage];
}

-(void) updateUI {
    self.beforeHolderView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width,self.frame.size.height)];
    self.beforeHolderView.clipsToBounds = YES;
    [self addSubview:self.beforeHolderView];
    if ([self.pose.beforePath length] != 0) {
        self.beforeImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:self.pose.beforePath]];
    }
    //[NSData dataWithContentsOfURL:[NSURL URLWithString:url_Img_FULLurl_Img_FULL]]
    self.beforeImageView.userInteractionEnabled = YES;
    self.beforeImageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=self.beforeImageView.image.size};
    [self.beforeHolderView addSubview:self.beforeImageView];
    
    [self setInitScale:self.pose.beforeScale
                 image:self.beforeImageView
                  path:self.pose.beforePath
               offsetX:self.pose.beforeOffsetX
               offsetY:self.pose.beforeOffsetY];
    
    self.afterHolderView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width,self.frame.size.height)];
    self.afterHolderView.clipsToBounds = YES;
    [self addSubview:self.afterHolderView];
    if (self.pose.afterPath) {
        self.afterImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:self.pose.afterPath]];
    }
    self.afterImageView.userInteractionEnabled = YES;
    self.afterImageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=self.afterImageView.image.size};
    [self.afterHolderView addSubview:self.afterImageView];
    
    [self setInitScale:self.pose.afterScale
                 image:self.afterImageView
                  path:self.pose.afterPath
               offsetX:self.pose.afterOffsetX
               offsetY:self.pose.afterOffsetY];
}

- (void)drawRect:(CGRect)rect
{
    Utilities *util = [[Utilities alloc] init];
    if (!self.pose.beforePath) {
        
        
    } else {
        if (!self.beforeImageView.image || self.needsRedraw) {
            self.beforeHolderView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width,self.frame.size.height)];
            self.beforeHolderView.clipsToBounds = YES;
            [self addSubview:self.beforeHolderView];
            if ([self.pose.beforePath length] != 0) {
                UIImage *beforeImage = [UIImage imageWithContentsOfFile:self.pose.beforePath];
                self.beforeImageView = [[UIImageView alloc] initWithImage:beforeImage];
            }
            //[NSData dataWithContentsOfURL:[NSURL URLWithString:url_Img_FULLurl_Img_FULL]]
            self.beforeImageView.userInteractionEnabled = YES;
            
            if (! self.pose.uploaded) {
                self.beforeImageView.frame = CGRectMake(0, 0, self.beforeImageView.image.size.width, self.beforeImageView.image.size.height);
                [self setInitScale:self.pose.beforeScale
                             image:self.beforeImageView
                              path:self.pose.beforePath
                           offsetX:self.pose.beforeOffsetX
                           offsetY:self.pose.beforeOffsetY];
            } else {
                self.beforeImageView.frame = CGRectMake(0, 0, self.frame.size.width,self.frame.size.height);
            }
            
            [self.beforeHolderView addSubview:self.beforeImageView];
        }
        
        if (!self.afterImageView.image || self.needsRedraw) {
            self.afterHolderView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width,self.frame.size.height)];
            self.afterHolderView.clipsToBounds = YES;
            [self addSubview:self.afterHolderView];
            if (self.pose.afterPath) {
                UIImage *afterImage = [UIImage imageWithContentsOfFile:self.pose.afterPath];
                self.afterImageView = [[UIImageView alloc] initWithImage:afterImage];
            } else {
                self.afterImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"add.png"]];
            }
            self.afterImageView.userInteractionEnabled = YES;
            
            if (! self.pose.uploaded) {
                self.afterImageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=self.afterImageView.image.size};
                [self setInitScale:self.pose.afterScale
                             image:self.afterImageView
                              path:self.pose.afterPath
                           offsetX:self.pose.afterOffsetX
                           offsetY:self.pose.afterOffsetY];
            } else {
                self.afterImageView.frame = CGRectMake(0, 0, self.frame.size.width,self.frame.size.height);
            }
            
            [self.afterHolderView addSubview:self.afterImageView];
        }

        if (!self.masker || self.needsRedraw) {
            self.masker = [[MaskView alloc] initWithPerc:self.maskPercentage andDirection:self.pose.direction];
            self.masker.frame = self.afterHolderView.frame;
            [self addSubview:self.masker];
            [self.afterHolderView.layer setMask:self.masker.layer];
        }
        
        if (!self.meldOverlayView || self.needsRedraw) {
            self.meldOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width,self.frame.size.height)];
            self.meldOverlayView.opaque = NO;
            self.meldOverlayView.backgroundColor = [UIColor clearColor];
            [self addSubview:self.meldOverlayView];
        
            
            UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
                [self.meldOverlayView addGestureRecognizer:panRecognizer];

            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
                [self.meldOverlayView addGestureRecognizer:tapRecognizer];

            if (self.hasInteractions) {
                
                
                
                UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
                [self.meldOverlayView addGestureRecognizer:pinchRecognizer];
                
            }
        }
        
        if (!self.lineView || self.needsRedraw) {
            self.lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, (self.bounds.size.width +self.bounds.size.height)*2, 2)];
            self.lineView.backgroundColor = [UIColor whiteColor];
            [self addSubview:self.lineView];
            [self centerLine];
        }
        
        self.needsRedraw = NO;
        
        if (! self.pose.identifier) {
        
            self.selectedImage = self.beforeImageView;
            [self centerSelectedImage:CGPointMake(0, 0)];
            
            if (self.pose.afterPath) {
                self.selectedImage = self.afterImageView;
                [self centerSelectedImage:CGPointMake(0, 0)];
            }
            CALayer *backgroundLayer = [CALayer layer];
        }
        
//        CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
//        [blurFilter setDefaults];
//        backgroundLayer.backgroundFilters = [NSArray arrayWithObject:blurFilter];
//        
//        [[self layer] addSublayer:backgroundLayer];
    }

    //

    
//    [self initHolder:self.beforeHolderView withImage:self.pose.before inImageView:self.beforeImageView];
//    [self initHolder:self.afterHolderView withImage:self.pose.after inImageView:self.afterImageView];

}

- (void)centerLine {
    float ratio = self.meldOverlayView.frame.size.width/self.meldOverlayView.frame.size.height;
    float angle;
    if ([self.masker.direction intValue] == 0) {
        angle = .25*M_PI;
        if (ratio < .9) {
            angle = 0.927642497;
        } else if (ratio > 1.1) {
            angle = 0.643153829;
        }
        self.lineView.transform = CGAffineTransformMakeRotation(angle);
        self.lineView.center = CGPointMake(self.meldOverlayView.frame.size.width*(self.maskPercentage) - self.meldOverlayView.frame.size.width*(1-self.maskPercentage), 0);
    } else if ([self.masker.direction intValue] == 3) {
        self.lineView.transform = CGAffineTransformMakeRotation(0);
        self.lineView.center = (CGPointMake(0, self.meldOverlayView.frame.size.height * self.maskPercentage));
    } else if ([self.masker.direction intValue] == 2) {
        angle = .75*M_PI;
        if (ratio > 1.1) {
            angle = 0.927642497+.5*M_PI;
        } else if (ratio < .9) {
            angle = 0.643153829+.5*M_PI;
        }
        self.lineView.transform = CGAffineTransformMakeRotation(angle);
        self.lineView.center = (CGPointMake(self.meldOverlayView.frame.size.width*(self.maskPercentage*2), 0));
        //self.lineView.center = CGPointMake(160, 213);
    } else if ([self.masker.direction intValue] == 1) {
        self.lineView.transform = CGAffineTransformMakeRotation(.5*M_PI);
        self.lineView.center = (CGPointMake(self.meldOverlayView.frame.size.width * self.maskPercentage, 0));
    }
}

- (void)setInitScale:(NSNumber *)scale image:(UIImageView *)image path:(NSString *)path offsetX:(NSNumber *)offsetX offsetY:(NSNumber *)offsetY {
    if (path) {
        float ratio = image.image.size.width / image.image.size.height;
        float widthRatio = image.bounds.size.width / image.image.size.width;
        float heightRatio = image.bounds.size.height / image.image.size.height;
        float scaleMax = MAX(widthRatio, heightRatio);
        float imageWidth = scaleMax * image.image.size.width;
        float imageHeight = scaleMax * image.image.size.height;
        image.frame = CGRectMake(0, 0, imageWidth, imageHeight);
        
        CGRect scrollViewFrame = self.beforeHolderView.frame;
        CGFloat scaleWidth = scrollViewFrame.size.width / image.frame.size.width;
        CGFloat scaleHeight = scrollViewFrame.size.height / image.frame.size.height;
        
        CGRect t = image.frame;
        CGFloat multiplier = scaleWidth < scaleHeight ? scaleHeight : scaleWidth;
        image.frame = CGRectMake(t.origin.x, t.origin.y, t.size.width*multiplier, t.size.height*multiplier);
        
        if ([scale floatValue] == 1){

        } else {
            float newWidth;
            if (ratio > 1) {
                newWidth = self.frame.size.width/[scale floatValue];
            } else {
                newWidth = self.frame.size.width*[scale floatValue];
            }
            image.frame = CGRectMake(
                                     -self.frame.size.width*[offsetX floatValue],
                                     -self.frame.size.height*[offsetY floatValue],
                                     newWidth,
                                     self.frame.size.height/[scale floatValue]/ratio * (self.frame.size.width/self.frame.size.height));
        }
    }
}

- (void)initHolder:(UIView *)holder withImage:(UIImage *)image inImageView:(UIImageView *)imageView {
    holder = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width,self.frame.size.height)];
    holder.clipsToBounds = YES;
    [self addSubview:holder];
    imageView = [[UIImageView alloc] initWithImage:image];
    //[NSData dataWithContentsOfURL:[NSURL URLWithString:url_Img_FULLurl_Img_FULL]]
    imageView.userInteractionEnabled = YES;
    imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=image.size};
    [holder addSubview:imageView];
    
    float widthRatio = imageView.bounds.size.width / imageView.image.size.width;
    float heightRatio = imageView.bounds.size.height / imageView.image.size.height;
    float scale = MAX(widthRatio, heightRatio);
    float imageWidth = scale * imageView.image.size.width;
    float imageHeight = scale * imageView.image.size.height;
    imageView.frame = CGRectMake(0, 0, imageWidth, imageHeight);
    
}

- (void)pan:(UIPanGestureRecognizer *)recognizer {
    CGPoint pointInView = [recognizer locationInView:self];
    
    if (recognizer.state == (long)UIGestureRecognizerStateBegan) {
        [self setSelectedImage:recognizer withOffset:[self getGestureOffset:pointInView]];
    } else if (recognizer.state == (long)UIGestureRecognizerStateEnded) {
        self.selectedImage = nil;
        if (!self.hasInteractions) {
            self.maskPercentage = .5;
        }
    }
    if (self.selectedImage) {
        if (self.hasInteractions) {
            CGPoint translation = [recognizer translationInView:self];
            [self centerSelectedImage:translation];
            [recognizer setTranslation:CGPointMake(0, 0) inView:self.selectedImage];
        } else {
            //NSLog(@"%@", [self nextResponder]);
        }
    } else {
        if (recognizer.state == UIGestureRecognizerStateChanged) {
            float ratio = self.meldOverlayView.frame.size.width/self.meldOverlayView.frame.size.height;
            if ([self.masker.direction intValue] == 0) {
                self.maskPercentage = ((pointInView.x-(pointInView.y*ratio))/self.frame.size.width + 1) / 2;
            } else if ([self.masker.direction intValue] == 2) {
                self.maskPercentage = (pointInView.x+(pointInView.y*ratio))/self.frame.size.width / 2;
            } else if ([self.masker.direction intValue] == 3) {
                self.maskPercentage = pointInView.y/self.frame.size.height;
            } else if ([self.masker.direction intValue] == 1) {
                self.maskPercentage = pointInView.x/self.frame.size.width;
            }
        }
    }
    
    [self.masker redraw:self.maskPercentage];
    [self centerLine];
}

- (void)pinch:(UIPinchGestureRecognizer *)recognizer {
    CGPoint pointInView = [recognizer locationInView:self];
    
    if (recognizer.state == (long)UIGestureRecognizerStateBegan) {
        [self setSelectedImage:recognizer withOffset:[self getGestureOffset:pointInView]];
    } else if (recognizer.state == (long)UIGestureRecognizerStateEnded) {
        self.selectedImage = nil;
    }
    float ratio = self.selectedImage.image.size.width / self.selectedImage.image.size.height;
    
    if (recognizer.state != (long)UIGestureRecognizerStateEnded) {
        if (self.selectedImage.frame.size.width*recognizer.scale < self.meldOverlayView.frame.size.width) {
            NSLog(@"TOO SMALL1");
//            self.selectedImage.frame = CGRectMake(self.selectedImage.frame.origin.x, self.selectedImage.frame.origin.x, self.meldOverlayView.frame.size.width, self.meldOverlayView.frame.size.width*ratio);
        } else if (self.selectedImage.frame.size.height*recognizer.scale < self.meldOverlayView.frame.size.height) {
            NSLog(@"TOO SMALL2");
            self.selectedImage.frame = CGRectMake(self.selectedImage.frame.origin.x, self.selectedImage.frame.origin.x, self.meldOverlayView.frame.size.height*ratio, self.meldOverlayView.frame.size.height);
            
//            self.selectedImage.transform = CGAffineTransformScale(self.selectedImage.transform, recognizer.scale, recognizer.scale);
        } else {
            self.selectedImage.transform = CGAffineTransformScale(self.selectedImage.transform, recognizer.scale, recognizer.scale);
        }
        recognizer.scale = 1;
        
        [self centerSelectedImage:CGPointMake(0, 0)];
    }
}

- (void)centerSelectedImage:(CGPoint)offset {
    CGRect frame = self.selectedImage.frame;
    
    float ratio = self.selectedImage.image.size.width / self.selectedImage.image.size.height;
    
    if (self.selectedImage.frame.size.width < self.meldOverlayView.frame.size.width) {
        NSLog(@"TOO SMALL1");
        self.selectedImage.frame = CGRectMake(self.selectedImage.frame.origin.x, self.selectedImage.frame.origin.x, self.meldOverlayView.frame.size.width, self.meldOverlayView.frame.size.width*ratio);
    } else if (self.selectedImage.frame.size.height < self.meldOverlayView.frame.size.height) {
        NSLog(@"TOO SMALL2");
        self.selectedImage.frame = CGRectMake(self.selectedImage.frame.origin.x, self.selectedImage.frame.origin.x, self.meldOverlayView.frame.size.height*ratio, self.meldOverlayView.frame.size.height);
    }
    
    frame = self.selectedImage.frame;
    
    float newX = frame.origin.x + offset.x > 0 ? frame.size.width/2 : self.selectedImage.center.x + offset.x;
    float minHorizontal = frame.size.width/2 + (self.meldOverlayView.frame.size.width - frame.size.width);
    if (newX < minHorizontal) {
        newX = minHorizontal;
    }
    float newY = frame.origin.y + offset.y > 0 ? frame.size.height/2 : self.selectedImage.center.y + offset.y;
    float minVertical =  frame.size.height/2 + (self.meldOverlayView.frame.size.height - frame.size.height);
    if (newY < minVertical) {
        newY = minVertical;
    }
    //NSLog(@"%f, %f, %f", self.selectedImage.center.y, newY, frame.size.width);
    self.selectedImage.center = CGPointMake(newX, newY);
}

- (void)tap:(UITapGestureRecognizer *)recognizer {
//    CGPoint pointInView = [recognizer locationInView:self];
//    float offset = [self getGestureOffset:pointInView];
//    
//    [self setSelectedImage:recognizer withOffset:offset];
    // NSLog(@"%@", self.superview.superview.superview.superview);
    // [(CollectionViewController *)self.superview.superview performSegueWithIdentifier:@"editPose" sender:self];
}

- (float)getGestureOffset:(CGPoint)pointInView {
    float offset = 0.0;
    float ratio = self.meldOverlayView.frame.size.width/self.meldOverlayView.frame.size.height;
    if ([self.masker.direction intValue] == 0) {
        offset = (pointInView.x - ((self.maskPercentage*2-1)*self.frame.size.width)) - (pointInView.y * ratio);
    } else if ([self.masker.direction intValue] == 2) {
        offset = (pointInView.x - ((self.maskPercentage*2)*self.frame.size.width)) + (pointInView.y * ratio);
    } else if ([self.masker.direction intValue] == 3) {
        offset = pointInView.y - self.maskPercentage*self.frame.size.height;
    } else if ([self.masker.direction intValue] == 1) {
        offset = pointInView.x - self.maskPercentage*self.frame.size.width;
    }
    
    return offset;
}

- (void)setSelectedImage:(UIGestureRecognizer *)recognizer withOffset:(float)offset {
    if (offset < -30) {
        NSLog(@"Before");
        self.selectedImage = self.beforeImageView;
    } else if (offset > 30) {
        NSLog(@"After");
        self.selectedImage = self.afterImageView;
    } else {
        NSLog(@"Center");
        self.selectedImage = nil;
    }
    
    // DEBUGGING! REMOVE
    //self.selectedImage = self.beforeImageView;
}

- (float)maskPercentage {
    if (!_maskPercentage) {
        if (!self.hasInteractions) {
            _maskPercentage = .5;
        } else {
            //_maskPercentage = [self.pose.perc floatValue];
            _maskPercentage = .5;
        }
    }
    return _maskPercentage;
}

//- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
//    if (self.scrollViewBefore.maximumZoomScale != self.scrollViewBefore.maximumZoomScale) {
//        // 1
//        CGPoint pointInView = [recognizer locationInView:self.scrollViewBefore];
//    //    NSLog(@"%@", pointInView.x);
//
//        // 2
//        CGFloat newZoomScale = self.scrollViewBefore.zoomScale * 1.5f;
//        newZoomScale = MIN(newZoomScale, self.scrollViewBefore.maximumZoomScale);
//
//        // 3
//        CGSize scrollViewSize = self.scrollViewBefore.bounds.size;
//
//        CGFloat w = scrollViewSize.width / newZoomScale;
//        CGFloat h = scrollViewSize.height / newZoomScale;
//        CGFloat x = pointInView.x - (w / 2.0f);
//        CGFloat y = pointInView.y - (h / 2.0f);
//
//        CGRect rectToZoomTo = CGRectMake(x, y, w, h);
//
//        // 4
//        [self.scrollViewBefore zoomToRect:rectToZoomTo animated:YES];
//    }
//}

//- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer {
//    // Zoom out slightly, capping at the minimum zoom scale specified by the scroll view
//    CGFloat newZoomScale = self.scrollViewBefore.zoomScale / 1.5f;
//    newZoomScale = MAX(newZoomScale, self.scrollViewBefore.minimumZoomScale);
//    [self.scrollViewBefore setZoomScale:newZoomScale animated:YES];
//}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    if (self.hasInteractions) {
        return hitView;
    }
//    NSSet *touches = [event allTouches];
//    UITouch *touch = [touches anyObject];
//    CALayer *touchedLayer = [touch view].layer;
    //NSLog(@"%@", event.type);
    // If the hitView is THIS view, return nil and allow hitTest:withEvent: to
    // continue traversing the hierarchy to find the underlying view.

    float offset = [self getGestureOffset:point];
    if (offset < 30 && offset > -30) {
       return hitView;
    }
    // Else return the hitView (as it could be one of this view's buttons):
    return nil;
}

@end
