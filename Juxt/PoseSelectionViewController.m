//
//  PostTableViewController.m
//  Juxt
//
//  Created by John Brown on 8/2/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#include "AppDelegate.h"
#import "PoseSelectionViewController.h"
#import "PoseTableCell.h"
#import "SelectionViewController.h"
#import <Social/Social.h>

@interface PoseSelectionViewController ()
@property (nonatomic, strong) NSMutableArray *items;
@end

@implementation PoseSelectionViewController

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
    
    AppDelegate *delegate = (AppDelegate*)
    [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = delegate.managedObjectContext;
    
    NSManagedObjectContext *context = self.managedObjectContext;
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Pose"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    self.items = [fetchedObjects mutableCopy];
    Pose *final = [self.items lastObject];
    if (!final || final.beforePath) {
        Pose *pose = [NSEntityDescription insertNewObjectForEntityForName:@"Pose" inManagedObjectContext:context];
        pose.identifier = [self genRandStringLength:8];
        [self.items addObject:pose];
    }
    
}

NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

-(NSString *) genRandStringLength: (int) len {
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    
    return randomString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *simpleTableIdentifier = @"PoseCell";
    
    PoseTableCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        NSLog(@"asfsafd");
        cell = [[PoseTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    Pose *pose = [self.items objectAtIndex:indexPath.row];
    cell.pose = pose;
    [cell initUI:YES];
    
    return cell;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
    }
}

//-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSLog(@"%i", indexPath.row);
//}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // unwrap the controller if it's embedded in the nav controller.
    UIViewController *controller;
    if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        controller = [navController.viewControllers objectAtIndex:0];
    } else {
        controller = segue.destinationViewController;
    }
    
    if ([controller isKindOfClass:[SelectionViewController class]]) {
        SelectionViewController *vc = (SelectionViewController *)controller;
        NSIndexPath *ip = [self.tableView indexPathForSelectedRow];
        [vc setPose:[self.items objectAtIndex:ip.row]];
        [vc setManagedObjectContext: self.managedObjectContext];
        
    } else {
        NSAssert(NO, @"Unknown segue. All segues must be handled.");
    }
}

- (CGFloat)tableView:(UITableView *)t heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Pose *pose = [self.items objectAtIndex:indexPath.row];
    return [pose.beforePath length] ? 320 : 104;
}

@end
