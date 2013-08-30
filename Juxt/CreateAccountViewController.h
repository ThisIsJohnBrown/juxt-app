//
//  CreatAccountViewController.h
//  Juxt
//
//  Created by John Brown on 8/11/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateAccountViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *createButton;
@property (strong, nonatomic) IBOutlet UITextField *usernameInput;
@property (strong, nonatomic) IBOutlet UITextField *emailInput;
@property (strong, nonatomic) IBOutlet UITextField *displayInput;
@property (strong, nonatomic) IBOutlet UITextField *passwordInput;

@property (strong, nonatomic) IBOutlet UILabel *usernameError;
@property (strong, nonatomic) IBOutlet UILabel *emailError;
@property (strong, nonatomic) IBOutlet UILabel *displayError;
@property (strong, nonatomic) IBOutlet UILabel *passwordError;

@property (strong, nonatomic) IBOutlet UILabel *errorText;

- (IBAction)create:(id)sender;
@end
