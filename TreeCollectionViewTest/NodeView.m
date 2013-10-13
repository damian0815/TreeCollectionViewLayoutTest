//
//  NodeView.m
//  TreeCollectionViewTest
//
//  Created by Damian Stewart on 12.10.13.
//  Copyright (c) 2013 jack. All rights reserved.
//

#import "NodeView.h"

@interface NodeView()

@property (copy, readwrite, nonatomic) NSString* key;
@property (strong, readwrite, atomic) UILabel* keyLabel;

@end

@implementation NodeView

+ (NodeView*)nodeViewWithFrame:(CGRect)frame forNodeWithKey:(NSString*)key
{
	NodeView* nodeView = [[NodeView alloc] initWithFrame:frame];
	nodeView.key = key;
	return nodeView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.key = nil;
		self.backgroundColor = [UIColor blackColor];
		self.keyLabel = [[UILabel alloc] initWithFrame:self.bounds];
		self.keyLabel.textColor = [UIColor whiteColor];
		self.keyLabel.textAlignment = NSTextAlignmentCenter;
		[self addSubview:self.keyLabel];
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
	self.keyLabel.frame = self.bounds;
}

- (void)setKey:(NSString *)key
{
	self.keyLabel.text = key;
}

@end
