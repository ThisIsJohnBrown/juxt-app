//
//  ViewController.m
//  Juxt
//
//  Created by John Brown on 7/28/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import "SelectionViewController.h"
#import "PoseViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "Pose.h"

@interface SelectionViewController ()
@property (nonatomic) BOOL *before;
@end

@implementation SelectionViewController

- (Pose *)pose {
    if (!_pose) {
        _pose = [[Pose alloc] init];
    }
    return _pose;
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
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.imageViewBefore addGestureRecognizer:tapRecognizer];
}

- (void)tap:(UITapGestureRecognizer *)recognizer {
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

-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        
        NSData *imageData = UIImagePNGRepresentation(image);
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@.png",self.pose.identifier, self.before ? @"b" : @"a"]];
        
        NSLog((@"pre writing to file"));
        if (![imageData writeToFile:imagePath atomically:NO])
        {
            NSLog(@"Failed to cache image data to disk");
        }
        else
        {
            NSLog(@"the cachedImagedPath is %@",imagePath); 
        }
        
        if (self.before) {
            self.imageViewBefore.image = image;
            self.pose.beforePath = imagePath;
            [self.imageViewBefore setHidden:NO];
        } else {
            self.imageViewAfter.image = image;
            self.pose.afterPath = imagePath;
            [self.imageViewAfter setHidden:NO];
        }
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

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"segueToMeld"]) {
        PoseViewController *nextVC = (PoseViewController *)[segue destinationViewController];
        nextVC.pose = self.pose;
        nextVC.managedObjectContext = self.managedObjectContext;
    } else if ([[segue identifier] isEqualToString:@"backToTable"]) {
        if (!self.pose.createdDate) {
            self.pose.afterPath = nil;
            self.pose.beforePath = nil;
        }
    }
}

@end
