//
//  TreeCellView.h
//  TreeCollectionViewTest
//
//  Created by damian on 04/10/13.
//  Copyright (c) 2013 jack. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TREE_CELL_VIEW_REUSE_IDENTIFIER @"TreeCellView"

@class GraphNode;
@interface TreeCellView : UICollectionViewCell

- (void)setNode:(GraphNode*)node;

@end
