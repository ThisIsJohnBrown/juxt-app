//
//  Pose.h
//  Juxt
//
//  Created by John Brown on 8/11/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Pose : NSManagedObject

@property (nonatomic, retain) NSNumber * afterOffsetX;
@property (nonatomic, retain) NSNumber * afterOffsetY;
@property (nonatomic, retain) NSString * afterPath;
@property (nonatomic, retain) NSNumber * afterScale;
@property (nonatomic, retain) NSNumber * beforeOffsetX;
@property (nonatomic, retain) NSNumber * beforeOffsetY;
@property (nonatomic, retain) NSString * beforePath;
@property (nonatomic, retain) NSNumber * beforeScale;
@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSNumber * direction;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSNumber * perc;
@property (nonatomic, retain) NSNumber * ratio;
@property (nonatomic, retain) NSDate * updatedDate;
@property (nonatomic, retain) NSNumber * uploaded;
@property (nonatomic, retain) NSString * uri;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSNumber * shared;
@property (nonatomic, retain) NSNumber * draft;

@end
