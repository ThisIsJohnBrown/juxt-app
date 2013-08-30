//
//  CollectionCell.h
//  Juxt
//
//  Created by John Brown on 8/7/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pose.h"

@interface CollectionCell : UICollectionViewCell
@property (nonatomic, strong) Pose *pose;

-(void) changeViewSize:(int) newSize;
-(void) updateUI;

@end
