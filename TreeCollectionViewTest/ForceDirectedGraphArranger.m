//
//  ForceDirectedGraphArranger.m
//  TreeCollectionViewTest
//
//  Created by damian on 04/10/13.
//  Copyright (c) 2013 jack. All rights reserved.
//

#import "ForceDirectedGraphArranger.h"

#import "CGPoint+Vector.h"

@interface ForceDirectedGraphArrangerNodeInfo : NSObject

@property (readwrite,copy,atomic) NSString* nodeKey;
@property (readwrite,assign,atomic) BOOL anchored;
@property (readwrite,assign,atomic) CGPoint position;
@property (readwrite,assign,atomic) CGPoint velocity;
@property (readwrite,assign,atomic) CGPoint force;
@property (readwrite,assign,atomic) float restLength;

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

@property (readwrite,atomic,strong) NSMutableDictionary* nodes;

@end

@implementation ForceDirectedGraphArranger

- (id)initWithGraph:(Graph*)graph
{
	self = [super init];
	if ( self ) {
		self.nodes = [NSMutableDictionary dictionary];
		self.nodeMass = 1.0f;
		self.nodeCharge = 1.0f;
		self.springConstant = 0.01f;
		self.damping = 0.1f;
		self.startRestLength = 50.0f;
		self.gravity = 0.0f;
		
		self.graph = graph;
		
	}
	return self;
}

- (void)setGraph:(Graph *)graph
{
	_graph = graph;
	
	[self.nodes removeAllObjects];
	
	NSArray* sortedNodes = [Graph topologicalSortWithNodes:[graph allNodes]];
	
	for (GraphNode* node in sortedNodes) {
		[self addNode:node];
	}
}

- (void)anchorNode:(GraphNode*)node
{
	ForceDirectedGraphArrangerNodeInfo* nodeInfo = [self nodeForGraphNode:node];
	nodeInfo.anchored = YES;
}

- (void)addNode:(GraphNode *)node
{
	ForceDirectedGraphArrangerNodeInfo* nodeInfo = [[ForceDirectedGraphArrangerNodeInfo alloc] init];
	nodeInfo.nodeKey = node.key;
	// try to find a parent
	GraphNode* parent = [[node inNodes] anyObject];
	if ( parent ) {
		NSSet* siblings = [parent outNodes];
		float baseAngle = 0.0f;
		float angleSpread = (float)M_PI*2.0f;
		GraphNode* grandparent = [[parent inNodes] anyObject];
		if ( grandparent ) {
			ForceDirectedGraphArrangerNodeInfo* grandparentInfo = [self nodeForGraphNode:grandparent];
			ForceDirectedGraphArrangerNodeInfo* parentInfo = [self nodeForGraphNode:parent];
			if ( grandparentInfo && parentInfo ) {
				// baseAngle = angle from parent to grandparent + 90
				CGPoint grandparentDirection = CGPointDelta( parentInfo.position, grandparentInfo.position );
				
				baseAngle = atan2f( grandparentDirection.y, grandparentDirection.x);
				baseAngle += M_PI_2;
				
				angleSpread = (float)M_PI;
			}
		}
		
		// count siblings
		unsigned int siblingCount = siblings.count;
		
		// our angle is (360/totalNumSiblings)*(numSiblingsAlreadyInArranger)
		unsigned int numSiblingsAlreadyIn = 0;
		for ( GraphNode* sibling in siblings ) {
			if ( [self nodeForGraphNode:sibling] ) {
				numSiblingsAlreadyIn++;
			}
		}
		float angle = baseAngle + (angleSpread/(double)(siblingCount))*(double)numSiblingsAlreadyIn;
	
		// add at the correct angle away from the parent
		float r = self.startRestLength*2.0f;
		CGPoint relativePosition = CGPointMake(r*cosf(angle), r*sinf(angle));
		relativePosition = CGPointAdd( relativePosition, CGPointMake( arc4random_uniform(30), arc4random_uniform(30) ) );
		
		CGPoint parentPosition = [self positionForNode:parent.key];
		CGPoint absolutePosition = CGPointAdd(parentPosition,relativePosition);
		
		nodeInfo.position = absolutePosition;
	}
	else
	{
		// add somewhere random
		nodeInfo.position = CGPointMake(200+arc4random_uniform(100),200+arc4random_uniform(100));
	}
	
	nodeInfo.velocity = CGPointZero;
	nodeInfo.force = CGPointZero;
	nodeInfo.restLength = self.startRestLength;
	[self.nodes setObject:nodeInfo forKey:node.key];
}

- (void) shuffleArray:(NSMutableArray*)array
{
	NSUInteger count = [array count];
	for (NSUInteger i = 0; i < count; ++i) {
		// Select a random element between i and end of array to swap with.
		NSInteger nElements = count - i;
		NSInteger n = arc4random_uniform(nElements) + i;
		[array exchangeObjectAtIndex:i withObjectAtIndex:n];
	}
}

