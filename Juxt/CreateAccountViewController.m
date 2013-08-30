//
//  CreatAccountViewController.m
//  Juxt
//
//  Created by John Brown on 8/11/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import "constants.h"
#import "CreateAccountViewController.h"

@interface CreateAccountViewController ()

@end

@implementation CreateAccountViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationController.navigationBar.hidden=YES;
    self.navigationItem.hidesBackButton = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)create:(id)sender {
    int error = 0;
    NSString *emailRegEx =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    
    NSPredicate *emailTest;
    emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailRegEx];

    if (![emailTest evaluateWithObject:self.emailInput.text]) {
        self.emailInput.backgroundColor = [UIColor greenColor];
        error++;
        self.emailError.text = @"Invalid email.";
    } else {
        self.emailInput.backgroundColor = [UIColor clearColor];
        self.emailError.text = @"";
    }
    
    NSString *alphaNumericPattern = @"[a-zA-Z0-9_]*";
    NSPredicate *alphaNumericTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", alphaNumericPattern];
    
    if (![alphaNumericTest evaluateWithObject:self.usernameInput.text]) {
        self.usernameInput.backgroundColor = [UIColor greenColor];
        error++;
        self.usernameError.text = @"Please only use a-z, #s, and _";
    } else if ([self.usernameInput.text length] > 24) {
        self.usernameInput.backgroundColor = [UIColor greenColor];
        error++;
        self.usernameError.text = @"Username too long.";
    } else if ([self.usernameInput.text length] < 2) {
        self.usernameInput.backgroundColor = [UIColor greenColor];
        error++;
        self.usernameError.text = @"Username too short";
    } else {
        self.usernameInput.backgroundColor = [UIColor clearColor];
        self.usernameError.text = @"";
    }
    
    if (![alphaNumericTest evaluateWithObject:self.passwordInput.text]) {
        self.passwordInput.backgroundColor = [UIColor greenColor];
        error++;
        self.passwordError.text = @"Please only use a-z, #s, and _";
    } else if ([self.passwordInput.text length] > 24) {
        self.passwordInput.backgroundColor = [UIColor greenColor];
        error++;
        self.passwordError.text = @"Password too long.";
    } else if ([self.passwordInput.text length] < 8) {
        self.passwordInput.backgroundColor = [UIColor greenColor];
        error++;
        self.passwordError.text = @"Password too short";
    } else {
        self.passwordInput.backgroundColor = [UIColor clearColor];
        self.passwordError.text = @"";
    }

    if ([self.displayInput.text length] > 24) {
        self.displayInput.backgroundColor = [UIColor greenColor];
        error++;
        self.displayError.text = @"Please keep name under 24 characters.";
    } else if ([self.displayInput.text length] < 2) {
        self.displayInput.backgroundColor = [UIColor greenColor];
        self.displayError.text = @"Name too short.";
        error++;
    } else {
        self.displayInput.backgroundColor = [UIColor clearColor];
        self.displayError.text = @"";
    }
    
    if (!error) {
        [self createAccount];
        NSLog(@"GOOD!");
    }
    
}

- (void)createAccount {
    [self dismissKeyboard];
    
    NSString *encodedText = [self encodeToPercentEscapeString:self.displayInput.text];
    NSLog(@"Encoded text: %@", encodedText);
    
    NSString *urlString = [NSString stringWithFormat:@"%@/account/create/?format=json&username=%@&password=%@&email=%@&display=%@", baseURL, self.usernameInput.text, self.passwordInput.text, self.emailInput.text, [self encodeToPercentEscapeString:self.displayInput.text]];
    NSURL *url = [NSURL URLWithString:urlString];
//    NSLog(urlString);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    NSLog(@"connection: %@", [conn debugDescription]);
    if (conn) {
        NSLog(@"Connection succeeded");
    } else {
        NSLog(@"Connection failed");
    }
}

- (NSString *)encodeToPercentEscapeString:(NSString *)string {
    return (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                            (CFStringRef) string,
                                            NULL,
                                            (CFStringRef) @"!*'();:@&=+$,/?%#[]",
                                            kCFStringEncodingUTF8));
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:data //1
                          
                          options:kNilOptions
                          error:&error];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *responseType = [json objectForKey:@"status"];
    if (responseType) {
        if ([responseType isEqualToString:@"success"]) {
            [defaults setObject:self.usernameInput.text forKey:@"username"];
            [defaults setObject:[json objectForKey:@"api-key"] forKey:@"apiKey"];
            [defaults setObject:[NSDate date] forKey:@"lastUpdate"];
            [defaults synchronize];
            self.errorText.text = @"";
            [self performSegueWithIdentifier:@"loginToCollection" sender:self];
        } else {
            id messages = [json objectForKey:@"message"];
            for (NSString *message in messages) {
                if ([message isEqualToString:@"missing"]) {
                    self.errorText.text = @"You were missing some information. Please check fields again.";
                } else if ([message isEqualToString:@"email"]) {
                    self.errorText.text = @"Email already registered.";
                } else if ([message isEqualToString:@"username"]) {
                    self.errorText.text = @"Username already registered.";
                }
            }
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error { NSLog(@"%@", error); }

- (void)dismissKeyboard {
    [self.emailInput resignFirstResponder];
    [self.passwordInput resignFirstResponder];
    [self.usernameInput resignFirstResponder];
    [self.displayInput resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self create:textField];
    [self dismissKeyboard];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dismissKeyboard];
    
}

@end
