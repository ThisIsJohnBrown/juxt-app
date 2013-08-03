//
//  ViewController.h
//  Juxt
//
//  Created by John Brown on 7/28/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "Pose.h"

@interface SelectionViewController : UIViewController <UIImagePickerControllerDelegate,
UINavigationControllerDelegate>

@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;

@property BOOL newMedia;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewBefore;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewAfter;
@property (weak, nonatomic) IBOutlet UIButton *readyButton;

@property (nonatomic, strong) Pose *pose;

@end
