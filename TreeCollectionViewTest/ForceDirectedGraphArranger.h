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

- (id)initWithGraph:(Graph*)graph;

- (void)addNode:(GraphNode*)node;

- (void)applyForce;

@end
