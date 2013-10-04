//
//  CollectionViewTreeLayout.h
//  TreeCollectionViewTest
//
//  Created by damian on 04/10/13.
//  Copyright (c) 2013 jack. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Graph;

@interface CollectionViewTreeLayout : UICollectionViewLayout

@property (strong,readwrite,atomic) Graph* tree;

@end
