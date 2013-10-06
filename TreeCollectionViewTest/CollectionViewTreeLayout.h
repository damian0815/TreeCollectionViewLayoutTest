//
//  CollectionViewTreeLayout.h
//  TreeCollectionViewTest
//
//  Created by damian on 04/10/13.
//  Copyright (c) 2013 jack. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ForceDirectedGraphArranger.h"

@class TreeDataSource;
@class Graph;

@interface CollectionViewTreeLayout : UICollectionViewLayout

@property (strong,readwrite,nonatomic) Graph* tree;
@property (strong,readwrite,nonatomic) TreeDataSource* dataSource;

@property (readonly,atomic) ForceDirectedGraphArranger* arranger;


@end
