//
//  NodeView.h
//  TreeCollectionViewTest
//
//  Created by Damian Stewart on 12.10.13.
//  Copyright (c) 2013 jack. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NodeView : UIView

+ (NodeView*)nodeViewWithFrame:(CGRect)frame forNodeWithKey:(NSString*)key;

@end
