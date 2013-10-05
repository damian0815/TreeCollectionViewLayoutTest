//
//  GraphDataStore.h
//  TreeCollectionViewTest
//
//  Created by damian on 04/10/13.
//  Copyright (c) 2013 jack. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Graph;
@interface TreeDataSource : NSObject<UICollectionViewDataSource>

- (id)initWithTree:(Graph*)tree;

- (unsigned int)numNodes;
- (NSString*)labelForNodeWithIndexPath:(NSIndexPath*)indexPath;


@end
