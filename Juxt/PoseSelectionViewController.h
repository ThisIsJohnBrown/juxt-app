//
//  PostTableViewController.h
//  Juxt
//
//  Created by John Brown on 8/2/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PoseSelectionViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;

@end
