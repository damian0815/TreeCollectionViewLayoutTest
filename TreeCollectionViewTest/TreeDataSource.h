//
//  GraphDataStore.h
//  TreeCollectionViewTest
//
//  Created by damian on 04/10/13.
//  Copyright (c) 2013 jack. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Graph;
@class GraphNode;
@interface TreeDataSource : NSObject<UICollectionViewDataSource>

- (id)initWithTree:(Graph*)tree;

- (unsigned int)numNodes;
- (GraphNode*)nodeForIndexPath:(NSIndexPath*)indexPath;
- (NSString*)labelForNodeWithIndexPath:(NSIndexPath*)indexPath;


@end
