//
//  TreeCellView.m
//  TreeCollectionViewTest
//
//  Created by damian on 04/10/13.
//  Copyright (c) 2013 jack. All rights reserved.
//

#import "TreeCellView.h"
#import "GraphNode.h"

@interface TreeCellView()

@property (strong,readwrite,atomic) UILabel* nodeKeyLabel;

@end

@implementation TreeCellView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.nodeKeyLabel = [[UILabel alloc] init];
		[self.contentView addSubview:self.nodeKeyLabel];
		self.backgroundColor = [UIColor blackColor];
		self.nodeKeyLabel.textColor = [UIColor whiteColor];
		self.nodeKeyLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)layoutSubviews
{
	[super layoutSubviews];
	self.nodeKeyLabel.frame = self.contentView.bounds;
}

- (void)prepareForReuse
{
	self.nodeKeyLabel.text = @"nix";
}

- (void)setNode:(GraphNode *)node
{
	self.nodeKeyLabel.text = node.key;
}

@end
