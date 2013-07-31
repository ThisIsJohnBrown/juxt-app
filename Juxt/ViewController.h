//
//  ViewController.h
//  Juxt
//
//  Created by John Brown on 7/28/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ViewController : UIViewController <UIImagePickerControllerDelegate,
UINavigationControllerDelegate>

@property BOOL newMedia;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewBefore;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewAfter;
@property (weak, nonatomic) IBOutlet UIButton *readyButton;

- (void) useCameraRollButton:(id)sender;

@property (nonatomic, retain) NSManagedObjectContext *context;

@end
