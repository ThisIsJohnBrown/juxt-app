//
//  StartupViewController.m
//  Juxt
//
//  Created by John Brown on 8/10/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import "AMBlurView.h"
#import "AppDelegate.h"
#import "constants.h"
#import "DRNRealTimeBlurView.h"
#import <Pinterest/Pinterest.h>
#import "Pose.h"
#import "StartupViewController.h"

@interface StartupViewController ()

@end

@implementation StartupViewController

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
    self.navigationItem.hidesBackButton = YES;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults objectForKey:@"username"];
    NSString *apiKey = [defaults objectForKey:@"apiKey"];
    NSLog(@"%@, %@", username, apiKey);
    if ([username length] && [apiKey length]) {
        [self performSegueWithIdentifier:@"pushToCollection" sender:self];
    }
    
    self.navigationController.navigationBar.hidden=YES;
    
    //Creates a live blur view
    
    UIButton* pinItButton = [Pinterest pinItButton];
    [pinItButton addTarget:self
                    action:@selector(pinIt:)
          forControlEvents:UIControlEventTouchUpInside];
    //[self.view addSubview:pinItButton];
}

- (void)pinIt:(id)sender
{
    Pinterest *p = [[Pinterest alloc] initWithClientId:@"1432886" urlSchemeSuffix:@"pin1432886"];
    NSLog(@"%c", [p canPinWithSDK]);
    NSLog(@"asf");
    NSURL *imageURL     = [NSURL URLWithString:@"http://placekitten.com/500/400"];
    NSURL *sourceURL    = [NSURL URLWithString:@"http://placekitten.com"];
    
    
    [p createPinWithImageURL:imageURL
                           sourceURL:sourceURL
                         description:@"Pinning from Pin It Demo"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender {
    [self loginAction];
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSString *username = [defaults objectForKey:@"username"];
//    NSString *apiKey = [defaults objectForKey:@"apiKey"];
}

- (void)loginAction {
    [self.username resignFirstResponder];
    [self.password resignFirstResponder];
    
    NSLog(@"%@, %@", self.username.text, self.password.text);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/account/login/?format=json&username=%@&password=%@", baseURL, self.username.text, self.password.text]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%@", connection);
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
            [defaults setObject:self.username.text forKey:@"username"];
            [defaults setObject:[json objectForKey:@"api-key"] forKey:@"apiKey"];
            [defaults setObject:[NSDate date] forKey:@"lastUpdate"];
            //NSLog(@"%@, %@", self.username.text, [json objectForKey:@"api-key"]);
            [defaults synchronize];
            self.errorLabel.text = @"";
            [self getUserPoses];
            //[self performSegueWithIdentifier:@"pushToCollection" sender:self];
        } else {
            id messages = [json objectForKey:@"message"];
            for (NSString *message in messages) {
                if ([message isEqualToString:@"wrong password"]) {
                    self.errorLabel.text = @"Wrong username/password";
                } else if ([message isEqualToString:@"username"]) {
                    self.errorLabel.text = @"Username doesn't exist";
                }
            }
        }
    } else {
        NSArray *poses = [json objectForKey:@"objects"];
        AppDelegate *delegate = (AppDelegate*)
        [[UIApplication sharedApplication] delegate];
        self.managedObjectContext = delegate.managedObjectContext;
        
        NSError *error;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Pose"
                                                  inManagedObjectContext:self.managedObjectContext];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"updatedDate" ascending:NO]];
        [fetchRequest setEntity:entity];
        NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSS"];
