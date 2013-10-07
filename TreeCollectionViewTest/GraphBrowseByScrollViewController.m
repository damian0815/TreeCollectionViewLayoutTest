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

@interface GraphBrowseByScrollViewController () <UIGestureRecognizerDelegate>

@property (strong,readwrite,atomic) Graph* graph;
@property (strong,readwrite,atomic) UIPanGestureRecognizer* scrollDetector;

@property (copy,readwrite,atomic) NSString* centralNodeKey;

@property (copy,readwrite,atomic) NSMutableDictionary* nodeViews;

@end

@implementation GraphBrowseByScrollViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.graph = [GraphBuilder buildGraph];
		self.visibleViews = [NSMutableDictionary dictionary];
		self.centralNodeKey = @"*";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
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
	
	GraphNode* centralNode = [self.graph nodeWithKey:self.centralNodeKey];
	[expectedVisibleNodes addObject:centralNode];
	[expectedVisibleNodes unionSet:[centralNode outNodes]];
	[expectedVisibleNodes unionSet:[centralNode inNodes]];
	
	
	
	
}

- (void)handleScrollGesture:(UIPanGestureRecognizer*)gr
{
	if ( gr.state == UIGestureRecognizerStateBegan ) {
		
	} else if ( gr.state == UIGestureRecognizerStateChanged ) {
		
	} else if ( gr.state == UIGestureRecognizerStateEnded ) {
		
	}
	
}


@end