- (void)applyForce
{
	float invMass = 1.0f/self.nodeMass;
	float t = 1.0f;
	float distanceThresh = 200;
	
	NSMutableArray* allNodes = [[self.nodes allValues] mutableCopy];
	// reset force
	for ( ForceDirectedGraphArrangerNodeInfo* nodeInfo in allNodes ) {
		nodeInfo.force = CGPointZero;
	}

	for ( ForceDirectedGraphArrangerNodeInfo* nodeInfo in allNodes ) {
		if ( nodeInfo.anchored ) {
			continue;
		}
		// be pulled downwards
		nodeInfo.force = CGPointAdd(nodeInfo.force, CGPointMake(0, self.gravity*self.nodeMass));
		// damp velocities
		nodeInfo.force = CGPointAdd(nodeInfo.force, CGPointMultiply(nodeInfo.velocity, -self.damping));
		
		
		// be driven away from all other nodes, inverse squared falloff
		NSArray* neighbours = [self nodesNear:nodeInfo.nodeKey distanceThreshold:distanceThresh];
		for ( ForceDirectedGraphArrangerNodeInfo* neighbour in neighbours ) {
			CGPoint delta = [nodeInfo deltaTo:neighbour];
			float sqDist = CGPointMagnitudeSquared(delta);
			float dist = sqrtf(sqDist);
			float pushAmount = 0;
			CGPoint direction;
			if ( fequal(dist,0) ) {
				pushAmount = 1.0f;
				direction = CGPointMake(0,0);
			} else {
				pushAmount = 1.0f/sqDist;
				direction = CGPointMultiply(delta,1.0f/dist);
			}
			
			pushAmount *= self.nodeCharge;
			nodeInfo.force = CGPointAdd(nodeInfo.force,CGPointMultiply(direction,-pushAmount));
		}
		
		// be pulled toward parents and children
		GraphNode* node = [self.graph nodeWithKey:nodeInfo.nodeKey];
		//NSMutableArray* relatives = [[[[node outNodes] setByAddingObjectsFromSet:[node inNodes]] allObjects] mutableCopy];
		NSSet* relatives = [node inNodes];
		for ( GraphNode* relative in relatives ) {
			ForceDirectedGraphArrangerNodeInfo* relativeInfo = [self nodeForGraphNode:relative];
			CGPoint delta = [nodeInfo deltaTo:relativeInfo];
			float sqDist = CGPointMagnitudeSquared(delta);
			float dist = sqrtf(sqDist);
			
			CGPoint direction;
			if ( fequal(sqDist,0) ) {
				direction = CGPointMake(1,0);
			} else {
				direction = CGPointMultiply(delta,1.0f/dist);
			}
			//float moveDist = (dist-nodeInfo.restLength)*self.springConstant;
			CGPoint springForce = CGPointMultiply(direction,0.5f*self.springConstant*log10f(dist/nodeInfo.restLength));
			relativeInfo.force = CGPointAdd(relativeInfo.force,CGPointMultiply(springForce,-1.0f));
			nodeInfo.force = CGPointAdd(nodeInfo.force,springForce);
		}
		
	}
	
	
	for ( ForceDirectedGraphArrangerNodeInfo* nodeInfo in allNodes ) {
		if ( nodeInfo.anchored ) {
			continue;
		}
		CGPoint newVelocity = CGPointAdd(nodeInfo.velocity, CGPointMultiply(nodeInfo.force, t*invMass));
		CGPoint newPosition = CGPointAdd(nodeInfo.position, CGPointMultiply(newVelocity, t));
		nodeInfo.velocity = newVelocity;
		nodeInfo.position = newPosition;
		NSAssert(!isnan(nodeInfo.position.x), @"NaN");
		NSAssert(!isnan(nodeInfo.position.y), @"NaN");
	}
}

- (ForceDirectedGraphArrangerNodeInfo*)nodeForGraphNode:(GraphNode*)graphNode
{
	return [self.nodes objectForKey:graphNode.key];
}
	
- (NSArray*)nodesNear:(NSString*)nodeKey distanceThreshold:(float)distanceThresh
{
	float distThreshSq = distanceThresh*distanceThresh;
	ForceDirectedGraphArrangerNodeInfo* n = [self.nodes objectForKey:nodeKey];
	NSAssert(n, @"Failure: bad node key");
	
	NSMutableArray* result = [NSMutableArray array];
	for ( ForceDirectedGraphArrangerNodeInfo* nodeInfo in [self.nodes allValues] ) {
		if ( [nodeInfo.nodeKey isEqual:nodeKey] ) {
			continue;
		}
		float distSq = [nodeInfo distanceSquaredTo:n];
		if ( distSq < distThreshSq ) {
			[result addObject:nodeInfo];
		}
	}
	return result;
}

- (CGPoint)positionForNode:(NSString*)nodeKey
{
	ForceDirectedGraphArrangerNodeInfo* nodeInfo = [self.nodes objectForKey:nodeKey];
	NSAssert(nodeInfo, @"Couldn't find node for key");
	return nodeInfo.position;
}



@end
