//
//  ViewController.m
//  TreeCollectionViewTest
//
//  Created by damian on 04/10/13.
//  Copyright (c) 2013 jack. All rights reserved.
//

#import "GraphBrowseByCollectionViewController.h"
#import "Graph.h"
#import "CollectionViewTreeLayout.h"
#import "TreeCellView.h"
#import "TreeDataSource.h"
#import "GraphBuilder.h"

@interface GraphBrowseByCollectionViewController ()

@property (strong,readwrite,atomic) Graph* graph;
@property (strong,readwrite,atomic) CollectionViewTreeLayout* layout;
//@property (strong,readwrite,atomic) UICollectionViewFlowLayout* layout;

@property (strong,readwrite,atomic) TreeDataSource* dataSource;

@property (strong,readwrite,atomic) CADisplayLink* displayLink;

@end

@implementation GraphBrowseByCollectionViewController

- (id)init
{
	
	CollectionViewTreeLayout* layout = [[CollectionViewTreeLayout alloc] init];
	//UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
	self = [super initWithCollectionViewLayout:layout];
	if ( self ) {
		self.layout = layout;
	}
	return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.collectionView.backgroundColor = [UIColor whiteColor];
	
	//create the graph
	self.graph = [GraphBuilder buildGraph];
	
	self.dataSource = [[TreeDataSource alloc] initWithTree:self.graph];
	self.collectionView.dataSource = self.dataSource;
	self.collectionView.delegate = self;
	
	self.layout.tree = self.graph;
	[self.layout.arranger anchorNode:[self.graph nodeWithKey:@"*"]];
	
	self.layout.dataSource = self.dataSource;
	
	[self.collectionView registerClass:[TreeCellView class] forCellWithReuseIdentifier:TREE_CELL_VIEW_REUSE_IDENTIFIER];
	
	self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTick:)];
	[self.displayLink setFrameInterval:1];
	[self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	
	// make sliders
	UISlider* chargeSlider = [[UISlider alloc] initWithFrame:CGRectMake(0,20,300,10)];
	[chargeSlider setMinimumValue:0.0f];
	[chargeSlider setMaximumValue:10000.0f];
	[chargeSlider addTarget:self action:@selector(chargeSliderMoved:) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:chargeSlider];
	
	UISlider* pullSlider = [[UISlider alloc] initWithFrame:CGRectMake(0,60,300,10)];
	[pullSlider setMinimumValue:0.0f];
	[pullSlider setMaximumValue:1.0f];
	[pullSlider addTarget:self action:@selector(pullSliderMoved:) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:pullSlider];
	
	
}

- (void)displayLinkTick:(CADisplayLink*)link
{
	[self.layout invalidateLayout];
}


- (void)chargeSliderMoved:(UISlider*)slider
{
	NSLog(@"node charge: %f", slider.value);
	[self.layout.arranger setNodeCharge:slider.value];
}

- (void)pullSliderMoved:(UISlider*)slider
{
	NSLog(@"spring constant: %f", slider.value);
	[self.layout.arranger setSpringConstant:slider.value];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
