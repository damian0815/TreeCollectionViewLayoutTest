//
//  ForceDirectedGraphArranger.h
//  TreeCollectionViewTest
//
//  Created by damian on 04/10/13.
//  Copyright (c) 2013 jack. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Graph.h"

@interface ForceDirectedGraphArranger : NSObject

@property (strong,readwrite,nonatomic) Graph* graph;

@property (assign,readwrite,atomic) float nodeMass;
@property (assign,readwrite,atomic) float nodeCharge;
@property (assign,readwrite,atomic) float springConstant;
@property (assign,readwrite,atomic) float damping;
@property (assign,readwrite,atomic) float startRestLength;
@property (assign,readwrite,atomic) float gravity;

- (id)initWithGraph:(Graph*)graph;
- (void)anchorNode:(GraphNode*)node;

- (void)addNode:(GraphNode*)node;

- (void)applyForce;

- (CGPoint)positionForNode:(NSString*)nodeKey;

@end
