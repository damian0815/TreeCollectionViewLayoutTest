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

@property (strong,readwrite,atomic) Graph* graph;

@property (assign,readwrite,atomic) float nodeMass;
@property (assign,readwrite,atomic) float nodeCharge;

- (void)updateLayout;

@end
