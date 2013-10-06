//
//  CollectionViewTreeLayout.m
//  TreeCollectionViewTest
//
//  Created by damian on 04/10/13.
//  Copyright (c) 2013 jack. All rights reserved.
//

#import "CollectionViewTreeLayout.h"
#import "Graph.h"
#import "TreeDataSource.h"
#import "ForceDirectedGraphArranger.h"

@interface CollectionViewTreeLayout()

@property (strong,readwrite,atomic) NSMutableDictionary* layoutAttributesPerIndexPath;

@property (strong,readwrite,atomic) ForceDirectedGraphArranger* arranger;

@end

@implementation CollectionViewTreeLayout


- (id)init
{
	self = [super init];
	if ( self ) {
		self.layoutAttributesPerIndexPath = [NSMutableDictionary dictionary];
	}
	return self;
}

- (void)prepareLayout
{
	[self.layoutAttributesPerIndexPath removeAllObjects];
	
	// arrange the nodes
	//for ( int i=0; i<100; i++ ) {
	//	[self.arranger applyForce];
	//}
	[self.arranger applyForce];
	
	unsigned int count = [self.dataSource numNodes];
	for ( unsigned int i=0; i<count; i++ ) {
		NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
		UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
		attributes.bounds = CGRectMake(0,0,80,40);
		
		GraphNode* node = [self.dataSource nodeForIndexPath:indexPath];
		attributes.center = [self.arranger positionForNode:node.key];
		
		NSString* label = [self.dataSource labelForNodeWithIndexPath:indexPath];
		[self.layoutAttributesPerIndexPath setObject:attributes forKey:label];
	}
			
}

- (void)randomlyPositionNodes
{
	// randomly position
	[self.layoutAttributesPerIndexPath removeAllObjects];
	
	unsigned int count = [self.dataSource numNodes];
	for ( unsigned int i=0; i<count; i++ ) {
		NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
		UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
		attributes.bounds = CGRectMake(0,0,arc4random_uniform(40)+20, arc4random_uniform(40)+20);
		attributes.center = CGPointMake(arc4random_uniform(500), arc4random_uniform(1000));
		
		NSString* label = [self.dataSource labelForNodeWithIndexPath:indexPath];
		[self.layoutAttributesPerIndexPath setObject:attributes forKey:label];
	}
	
}

- (void)setTree:(Graph *)tree
{
	_tree = tree;
	self.arranger = [[ForceDirectedGraphArranger alloc] initWithGraph:_tree];
	
	[self invalidateLayout];
}

- (CGSize)collectionViewContentSize
{
	CGRect rect = CGRectZero;
	for ( UICollectionViewLayoutAttributes* attributes in [self.layoutAttributesPerIndexPath allValues] ) {
		rect = CGRectUnion(rect, attributes.frame);
	}
	return rect.size;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
	NSMutableArray* elements = [NSMutableArray array];
	for ( UICollectionViewLayoutAttributes* attributes in [self.layoutAttributesPerIndexPath allValues] ) {
		if ( CGRectIntersectsRect(attributes.frame,rect) ) {
			[elements addObject:attributes];
		}
	}
	return elements;
}

- (UICollectionViewLayoutAttributes*)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
	NSString* label = [self.dataSource labelForNodeWithIndexPath:indexPath];
	UICollectionViewLayoutAttributes* attributes = [self.layoutAttributesPerIndexPath objectForKey:label];
	return attributes;
	
	
}

@end
