//
//  MeldViewController.m
//  Juxt
//
//  Created by John Brown on 7/28/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import "AppDelegate.h"
#import "PoseViewController.h"
#import "Pose.h"
#import "MaskView.h"
#import <Social/Social.h>

@interface PoseViewController ()

@property (nonatomic) CGPoint slideStart;
@property (nonatomic, strong) MaskView *masker;
@property (nonatomic, strong) UIImageView *imageViewBefore;
@property (nonatomic, strong) UIImageView *imageViewAfter;
@property (nonatomic) float maximumZoomScaleBefore;
@property (nonatomic) float mininumZoomScaleBefore;

@property (nonatomic, strong) UIView *meldOverlayView;
@property (nonatomic, strong) UIImageView *selectedImage;
@property (nonatomic) float maskPercentage;

@property (nonatomic, strong) UIView *beforeHolderView;
@property (nonatomic, strong) UIImageView *beforeImageView;

@property (nonatomic, strong) UIView *afterHolderView;
@property (nonatomic, strong) UIImageView *afterImageView;

//@property(nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;

@end

@implementation PoseViewController

- (IBAction)sliderMoved:(UISlider *)sender {
    [self.meldView afterOpacity:[sender value]];
}

- (IBAction)switchImages:(UIButton *)sender {
    [self.meldView switchImages];
}

- (IBAction)changeDirection:(UIButton *)sender {
    [self.meldView nextDirection];
}

- (IBAction)save:(UIButton *)sender {
    NSManagedObjectContext *context = self.managedObjectContext;
    NSError *error;
    [self.meldView savePose];
    
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

- (IBAction)tweetTapped:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:@"Tweeting from my own app! :)"];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.meldView = [[MeldView alloc] initWithPose:self.pose inFrame:CGRectMake(0, 0, 320, 320) withInteractions:YES];
    [self.view addSubview:self.meldView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

@end
