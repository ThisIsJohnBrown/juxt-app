//
//  ViewController.m
//  Juxt
//
//  Created by John Brown on 7/28/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import "ViewController.h"
#import "PoseViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "AppDelegate.h"
#import <CoreData/CoreData.h>

@interface ViewController ()
@property (nonatomic) BOOL *before;
@end

@implementation ViewController

- (IBAction)useCameraRollBefore:(id)sender {
    self.before = YES;
    [self useCameraRoll];
}

- (IBAction)useCameraRollAfter:(id)sender {
    self.before = NO;
    [self useCameraRoll];
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (NSManagedObjectContext *)context {
    if (!_context) {
        _context = [self managedObjectContext];
    }
    return _context;
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
    
    NSLog(@"%@", mediaType);
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        
        if (self.before) {
            self.imageViewBefore.image = image;
            [self.imageViewBefore setHidden:NO];
        } else {
            self.imageViewAfter.image = image;
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

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([[segue identifier] isEqualToString:@"segueToMeld"]) {
//        PoseViewController *nextVC = (PoseViewController *)[segue destinationViewController];
//        nextVC.before = self.imageViewBefore.image;
//        nextVC.after = self.imageViewAfter.image;
//    }
//}

@end
