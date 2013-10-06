//
//  GraphDataStore.m
//  TreeCollectionViewTest
//
//  Created by damian on 04/10/13.
//  Copyright (c) 2013 jack. All rights reserved.
//

#import "TreeDataSource.h"
#import "Graph.h"
#import "TreeCellView.h"

@interface TreeDataSource()

@property (strong,readwrite,atomic) NSMutableDictionary* nodeKeyToLabelMap;
@property (strong,readwrite,atomic) NSMutableDictionary* labelToNodeKeyMap;
@property (strong,readwrite,atomic) Graph* tree;

@end

@implementation TreeDataSource

- (id)initWithTree:(id)tree
{
	self = [super init];
	if ( self ) {
		self.tree = tree;
		self.nodeKeyToLabelMap = [NSMutableDictionary dictionary];
		self.labelToNodeKeyMap = [NSMutableDictionary dictionary];
		[self labelNodes:[tree allNodes]];
	}
	return self;
}

- (void)labelNodes:(NSSet*)nodes
{
	for ( GraphNode* n in nodes ) {
		[self labelNode:n];
	}
}

- (void)labelNode:(GraphNode*)n
{
	NSAssert(![self.nodeKeyToLabelMap objectForKey:n.key], @"Failure: already labelled this node");
	NSString* label = [NSString stringWithFormat:@"%i",self.nodeKeyToLabelMap.count];
	[self.nodeKeyToLabelMap setObject:label forKey:n.key];
	[self.labelToNodeKeyMap setObject:n.key forKey:label];
}

- (GraphNode*)nodeForIndexPath:(NSIndexPath*)indexPath
{
	NSString* label = [self labelForNodeWithIndexPath:indexPath];
	NSString* key = [self.labelToNodeKeyMap objectForKey:label];
	NSAssert(key, @"Failure: no node for this index path");
	GraphNode* node = [self.tree nodeWithKey:key];
	NSAssert(node, @"Failure: missing graph node");
	return node;
}

- (unsigned int)numNodes
{
	return self.tree.allNodes.count;
}

- (NSString*)labelForNodeWithIndexPath:(NSIndexPath*)indexPath
{
	NSString* label = [NSString stringWithFormat:@"%i",indexPath.row];
	return label;
}


#pragma mark - UICollectionViewDataSource delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.nodeKeyToLabelMap.count;
}



- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	//NSLog(@"cell for %@", indexPath);
	TreeCellView* treeCell = (TreeCellView*)[collectionView dequeueReusableCellWithReuseIdentifier:TREE_CELL_VIEW_REUSE_IDENTIFIER forIndexPath:indexPath];
	
	GraphNode* node = [self nodeForIndexPath:indexPath];
	[treeCell setNode:node];
	
	return treeCell;
}


@end
