//
//  MeldView.m
//  Juxt
//
//  Created by John Brown on 8/2/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import "MeldView.h"
#import "MaskView.h"
#import "Pose.h"
#import <QuartzCore/QuartzCore.h>

@interface MeldView ()

@property (strong, nonatomic) UIView *beforeHolderView;
@property (strong, nonatomic) UIImageView *beforeImageView;

@property (nonatomic, strong) UIView *afterHolderView;
@property (nonatomic, strong) UIImageView *afterImageView;

@property (nonatomic, strong) MaskView *masker;
@property (nonatomic) float maskPercentage;

@property (nonatomic, strong) UIView *meldOverlayView;
@property (nonatomic, strong) UIImageView *selectedImage;

@property (nonatomic) BOOL hasInteractions;

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
    }
    return self;
}

- (void)afterOpacity:(float)opacity {
    self.afterHolderView.alpha = opacity;
}

- (void)nextDirection {
    [self.masker nextDirection];
}

- (Pose *)savePose {
    self.pose.perc = [NSNumber numberWithFloat:self.maskPercentage];
    self.pose.direction = self.masker.direction;
    CGRect frame = self.beforeImageView.frame;
    NSLog(@"%f, %f, %f", self.frame.size.width, frame.size.width, self.frame.size.width/frame.size.width);
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
    return self.pose;
}

- (void)switchImages {
    UIImage *oldBefore = self.beforeImageView.image;
    UIImage *oldAfter = self.afterImageView.image;
    
    self.beforeImageView.image= oldAfter;
    self.afterImageView.image = oldBefore;
    
    [self.masker redraw:self.maskPercentage];
    
    //[NSTimer scheduledTimerWithTimeInterval:.03 target:self selector:@selector(runScheduledTask) userInfo:nil repeats:YES];
}

- (void)runScheduledTask {
    if ([self.pose.perc floatValue] > self.maskPercentage + .003) {
        self.maskPercentage = self.maskPercentage + .003;
    }
    NSLog(@"%f", self.maskPercentage);
    [self.masker redraw:self.maskPercentage];
}

- (void)drawRect:(CGRect)rect
{
    if (!self.pose.beforePath) {
        
                              
    } else {
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
        
        self.afterHolderView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width,self.frame.size.height)];
        self.afterHolderView.clipsToBounds = YES;
        [self addSubview:self.afterHolderView];
        if (self.pose.afterPath) {
            self.afterImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:self.pose.afterPath]];
        }
        self.afterImageView.userInteractionEnabled = YES;
        self.afterImageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=self.afterImageView.image.size};
        [self.afterHolderView addSubview:self.afterImageView];
        
        NSLog(@"%f, %@, %f, %f",
              self.beforeImageView.image.size.width,
              self.pose.beforeScale,
              self.frame.size.width,
              self.beforeImageView.image.size.width * [self.pose.beforeScale floatValue] * (self.frame.size.width/self.beforeImageView.image.size.width));
              
        
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
        
        
        self.masker = [[MaskView alloc] initWithPerc:[self.pose.perc floatValue] andDirection:self.pose.direction];
        self.masker.frame = self.afterHolderView.frame;
        [self addSubview:self.masker];
        [self.afterHolderView.layer setMask:self.masker.layer];
        
        self.meldOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width,self.frame.size.height)];
        self.meldOverlayView.opaque = NO;
        self.meldOverlayView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.meldOverlayView];
        
        if (self.hasInteractions) {
            UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
            [self.meldOverlayView addGestureRecognizer:panRecognizer];
            
            UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
            [self.meldOverlayView addGestureRecognizer:pinchRecognizer];
            
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
            [self.meldOverlayView addGestureRecognizer:tapRecognizer];
        }
    }
    
//    [self initHolder:self.beforeHolderView withImage:self.pose.before inImageView:self.beforeImageView];
//    [self initHolder:self.afterHolderView withImage:self.pose.after inImageView:self.afterImageView];

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
            
            image.frame = CGRectMake(
                                     -self.frame.size.width*[offsetX floatValue],
                                     -self.frame.size.height*[offsetY floatValue],
                                     self.frame.size.width/[scale floatValue],
                                     self.frame.size.height/[scale floatValue]/ratio);
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
    }
    if (self.selectedImage) {
        CGPoint translation = [recognizer translationInView:self];
        [self centerSelectedImage:translation];
        [recognizer setTranslation:CGPointMake(0, 0) inView:self.selectedImage];
    } else {
        if (recognizer.state == UIGestureRecognizerStateChanged) {
            if ([self.masker.direction isEqualToString:@"left"]) {
                self.maskPercentage = ((pointInView.x-pointInView.y)/self.frame.size.width + 1) / 2;
            } else if ([self.masker.direction isEqualToString:@"right"]) {
                self.maskPercentage = (pointInView.x+pointInView.y)/self.frame.size.width / 2;
            } else if ([self.masker.direction isEqualToString:@"horizontal"]) {
                self.maskPercentage = pointInView.y/self.frame.size.height;
            } else if ([self.masker.direction isEqualToString:@"vertical"]) {
                self.maskPercentage = pointInView.x/self.frame.size.width;
            }
        }
    }
    
    [self.masker redraw:self.maskPercentage];
    
    //    [self centerScrollViewContents];
}

- (void)pinch:(UIPinchGestureRecognizer *)recognizer {
    CGPoint pointInView = [recognizer locationInView:self];
    
    if (recognizer.state == (long)UIGestureRecognizerStateBegan) {
        [self setSelectedImage:recognizer withOffset:[self getGestureOffset:pointInView]];
    } else if (recognizer.state == (long)UIGestureRecognizerStateEnded) {
        self.selectedImage = nil;
    }
    
    if (recognizer.state != (long)UIGestureRecognizerStateEnded) {
        if (self.selectedImage.frame.size.width*recognizer.scale < self.meldOverlayView.frame.size.width ||
            self.selectedImage.frame.size.height*recognizer.scale < self.meldOverlayView.frame.size.height) {
            //NSLog(@"TOO SMALL");
        } else {
            self.selectedImage.transform = CGAffineTransformScale(self.selectedImage.transform, recognizer.scale, recognizer.scale);
        }
        recognizer.scale = 1;
        
        [self centerSelectedImage:CGPointMake(0, 0)];
    }
}

- (void)centerSelectedImage:(CGPoint)offset {
    CGRect frame = self.selectedImage.frame;
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
    self.selectedImage.center = CGPointMake(newX, newY);
}

- (void)tap:(UITapGestureRecognizer *)recognizer {
    CGPoint pointInView = [recognizer locationInView:self];
    float offset = [self getGestureOffset:pointInView];
    
    [self setSelectedImage:recognizer withOffset:offset];
}

- (float)getGestureOffset:(CGPoint)pointInView {
    float offset = 0.0;
    if ([self.masker.direction isEqualToString:@"left"]) {
        offset = (pointInView.x - ((self.maskPercentage*2-1)*self.frame.size.width)) - pointInView.y;
    } else if ([self.masker.direction isEqualToString:@"right"]) {
        offset = (pointInView.x - ((self.maskPercentage*2)*self.frame.size.width)) + pointInView.y;
    } else if ([self.masker.direction isEqualToString:@"horizontal"]) {
        offset = pointInView.y - self.maskPercentage*self.frame.size.height;
    } else if ([self.masker.direction isEqualToString:@"vertical"]) {
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
    if (!_maskPercentage) _maskPercentage = [self.pose.perc floatValue];
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

@end
