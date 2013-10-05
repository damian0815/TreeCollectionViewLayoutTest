//
//  ForceDirectedGraphArranger.m
//  TreeCollectionViewTest
//
//  Created by damian on 04/10/13.
//  Copyright (c) 2013 jack. All rights reserved.
//

#import "ForceDirectedGraphArranger.h"


@interface ForceDirectedGraphArrangerNodeInfo : NSObject

@property (readwrite,copy,atomic) NSString* nodeKey;
@property (readwrite,assign,atomic) CGPoint position;
@property (readwrite,assign,atomic) CGPoint prevPosition;

- (float)distanceSquaredTo:(ForceDirectedGraphArrangerNodeInfo*)othernode;

@end

@implementation ForceDirectedGraphArrangerNodeInfo

- (BOOL)isEqual:(NSObject*)other
{
	if ( other==self )
		return YES;
	if ( [other isKindOfClass:[ForceDirectedGraphArrangerNodeInfo class]] ) {
		if ( [self.nodeKey isEqualToString:[(ForceDirectedGraphArrangerNodeInfo*)other nodeKey]] ) {
			return YES;
		}
	}
	return NO;
}

- (float)distanceSquaredTo:(ForceDirectedGraphArrangerNodeInfo *)otherNode
{
	float dx = otherNode.position.x-self.position.x;
	float dy = otherNode.position.y-self.position.y;
	return dx*dx+dy*dy;
}

- (CGPoint)deltaTo:(ForceDirectedGraphArrangerNodeInfo*)otherNode
{
	return CGPointMake(otherNode.position.x-self.position.x,otherNode.position.y-self.position.y);
}

@end


@interface ForceDirectedGraphArranger()

@property (readwrite,atomic,assign) NSMutableDictionary* nodes;

@end

@implementation ForceDirectedGraphArranger

- (id)initWithGraph:(Graph*)graph
{
	self = [super init];
	if ( self ) {
		self.graph = graph;
		self.nodeMass = 1.0f;
		self.nodeCharge = 1.0f;
		self.springConstant = 1.0f;
		self.damping = 0.1f;
		
	}
	return self;
}

- (void)setGraph:(Graph *)graph
{
	_graph = graph;
	
	[self.nodes removeAllObjects];
	for (GraphNode* node in graph.allNodes) {
		ForceDirectedGraphArrangerNodeInfo* nodeInfo = [[ForceDirectedGraphArrangerNodeInfo alloc] init];
		nodeInfo.nodeKey = node.key;
		nodeInfo.position = CGPointMake(arc4random_uniform(100),arc4random_uniform(100));
		nodeInfo.prevPosition = nodeInfo.position;
		[self.nodes setObject:nodeInfo forKey:node.key];
	}
	
}

- (void)applyForce
{
	float distanceThresh = 400;
	for ( ForceDirectedGraphArrangerNodeInfo* nodeInfo in self.nodes ) {
		// store previous position
		nodeInfo.prevPosition = nodeInfo.position;
		
		// be driven away from all other nodes, inverse squared falloff
		NSArray* neighbours = [self nodesNear:nodeInfo.nodeKey distanceThreshold:distanceThresh];
		for ( ForceDirectedGraphArrangerNodeInfo* neighbour in neighbours ) {
			CGPoint delta = [nodeInfo deltaTo:neighbour];
			float sqDist = CGPointLengthSquared(delta);
			float pushAmount = 0;
			CGPoint direction;
			if ( fequal(sqDist,0) ) {
				pushAmount = 1.0f;
				direction = CGPointMake(1,0);
			} else {
				pushAmount = 1.0f/sqDist;
				direction = CGPointMultiply(delta,1.0f/sqDist);
			}
			pushAmount *= self.nodeCharge;
			
			nodeInfo.position = CGPointAdd(nodeInfo.position, CGPointMultiply(direction,pushAmount));
		}
		
		// be pulled toward parents and children
		GraphNode* node = [self.graph nodeWithKey:nodeInfo.nodeKey];
		
		
	}
}

- (NSArray*)nodesNear:(NSString*)nodeKey distanceThreshold:(float)distanceThresh
{
	float distThreshSq = distanceThresh*distanceThresh;
	ForceDirectedGraphArrangerNodeInfo* n = [self.nodes objectForKey:nodeKey];
	NSAssert(n, @"Failure: bad node key");
	
	NSMutableArray* result = [NSMutableArray array];
	for ( ForceDirectedGraphArrangerNodeInfo* nodeInfo in self.nodes ) {
		float distSq = [nodeInfo distanceSquaredTo:n];
		if ( distSq < distThreshSq ) {
			[result addObject:nodeInfo];
		}
	}
	return result;
}


@end
