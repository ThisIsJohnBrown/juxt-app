//
//  ViewController.m
//  Juxt
//
//  Created by John Brown on 7/28/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import "Base64.h"
#import "SelectionViewController.h"
#import "PoseViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "Pose.h"
#import "constants.h"
#import "Utilities.h"

@interface SelectionViewController ()
@property (nonatomic) BOOL before;
@property (nonatomic) BOOL newBefore;
@property (nonatomic, strong) NSString *oldBeforePath;
@property (nonatomic) BOOL newAfter;
@property (nonatomic, strong) NSString *oldAfterPath;

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@end

@implementation SelectionViewController

- (Pose *)pose {
    if (!_pose) {
        _pose = [[Pose alloc] init];
    }
    return _pose;
}

- (IBAction)saveSingle:(id)sender {
    NSManagedObjectContext *context = self.managedObjectContext;
    NSError *error;
    self.pose.draft = [NSNumber numberWithInt:1];
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    [self performSegueWithIdentifier:@"saveSingle" sender:self];
}

- (IBAction)delete:(id)sender {
    NSManagedObjectContext *context = self.managedObjectContext;
//    NSError *error;

    if (self.pose.uri) {
        NSString *method = @"PUT";
        NSString *apiUrl = self.pose.uri;
    
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *username = [defaults objectForKey:@"username"];
        NSString *apiKey = [defaults objectForKey:@"apiKey"];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?format=json&username=%@&api_key=%@", apiUrl, username, apiKey]];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:@"true" forKey:@"deleted"];
        [params setObject:@"false" forKey:@"shared"];
        
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
        NSLog(@"%@", jsonString);
        NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
        NSLog(@"%@", connection);
    }
    
    
//    self.pose.draft = 0;
//    self.pose.createdDate = nil;
    [context deleteObject:self.pose];
//    [context processPendingChanges];
//    if (![context save:&error]) {
//        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
//    } else {
////        [self performSegueWithIdentifier:@"deletePose" sender:self];
//    }
    //[self performSegueWithIdentifier:@"deletePose" sender:self];
}

- (IBAction)useCameraRollBefore:(id)sender {
    self.before = YES;
    [self useCameraRoll];
}

- (IBAction)useCameraRollAfter:(id)sender {
    self.before = NO;
    [self useCameraRoll];
}


- (void)viewDidLoad {
//    NSManagedObject *newPose = [NSEntityDescription insertNewObjectForEntityForName:@"Pose" inManagedObjectContext:self.context];
//    [newPose setValue:@"a" forKey:@"before"];
//    [newPose setValue:@"1" forKey:@"after"];
//    
//    NSError *error = nil;
//    [self.context save:&error];
//    
//    NSLog(@"%@ -- %@", error, [error localizedDescription]);
    
    if (self.pose.beforePath) {
        self.imageViewBefore.image = [UIImage imageWithContentsOfFile:self.pose.beforePath];
        [self.imageViewBefore setHidden:NO];
    } if (self.pose.afterPath) {
        self.imageViewAfter.image = [UIImage imageWithContentsOfFile:self.pose.afterPath];
        [self.imageViewAfter setHidden:NO];
    }
    
    if (self.pose.beforePath && self.pose.afterPath) {
        [self.readyButton setHidden:NO];
    }
    if (self.pose.uri) {
        [self.deleteButton setHidden:NO];
    }
    
    UITapGestureRecognizer *beforeImageTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(beforeImageTap:)];
    [self.imageViewBefore addGestureRecognizer:beforeImageTapRecognizer];
    
    UITapGestureRecognizer *afterImageTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(afterImageTap:)];
    [self.imageViewAfter addGestureRecognizer:afterImageTapRecognizer];
    
//    [TestFlight passCheckpoint:@"SELECTION"];
    
    self.navigationItem.hidesBackButton = YES;
    
    self.oldBeforePath = self.pose.beforePath;
    self.oldAfterPath = self.pose.afterPath;
}

- (void)beforeImageTap:(UITapGestureRecognizer *)recognizer {
    self.before = YES;
    [self useCameraRoll];
}

- (void)afterImageTap:(UITapGestureRecognizer *)recognizer {
    self.before = NO;
    [self useCameraRoll];
}

- (void)useCameraRoll {
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker
                           animated:YES completion:nil];
        _newMedia = NO;
    }
}



#pragma mark -
#pragma mark UIImagePickerControllerDelegate

- (IBAction)useCamera:(id)sender {
    self.imagePicker = [[UIImagePickerController alloc] init];
#if TARGET_IPHONE_SIMULATOR
    self.imagePicker = UIImagePickerControllerSourceTypePhotoLibrary;
#else
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
#endif
    self.imagePicker.editing = NO;
    self.imagePicker.delegate = (id)self;
    UIView *border = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    border.backgroundColor = [UIColor redColor];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(takePhoto:)];
    [border addGestureRecognizer:tapRecognizer];
    
    [self.imagePicker setCameraOverlayView:border];
    self.imagePicker.showsCameraControls = NO;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

