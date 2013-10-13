//
//  GraphBrowseByScrollViewController.m
//  TreeCollectionViewTest
//
//  Created by Damian Stewart on 06.10.13.
//  Copyright (c) 2013 jack. All rights reserved.
//

#import "GraphBrowseByScrollViewController.h"
#import "Graph.h"
#import "GraphBuilder.h"
#import "NodeView.h"

static const float vDistance = 100.0f;
static const float hDistance = 60.0f;
static const float vCenter = 150.0f;


@interface GraphBrowseByScrollViewController () <UIGestureRecognizerDelegate>

@property (strong,readwrite,atomic) Graph* graph;
@property (strong,readwrite,atomic) UIPanGestureRecognizer* scrollDetector;

@property (assign,readwrite,atomic) float vPosition;
@property (assign,readwrite,atomic) float hPosition;

@property (assign,readwrite,atomic) CGPoint positionAtStartDrag;
@property (strong,readwrite,atomic) NSMutableArray* hPositionStack;

@property (copy,readwrite,atomic) NSString* centralNodeKey;

@property (strong,readwrite,atomic) NSMutableDictionary* nodeViews;

@end

@implementation GraphBrowseByScrollViewController

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
		self.graph = [GraphBuilder buildGraph];
		self.nodeViews = [NSMutableDictionary dictionary];
		self.hPositionStack = [NSMutableArray array];
		self.centralNodeKey = @"*";
		self.vPosition = 0.0f;
		self.hPosition = 0.0f;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	self.scrollDetector = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleScrollGesture:)];
	[self.scrollDetector setDelegate:self];
	[self.view addGestureRecognizer:self.scrollDetector];
	
	[self updateNodeViews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) updateNodeViews
{
	// build a set of nodes that should be visible or partially visible based on the centralNodeKey
	NSMutableSet* expectedVisibleNodes = [NSMutableSet set];
	
	//float alphaIn = self.position;
	//float alphaOut = 1.0f-self.position;
	float alphaIn = 1.0f;
	float alphaOut = self.vPosition;
	
	GraphNode* centralNode = [self.graph nodeWithKey:self.centralNodeKey];
	[expectedVisibleNodes addObject:centralNode.key];
	NodeView* nodeView = [self nodeViewForNodeWithKey:centralNode.key];
	nodeView.alpha = 1.0f;
	nodeView.center = CGPointMake(150, vCenter+self.vPosition*vDistance);
	
	// in nodes
	NSArray* inNodes = [[centralNode inNodes] allObjects];
	int count = 0;
	float inPositionY = vCenter-((1.0f-self.vPosition)*vDistance);
	for ( GraphNode* inNode in inNodes ) {
		NodeView* nodeView = [self nodeViewForNodeWithKey:inNode.key];
		nodeView.alpha = alphaIn;
		float xPos = 150 + (1.0f-self.vPosition)*(count*50)+count*10;
		nodeView.center = CGPointMake(xPos, inPositionY);
		count++;
		[expectedVisibleNodes addObject:inNode.key];
	}
	
	// out nodes
	NSArray* outNodes = [[centralNode outNodes] allObjects];
	count = 0;
	float outPositionY = vCenter+((1.0f+self.vPosition)*vDistance);
	for ( GraphNode* outNode in outNodes ) {
		NodeView* nodeView = [self nodeViewForNodeWithKey:outNode.key];
		
		if ( count == [self selectedChildIndex] ) {
			nodeView.alpha = 1.0f;
		} else {
			nodeView.alpha = alphaOut;
		}
		
		// weight the hposition depending on how far away we are from switching to the next child -- closer we are, the more snapped we should be
		float xPos = 150 + self.hPosition*hDistance + count*60;
		nodeView.center = CGPointMake(xPos, outPositionY);
		count++;
		[expectedVisibleNodes addObject:outNode.key];
	}
	
	// grandchildren of selected
	if ( outNodes.count ) {
		GraphNode* selectedChild = [outNodes objectAtIndex:[self selectedChildIndex]];
		float grandOutPositionY = outPositionY + vDistance;
		float grandHDistanceFactor = 2.0f*fabsf(fmodf(self.hPosition,1.0f)+0.5f);
		NSArray* grandOut = [[selectedChild outNodes] allObjects];
		count = 0;
		for ( GraphNode* outNode in grandOut ) {
			NodeView* nodeView = [self nodeViewForNodeWithKey:outNode.key];
			float xPos = 150 + count*hDistance + (self.hPosition+(float)[self selectedChildIndex])*hDistance;
			if ( self.vPosition<0.8f ) {
				nodeView.alpha = grandHDistanceFactor*(1.0f-(self.vPosition/0.8f));
			} else {
				nodeView.alpha = 0.0f;
			}
			nodeView.center = CGPointMake(xPos, grandOutPositionY);
			count++;
			[expectedVisibleNodes addObject:outNode.key];
		}
	}
	
	// wmork out which nodes to remove by intersecting with expectedVisibleNodes
	NSMutableSet* visibleNodes = [NSMutableSet setWithArray:[self.nodeViews allKeys]];
	[visibleNodes minusSet:expectedVisibleNodes];
	for ( NSString* key in visibleNodes ) {
		// delete them all, removing from superview also
		NodeView* v = [self.nodeViews objectForKey:key];
		[v removeFromSuperview];
		[self.nodeViews removeObjectForKey:key];
	}
	
}

