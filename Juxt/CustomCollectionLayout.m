//
//  CustomCollectionLayout.m
//  Juxt
//
//  Created by John Brown on 8/6/13.
//  Copyright (c) 2013 John Brown. All rights reserved.
//

#import "CustomCollectionLayout.h"

@implementation CustomCollectionLayout

- (CGSize)collectionViewContentSize {
    return CGSizeMake(250, 200);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray *newAttributes = [NSMutableArray arrayWithCapacity:attributes.count];
    for (UICollectionViewLayoutAttributes *attribute in attributes) {
        if ((attribute.frame.origin.x + attribute.frame.size.width <= self.collectionViewContentSize.width) &&
            (attribute.frame.origin.y + attribute.frame.size.height <= self.collectionViewContentSize.height)) {
            [newAttributes addObject:attribute];
        }
    }
    return newAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [[UICollectionViewLayoutAttributes alloc] init];
    attributes.alpha = 1.0;
    
    //CGSize size = [self collectionView].frame.size;
    //attributes.center = CGPointMake(size.width / 2.0, size.height / 2.0);
    return attributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

@end