//        NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
//        [formatter setTimeZone:gmt];
        
        for (NSData *poseData in poses) {
            
            NSString *ident = [poseData valueForKey:@"identifier"];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"identifier MATCHES '%@'", ident]];
            NSArray *results = [fetchedObjects filteredArrayUsingPredicate:predicate];
            
            NSLog(@"PREDICATE SEARCH: %lu", (unsigned long)[results count]);
            
            if (!(unsigned long)[results count]) {
                Pose *pose = (Pose *)[NSEntityDescription insertNewObjectForEntityForName:@"Pose" inManagedObjectContext:self.managedObjectContext];
                [self pose:pose withInfo:poseData];
            } else {
//                NSLog(@"EXISTS!");
                Pose *poseResult = [results objectAtIndex:0];
                NSDate *updatedDate = [formatter dateFromString:(NSString *)[poseData valueForKey:@"updated_date"]];
                NSDate *lastUpdate = poseResult.updatedDate;
                NSComparisonResult result = [updatedDate compare:lastUpdate];
                if(result==NSOrderedDescending) {
                    NSLog(@"UPDATE!!");
                    NSFetchRequest *fetchRequest2 = [[NSFetchRequest alloc] init];
                    NSPredicate *pred = [NSPredicate predicateWithFormat:@"identifier == %@", poseResult.identifier];
                    [fetchRequest2 setPredicate:pred];
                    [fetchRequest2 setEntity:entity];
                    NSError *error2;
                    NSArray *fetchedObjects2 = [self.managedObjectContext executeFetchRequest:fetchRequest2 error:&error2];
                    Pose *retrievedPose = [fetchedObjects2 objectAtIndex:0];
                    retrievedPose.updatedDate = [NSDate date];
                    [self pose:retrievedPose withInfo:poseData];
                }
            }
        }
        
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
        [self performSegueWithIdentifier:@"pushToCollection" sender:self];
    }
//    NSLog(@"loans: %@", ); //3
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self loginAction];
    [self.username resignFirstResponder];
    [self.password resignFirstResponder];
    return YES;
}

- (void)pose:(Pose *)pose withInfo:(NSData *)poseData {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSS"];
    
    pose.identifier = (NSString *)[poseData valueForKey:@"identifier"];
    pose.name = (NSString *)[poseData valueForKey:@"name"];
    pose.caption = (NSString *)[poseData valueForKey:@"caption"];
    
    pose.beforeOffsetX = (NSNumber *)[poseData valueForKey:@"before_offset_x"];
    pose.beforeOffsetY = (NSNumber *)[poseData valueForKey:@"before_offset_y"];
    pose.beforeScale = (NSNumber *)[poseData valueForKey:@"before_scale"];
    pose.afterOffsetX = (NSNumber *)[poseData valueForKey:@"after_offset_x"];
    pose.afterOffsetY = (NSNumber *)[poseData valueForKey:@"after_offset_y"];
    pose.afterScale = (NSNumber *)[poseData valueForKey:@"after_scale"];
    
    pose.uri = [NSString stringWithFormat:@"%@%@", baseURL, (NSString *)[poseData valueForKey:@"resource_uri"]];
    pose.shared = (NSNumber *)[poseData valueForKey:@"shared"];
    pose.perc = (NSNumber *)[poseData valueForKey:@"swiper_location"];
    pose.ratio = (NSNumber *)[poseData valueForKey:@"ratio"];
    pose.direction = (NSNumber *)[poseData valueForKey:@"split"];
    
    NSDate *updatedDate = [formatter dateFromString:(NSString *)[poseData valueForKey:@"updated_date"]];
    NSDate *uploadedDate = [formatter dateFromString:(NSString *)[poseData valueForKey:@"uploaded_date"]];
    
    pose.createdDate = uploadedDate;
    pose.updatedDate = updatedDate;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSURL *beforeImageUrl =[NSURL URLWithString:(NSString *) [poseData valueForKey:@"before_image"]];
    NSData* beforeData = [NSData dataWithContentsOfURL: beforeImageUrl];
    NSString *beforeFilePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat: @"%@-b.png", pose.identifier]];
    [beforeData writeToFile:beforeFilePath atomically:YES];
    pose.beforePath = beforeFilePath;
    
    NSURL *afterImageUrl =[NSURL URLWithString:(NSString *) [poseData valueForKey:@"after_image"]];
    NSData* afterData = [NSData dataWithContentsOfURL: afterImageUrl];
    NSString *afterFilePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat: @"%@-a.png", pose.identifier]];
    [afterData writeToFile:afterFilePath atomically:YES];
    pose.afterPath = afterFilePath;
}

-(void)getUserPoses {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/v1/pose/?format=json&username=%@&api_key=%@", baseURL, [defaults objectForKey:@"username"], [defaults objectForKey:@"apiKey"]]];
    NSLog(@"%@", url);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%@", connection);
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse *httpResponse;
    httpResponse = (NSHTTPURLResponse *)response;
    int statusCode = [httpResponse statusCode];
    NSLog(@"Status code was %d", statusCode);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.username resignFirstResponder];
    [self.password resignFirstResponder];
}

@end