- (void)atkePhoto:(UITapGestureRecognizer *)recognizer {
    NSLog(@"Asdf");
    [self.imagePicker takePicture];
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        Utilities *util = [[Utilities alloc] init];
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        
        NSData *imageData = UIImageJPEGRepresentation(image, .7);
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@.jpg",self.pose.identifier, self.before ? @"b" : @"a"]];
        
//        NSLog((@"pre writing to file"));
        if (![imageData writeToFile:imagePath atomically:NO])
        {
            NSLog(@"Failed to cache image data to disk");
        }
        else
        {
//            NSLog(@"the cachedImagedPath is %@",imagePath); 
        }
        
        
        
        if (self.before) {
            self.imageViewBefore.image = [util resizeImage:image width:320 height:240 offsetX:0 offsetY:0 scale:1];
//            self.imageViewBefore.image = image;
            self.pose.beforePath = imagePath;
            self.pose.beforeOffsetY = 0;
            self.pose.beforeOffsetY = 0;
            self.pose.beforeScale = [NSNumber numberWithInt:1];
            self.newBefore = YES;
            [self.imageViewBefore setHidden:NO];
        } else {
            self.imageViewAfter.image = [util resizeImage:image width:320 height:240 offsetX:0 offsetY:0 scale:1];
            self.pose.afterPath = imagePath;
            [self.imageViewAfter setHidden:NO];
            self.pose.afterOffsetY = 0;
            self.pose.afterOffsetY = 0;
            self.pose.afterScale = [NSNumber numberWithInt:1];
            self.newAfter = YES;
        }
        [self.saveButton setHidden:NO];
        if (self.imageViewBefore.image && self.imageViewAfter.image) {
            self.readyButton.hidden = NO;
        }
        if (_newMedia)
            UIImageWriteToSavedPhotosAlbum(image,
                                           self,
                                           @selector(image:finishedSavingWithError:contextInfo:),
                                           nil);
    }
}

-(void)image:(UIImage *)image
finishedSavingWithError:(NSError *)error
 contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)uploadImages {
    NSString *method = @"POST";
    NSString *apiUrl = [NSString stringWithFormat:@"%@/api/v1/pose/", baseURL];
    if (!self.pose.uri) {
        
    } else {
        method = @"PUT";
        apiUrl = self.pose.uri;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults objectForKey:@"username"];
    NSString *apiKey = [defaults objectForKey:@"apiKey"];
    
    NSData *beforeImageData = UIImageJPEGRepresentation([UIImage imageWithContentsOfFile:self.pose.beforePath], .7);
    NSString *beforeImageEncoded = [Base64 encode:beforeImageData];
    NSData *afterImageData = UIImageJPEGRepresentation([UIImage imageWithContentsOfFile:self.pose.afterPath], .7);
    NSString *afterImageEncoded = [Base64 encode:afterImageData];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?format=json&username=%@&api_key=%@", apiUrl, username, apiKey]];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@"Another Name1" forKey:@"name"];
    [params setObject:@"Caption Test" forKey:@"caption"];
    [params setObject:self.pose.identifier forKey:@"identifier"];
    
    NSMutableDictionary *beforeImage = [[NSMutableDictionary alloc] init];
    [beforeImage setObject:[NSString stringWithFormat:@"%@-b.jpg", self.pose.identifier] forKey:@"name"];
    [beforeImage setObject:@"image/png" forKey:@"conten_type"];
    [beforeImage setObject:beforeImageEncoded forKey:@"file"];
    [params setObject:beforeImage forKey:@"before_image"];
    
    NSMutableDictionary *afterImage = [[NSMutableDictionary alloc] init];
    [afterImage setObject:[NSString stringWithFormat:@"%@-a.jpg", self.pose.identifier] forKey:@"name"];
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
    if ([headers objectForKey:@"Location"] && self.pose) {
        NSLog(@"/%@", (NSString *)[headers objectForKey:@"Location"]);
        //        self.tempPose.uri = [NSString stringWithFormat:@"%@%@", baseURL, [headers objectForKey:@"Location"]];
        self.pose.uri = [headers objectForKey:@"Location"];
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData{
    NSLog(@"String sent from server %@",[[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding]);
    NSError *error;
    NSDictionary *json =
    [NSJSONSerialization JSONObjectWithData: [[[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding]
                                    options: NSJSONReadingMutableContainers
                                      error: &error];
    if ([[json objectForKey:@"pose"] objectForKey:@"identifier"]) {
        self.pose.identifier = [[[Utilities alloc] init] genRandStringLength:identLength];
        //[self uploadImages];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"segueToMeld"]) {
        PoseViewController *nextVC = (PoseViewController *)[segue destinationViewController];
        nextVC.pose = self.pose;
        nextVC.managedObjectContext = self.managedObjectContext;
//        [self uploadImages];
        
        
    } else if ([[segue identifier] isEqualToString:@"cancelToCollection"]) {
        self.pose.afterPath = self.oldAfterPath;
        self.pose.beforePath = self.oldBeforePath;
        if (!self.oldBeforePath && !self.oldAfterPath) {
            [self.managedObjectContext deleteObject:self.pose];
        }
    }
}

@end
