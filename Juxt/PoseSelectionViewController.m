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
@property (nonatomic, strong) NSArray *items;
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
    for (Pose *info in fetchedObjects) {
//        NSLog(@"Name: %@", info.name);
//        NSLog(@"Before: %@", info.beforePath);
//        NSLog(@"Perc: %@", info.perc);
        //info.direction = @"right";
    }
    
    self.items = fetchedObjects;
    
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
    [cell initUI];
    
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

@end
