//
//  CollectionViewController.m
//  Juxt
//
//  Created by John Brown on 8/5/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import "AMBlurView.h"
#include "AppDelegate.h"
#import "CollectionCell.h"
#import "CollectionViewController.h"
#import "constants.h"
#import "CustomCollectionLayout.h"
#import "Pose.h"
#import "SelectionViewController.h"
#import "Utilities.h"

@interface CollectionViewController ()
@property (nonatomic) int num;

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (nonatomic) int currentLayout;

@property (nonatomic, strong) NSMutableArray *items;

@property (nonatomic, strong) UIView *blurHolder;

@end

@implementation CollectionViewController

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
    self.num = 24;
    self.currentLayout = 2;
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    [self.view addGestureRecognizer:pinchGesture];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    // Configure layout
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [self changeFlowLayout];
    self.flowLayout.minimumInteritemSpacing = 0.0f;
    [self.collectionView setCollectionViewLayout:self.flowLayout];
    
    AppDelegate *delegate = (AppDelegate*)
    [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = delegate.managedObjectContext;
    
    NSManagedObjectContext *context = self.managedObjectContext;
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Pose"
                                              inManagedObjectContext:context];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"updatedDate" ascending:NO]];
    [fetchRequest setEntity:entity];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"username == %@", [defaults objectForKey:@"username"]];
    [fetchRequest setPredicate:pred];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
//    NSMutableArray *itemsTemp = [fetchedObjects mutableCopy];
    self.items = [fetchedObjects mutableCopy];
//    for (int i = 0; i < itemsTemp.count; i++) {
//        Pose *pose = itemsTemp[i];
//        if (!pose.createdDate && [pose.draft intValue] == 0) {
//            [self.items removeObject:pose];
////            [context deleteObject:pose];
//        }
//    }
//    [context save:&error];
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBar.hidden=NO;
}

- (UIEdgeInsets)collectionView: (UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)pinch:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.state == (long)UIGestureRecognizerStateBegan) {
        BOOL changed = YES;
        if (recognizer.scale > 1) {
            ++self.currentLayout;
            if (self.currentLayout > 2) {
                self.currentLayout = 2;
                changed = NO;
            }
        } else {
            --self.currentLayout;
            if (self.currentLayout < 0) {
                self.currentLayout = 0;
                changed = NO;
            }
        }
        if (changed) {
            self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
            //[self changeFlowLayout];
            //[self.collectionView setCollectionViewLayout:self.flowLayout animated:YES];
            
            NSArray *cells = [self.collectionView visibleCells];
            for (CollectionCell *cell in cells) {
                //[cell changeViewSize:self.currentLayout];
            }
        }
    }
}

- (void)changeFlowLayout {
    if (self.currentLayout == 0) {
        [self.flowLayout setItemSize:CGSizeMake(78.5, 118.5)];
        self.flowLayout.minimumInteritemSpacing = 2;
        self.flowLayout.minimumLineSpacing = 2;
    } else if (self.currentLayout == 1) {
        [self.flowLayout setItemSize:CGSizeMake(159, 159)];
        self.flowLayout.minimumInteritemSpacing = 2;
        self.flowLayout.minimumLineSpacing = 2;
    } else if (self.currentLayout == 2) {
        [self.flowLayout setItemSize:CGSizeMake(320, 320)];
        self.flowLayout.minimumInteritemSpacing = 0;
        self.flowLayout.minimumLineSpacing = 0;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.items count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    Pose *pose = [self.items objectAtIndex:indexPath.row];
    cell.pose = pose;
    [cell updateUI];
    
    //cell.label.text = [NSString stringWithFormat:@"%d",indexPath.item];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    Pose *pose = [self.items objectAtIndex:indexPath.row];
    int div = 4;
    int offset = 2;
    if (self.currentLayout == 1) {
        div = 2;
    } else if (self.currentLayout == 2) {
        div = 1;
        offset = 0;
    }
    
    self.currentLayout = 2;
    if ([pose.ratio intValue] == 1) {
        return CGSizeMake(320/div - offset, 320/div);
    } else if ([pose.ratio intValue] == 2) {
        return CGSizeMake(320/div - offset, 240/div);
    } else if ([pose.ratio intValue] == 3) {
        return CGSizeMake(320/div - offset, 427/div);
    }
    return CGSizeMake(320/div - offset, 320/div);
}

- (void)showInfo:(CollectionCell *)sender {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:indexPath.row animated:YES];
    
//    self.blurHolder = [UIView new];
//    [self.blurHolder setFrame:CGRectMake(0.0f,0.0f,320.0f,320.0f)];
//    AMBlurView *blurView = [AMBlurView new];
//    [blurView setFrame:CGRectMake(0.0f,0.0f,320.0f,320.0f)];
//    [blurView setBlurTintColor:[UIColor whiteColor]];
//    [self.blurHolder setAlpha:0.0f];
//    [self.blurHolder addSubview:blurView];
//    [self.view addSubview:self.blurHolder];
//    self.blurHolder.clipsToBounds = YES;
//    
//    [UIView animateWithDuration:0.5f
//                     animations:^{
//                         [self.blurHolder setAlpha:1.0f];
//                     }
//     ];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([sender isKindOfClass:[CollectionCell class]]) {
        NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
        NSIndexPath *index = [indexPaths objectAtIndex:0];
        Pose *pose = [self.items objectAtIndex:index.row];
        if (pose.createdDate) {
            [self showInfo:(CollectionCell *)sender];
            return NO;
        }
    }
    return YES;
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // unwrap the controller if it's embedded in the nav controller.
    UIViewController *controller;
    if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        NSLog(@"----%@", navController.viewControllers);
        controller = [navController.viewControllers objectAtIndex:0];
    } else {
        controller = segue.destinationViewController;
    }
    if ([segue.identifier isEqualToString:@"addPose"]) {
        SelectionViewController *vc = (SelectionViewController *)controller;
        Pose *pose = [NSEntityDescription insertNewObjectForEntityForName:@"Pose" inManagedObjectContext:self.managedObjectContext];
        pose.identifier = [[[Utilities alloc] init] genRandStringLength:identLength];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        pose.username = [defaults objectForKey:@"username"];
        [vc setPose:pose];
        [vc setManagedObjectContext: self.managedObjectContext];
    } else if ([segue.identifier isEqualToString:@"editPose"]) {
        SelectionViewController *vc = (SelectionViewController *)controller;
        NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
        NSIndexPath *index = [indexPaths objectAtIndex:0];
        [vc setPose:[self.items objectAtIndex:index.row]];
        [vc setManagedObjectContext: self.managedObjectContext];
        
    } else if ([segue.identifier isEqualToString:@"logout"]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"" forKey:@"username"];
        [defaults setObject:@"" forKey:@"apiKey"];
        [defaults synchronize];
        
    } else {
        //NSAssert(NO, @"Unknown segue. All segues must be handled.");
    }
}
- (IBAction)addPose:(id)sender {
    [self performSegueWithIdentifier:@"addPose" sender:self];
}

@end
