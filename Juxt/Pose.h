//
//  Pose.h
//  Juxt
//
//  Created by John Brown on 8/3/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Pose : NSManagedObject

@property (nonatomic, retain) NSString * direction;
@property (nonatomic, retain) NSString * beforePath;
@property (nonatomic, retain) NSString * afterPath;
@property (nonatomic, retain) NSNumber * perc;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSDate * updatedDate;
@property (nonatomic, retain) NSNumber * uploaded;
@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) NSNumber * beforeScale;
@property (nonatomic, retain) NSNumber * beforeOffsetX;
@property (nonatomic, retain) NSNumber * beforeOffsetY;
@property (nonatomic, retain) NSNumber * afterOffsetX;
@property (nonatomic, retain) NSNumber * afterOffsetY;
@property (nonatomic, retain) NSNumber * afterScale;

@end
