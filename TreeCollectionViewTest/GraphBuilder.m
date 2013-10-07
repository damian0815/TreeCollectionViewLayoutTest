//
//  GraphBuilder.m
//  TreeCollectionViewTest
//
//  Created by Damian Stewart on 06.10.13.
//  Copyright (c) 2013 jack. All rights reserved.
//

#import "GraphBuilder.h"
#import "Graph.h"

@interface GraphBuilder()

@property (readwrite, atomic, strong) Graph* graph;

@end

@implementation GraphBuilder

+ (Graph*)buildGraph
{
	GraphBuilder* gb = [[GraphBuilder alloc] init];
	
	GraphNode* root = [GraphNode nodeWithKey:@"*"];
	[gb.graph addNode:root];
	
	// recursively build the graph
	unsigned int numNodes = 25;
	unsigned int maxDepth = 4;
	while ( gb.graph.nodes.count<numNodes )
	{
		NSLog(@"*** need to add %i more children", numNodes-gb.graph.nodes.count);
		[gb buildGraphWithRoot:root maxNodes:numNodes depth:maxDepth];
	}
	
	return gb.graph;
}

- (id)init
{
	self = [super init];
	if ( self ) {
		self.graph = [[Graph alloc] init];
	}
	return self;
}

- (unsigned int)numDescendantsOfNode:(GraphNode*)root
{
	//NSLog(@"counting descendants of %@", root.key);
	unsigned int count = 0;
	NSSet* outNodes = [root outNodes];
	for ( GraphNode* child in outNodes ) {
		count += [self numDescendantsOfNode:child];
		//NSLog(@"added descendants of %@ -> %i", child.key, count);
	}
	//NSLog(@"-> returning descendants of %@: %i", root.key, count+1);
	return count+1;
}

- (void)buildGraphWithRoot:(GraphNode*)root maxNodes:(int)maxNodes depth:(int)depth
{
	if ( depth<=0 )
		return;
	if ( [self numDescendantsOfNode:root]>=maxNodes )
		return;

	// add N children to this root
	int numChildren = arc4random_uniform(4);
	for ( int i=0; i<numChildren; i++ )
	{
		NSLog(@"adding %i children", numChildren);
		GraphNode* child = [GraphNode nodeWithKey:[NSString stringWithFormat:@"%@%c", root.key, 'A'+i]];
		[self.graph addNode:child];
		[self.graph addEdgeFromNode:root toNode:child];
		
		[self buildGraphWithRoot:child maxNodes:maxNodes/numChildren depth:depth-1];
	}
}

@end
