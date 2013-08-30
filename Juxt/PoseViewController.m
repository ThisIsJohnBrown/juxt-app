//
//  MeldViewController.m
//  Juxt
//
//  Created by John Brown on 7/28/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import "AppDelegate.h"
#import "Base64.h"
#import "constants.h"
#import "PoseViewController.h"
#import "Pose.h"
#import "MaskView.h"
#import <Social/Social.h>
#import <QuartzCore/QuartzCore.h>
#import "Utilities.h"

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

@property (nonatomic, strong) Pose *tempPose;

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
    Utilities *util = [[Utilities alloc] init];
    NSManagedObjectContext *context = self.managedObjectContext;
    NSError *error;
    self.tempPose = [self.meldView savePose];
    NSString *method = @"POST";
    NSString *apiUrl = [NSString stringWithFormat:@"%@/api/v1/pose/", baseURL];
    if (!self.tempPose.createdDate) {
        self.tempPose.createdDate = [[NSDate alloc] init];
        self.tempPose.updatedDate = self.tempPose.createdDate;
    } else {
        self.tempPose.updatedDate = [[NSDate alloc] init];
    }
    self.tempPose.uploaded = [NSNumber numberWithInt:1];
    
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    NSLog(@"%@", self.tempPose);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults objectForKey:@"username"];
    NSString *apiKey = [defaults objectForKey:@"apiKey"];
    
    UIImage *beforeUIImage = [UIImage imageWithContentsOfFile:self.tempPose.beforePath];
    float ratio = 1;
    if ([self.pose.ratio floatValue] == 2) {
        ratio = 4.0/3.0;
    } else if ([self.pose.ratio floatValue] == 3) {
        ratio = 3.0/4.0;
    }
    UIImage *beforeResizedUpload = [util resizeImage:beforeUIImage
                                               width:800
                                              height:800/ratio
                                             offsetX:[self.pose.beforeOffsetX floatValue]
                                             offsetY:[self.pose.beforeOffsetY floatValue]
                                               scale:[self.pose.beforeScale floatValue]];
    NSData *beforeImageData = UIImageJPEGRepresentation(beforeResizedUpload, .7);
    NSString *beforeImageEncoded = [Base64 encode:beforeImageData];
    
    UIImage *afterUIImage = [UIImage imageWithContentsOfFile:self.tempPose.afterPath];
    UIImage *afterResizedUpload = [util resizeImage:afterUIImage
                                              width:800
                                             height:800/ratio
                                            offsetX:[self.pose.afterOffsetX floatValue]
                                            offsetY:[self.pose.afterOffsetY floatValue]
                                              scale:[self.pose.afterScale floatValue]];
    NSData *afterImageData = UIImageJPEGRepresentation(afterResizedUpload, .7);
    NSString *afterImageEncoded = [Base64 encode:afterImageData];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *beforeImagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-b.jpg",self.pose.identifier]];
    if (![beforeImageData writeToFile:beforeImagePath atomically:NO])
    {
        NSLog(@"Failed to cache image data to disk");
    }
    NSString *afterImagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-a.jpg",self.pose.identifier]];
    if (![afterImageData writeToFile:afterImagePath atomically:NO])
    {
        NSLog(@"Failed to cache image data to disk");
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?format=json&username=%@&api_key=%@", apiUrl, username, apiKey]];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@"Another Name1" forKey:@"name"];
    [params setObject:@"Caption Test" forKey:@"caption"];
    [params setObject:self.tempPose.perc forKey:@"swiper_location"];
    [params setObject:@"true" forKey:@"shared"];
    [params setObject:self.tempPose.ratio forKey:@"ratio"];
    [params setObject:self.tempPose.direction forKey:@"split"];
    [params setObject:self.tempPose.identifier forKey:@"identifier"];
    
    [params setObject:self.tempPose.beforeOffsetX forKey:@"before_offset_x"];
    [params setObject:self.tempPose.beforeOffsetY forKey:@"before_offset_y"];
    [params setObject:self.tempPose.beforeScale forKey:@"before_scale"];
    NSMutableDictionary *beforeImage = [[NSMutableDictionary alloc] init];
    [beforeImage setObject:[NSString stringWithFormat:@"%@-b.jpg", self.tempPose.identifier] forKey:@"name"];
    [beforeImage setObject:@"image/png" forKey:@"conten_type"];
    [beforeImage setObject:beforeImageEncoded forKey:@"file"];
    [params setObject:beforeImage forKey:@"before_image"];
    
    [params setObject:self.tempPose.afterOffsetX forKey:@"after_offset_x"];
    [params setObject:self.tempPose.afterOffsetY forKey:@"after_offset_y"];
    [params setObject:self.tempPose.afterScale forKey:@"after_scale"];
    NSMutableDictionary *afterImage = [[NSMutableDictionary alloc] init];
    [afterImage setObject:[NSString stringWithFormat:@"%@-a.jpg", self.tempPose.identifier] forKey:@"name"];
    [afterImage setObject:@"image/png" forKey:@"conten_type"];
    [afterImage setObject:afterImageEncoded forKey:@"file"];
    [params setObject:afterImage forKey:@"after_image"];
    
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&jsonError];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSMutableData *postData=[NSMutableData data];
    [postData appendData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:method];
    NSString *contentType = [NSString stringWithFormat:@"application/json"];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    [request setHTTPBody:postData];
    NSLog(@"Sending data to %@", url);
    NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%@", connection);
    
    // NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // [defaults setObject:@"testing" forKey:@"firstName"];
    // [defaults synchronize];
    // NSLog(@"%@", [defaults objectForKey:@"firstName"]);
    
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        
    }
    
    [self performSegueWithIdentifier:@"pushToCollection" sender:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"Did fail with error %@" , [error localizedDescription]);
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse *httpResponse;
    httpResponse = (NSHTTPURLResponse *)response;
    int statusCode = [httpResponse statusCode];
    NSLog(@"Status code was %d", statusCode);
    NSDictionary *headers = [httpResponse allHeaderFields];
    if ([headers objectForKey:@"Location"]) {
        NSLog(@"/%@", (NSString *)[headers objectForKey:@"Location"]);
//        self.tempPose.uri = [NSString stringWithFormat:@"%@%@", baseURL, [headers objectForKey:@"Location"]];
        self.tempPose.uri = [headers objectForKey:@"Location"];
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData{
    NSLog(@"String sent from server %@",[[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding]);
}

- (IBAction)ratio:(UIButton *)sender {
    [self.meldView changeRatio];
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
    
    CGRect dim = CGRectMake(0, 0, 320, 320);
    if ([self.pose.ratio floatValue] == 2) {
        dim = CGRectMake(0, 40, 320, 240);
    } else if ([self.pose.ratio floatValue] == 3) {
        dim = CGRectMake(40, 0, 240, 320);
    }
    self.meldView = [[MeldView alloc] initWithPose:self.pose inFrame:dim withInteractions:YES];
    [self.view addSubview:self.meldView];
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

@end