- (NodeView*)nodeViewForNodeWithKey:(NSString*)key
{
	NodeView* v = [self.nodeViews objectForKey:key];
	if ( !v ) {
		v = [NodeView nodeViewWithFrame:CGRectMake(0,0,50,50) forNodeWithKey:key];
		[self.nodeViews setObject:v forKey:key];
		[self.view addSubview:v];
	}
	return v;
}

- (unsigned int)selectedChildIndex
{
	GraphNode* central = [self.graph nodeWithKey:self.centralNodeKey];
	NSArray* children = [[central outNodes] allObjects];
	int childIdx = (int)(-(self.hPosition-0.5f));
	childIdx = MIN(children.count-1,childIdx);
	childIdx = MAX(0,childIdx);
	return childIdx;
}

- (BOOL)goToCurrentChild
{
	GraphNode* central = [self.graph nodeWithKey:self.centralNodeKey];
	NSArray* children = [[central outNodes] allObjects];
	if ( children.count ) {
		GraphNode* currentChild = [children objectAtIndex:[self selectedChildIndex]];
		self.centralNodeKey = currentChild.key;
		return YES;
	} else {
		return NO;
	}
}

- (BOOL)goToCurrentParent
{
	GraphNode* central = [self.graph nodeWithKey:self.centralNodeKey];
	NSArray* parents = [[central inNodes] allObjects];
	if ( parents.count ) {
		GraphNode* currentParent = [parents objectAtIndex:0];
		self.centralNodeKey = currentParent.key;
		return YES;
	} else {
		return NO;
	}
}

- (void)handleScrollGesture:(UIPanGestureRecognizer*)gr
{
	if ( gr.state == UIGestureRecognizerStateBegan ) {
		self.positionAtStartDrag = CGPointMake(self.hPosition,self.vPosition);
		
	} else if ( gr.state == UIGestureRecognizerStateChanged ) {
		CGPoint translation = [gr translationInView:self.view];
		
		// update v position
		float newVPositionNonPct = self.positionAtStartDrag.y*vDistance + translation.y;
		float newVPosition = newVPositionNonPct/vDistance;
		while ( newVPosition>1.0f ) {
			BOOL gone = [self goToCurrentParent];
			if ( gone ) {
				// self.positionAtStartDrag.y -= 1.0f
				float oldHPosition = 0.0f;
				if ( self.hPositionStack.count ) {
					oldHPosition = [[self.hPositionStack lastObject] floatValue];
					[self.hPositionStack removeLastObject];
				}
				self.hPosition = oldHPosition-translation.x/hDistance;
				self.positionAtStartDrag = CGPointMake(self.hPosition, self.positionAtStartDrag.y-1.0f);
				newVPosition -= 1.0f;
			} else {
				newVPosition = 1.0f;
			}
		}
		while ( newVPosition<0.0f ) {
			BOOL gone = [self goToCurrentChild];
			if ( gone ) {
				// self.positionAtStartDrag.y += 1.0f
				[self.hPositionStack addObject:@(self.hPosition)];
				self.hPosition = -translation.x/hDistance;
				self.positionAtStartDrag = CGPointMake(self.hPosition, self.positionAtStartDrag.y+1.0f);
				newVPosition += 1.0f;
			} else {
				newVPosition = 0.0f;
			}
		}
		self.vPosition = newVPosition;
		
		
		// update h position
		float newHPosition = self.positionAtStartDrag.x + translation.x/hDistance;
		if ( self.vPosition < 0.5f ) {
			// snap
			// find the nearest hPosition
			float snappedHPosition = (int)(newHPosition-0.5f);
			//NSLog(@"snappedHPos: %f", snappedHPosition);
			//float snappedHPosition = hDistance * (float)((int)(self.hPosition/hDistance+0.5f));
			//float snappedHPosition = self.hPosition - fmodf(self.hPosition+0.5f*hDistance,hDistance);
			float vPositionWeightedHPosition = newHPosition*self.vPosition*2.0f + snappedHPosition*(1.0f-self.vPosition*2.0f);

			newHPosition = vPositionWeightedHPosition;
//			NSLog(@"vPositionWeightedHPosition: %f, hPosition: %f, vPosition: %f", vPositionWeightedHPosition, self.hPosition, self.vPosition);
		
		}
		self.hPosition = newHPosition;
		
		[self updateNodeViews];
		
	} else if ( gr.state == UIGestureRecognizerStateEnded ) {
		
	}
	
}


@end
