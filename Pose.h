//
//  Pose.h
//  Juxt
//
//  Created by John Brown on 8/2/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Pose : NSManagedObject

@property (nonatomic, retain) NSString * direction;
@property (nonatomic, retain) NSString * beforePath;
@property (nonatomic, retain) NSString * afterPath;
@property (nonatomic, retain) NSNumber * perc;
@property (nonatomic, retain) NSString * name;

@end
