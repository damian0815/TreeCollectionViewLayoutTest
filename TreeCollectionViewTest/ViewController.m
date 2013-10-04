//
//  ViewController.m
//  TreeCollectionViewTest
//
//  Created by damian on 04/10/13.
//  Copyright (c) 2013 jack. All rights reserved.
//

#import "ViewController.h"
#import "Graph.h"
#import "CollectionViewTreeLayout.h"
#import "TreeCellView.h"
#import "TreeDataSource.h"

@interface ViewController ()

@property (strong,readwrite,atomic) Graph* graph;
//@property (strong,readwrite,atomic) CollectionViewTreeLayout* layout;
@property (strong,readwrite,atomic) UICollectionViewFlowLayout* layout;

@property (strong,readwrite,atomic) TreeDataSource* dataSource;

@end

@implementation ViewController

- (id)init
{
	
	//CollectionViewTreeLayout* layout = [[CollectionViewTreeLayout alloc] init];
	UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
	self = [super initWithCollectionViewLayout:layout];
	if ( self ) {
		self.layout = layout;
	}
	return self;
}

- (unsigned int)numDescendantsOfNode:(GraphNode*)root
{
	NSLog(@"counting descendants of %@", root.key);
	unsigned int count = 0;
	NSSet* outNodes = [root outNodes];
	for ( GraphNode* child in outNodes ) {
		count += [self numDescendantsOfNode:child];
		NSLog(@"added descendants of %@ -> %i", child.key, count);
	}
	NSLog(@"-> returning descendants of %@: %i", root.key, count+1);
	return count+1;
}

- (void)buildGraphWithRoot:(GraphNode*)root maxNodes:(int)maxNodes
{
	if ( [self numDescendantsOfNode:root]>=maxNodes )
		return;
	
	// add N children to this root
	int numChildren = arc4random_uniform(3);
	for ( int i=0; i<numChildren; i++ )
	{
		NSLog(@"adding %i children", numChildren);
		GraphNode* child = [GraphNode nodeWithKey:[NSString stringWithFormat:@"%i",self.graph.nodes.count]];
		[self.graph addNode:child];
		[self.graph addEdgeFromNode:root toNode:child];
		
		[self buildGraphWithRoot:child maxNodes:maxNodes/numChildren];
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.collectionView.backgroundColor = [UIColor whiteColor];
	
	//create the graph
	self.graph = [[Graph alloc] init];
	GraphNode* root = [GraphNode nodeWithKey:@"0"];
	[self.graph addNode:root];
	
	// recursively build the graph
	unsigned int numNodes = 25;
	while ( self.graph.nodes.count<numNodes )
	{
		NSLog(@"*** need to add %i more children", numNodes-self.graph.nodes.count);
		[self buildGraphWithRoot:root maxNodes:numNodes];
	}
	
	//self.layout.tree = self.graph;
	
	self.dataSource = [[TreeDataSource alloc] initWithTree:self.graph];
	self.collectionView.dataSource = self.dataSource;
	self.collectionView.delegate = self;
	
	[self.collectionView registerClass:[TreeCellView class] forCellWithReuseIdentifier:TREE_CELL_VIEW_REUSE_IDENTIFIER];
	
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
