//
//  CGPoint+Vector.c
//  TreeCollectionViewTest
//
//  Created by damian on 06/10/13.
//  Copyright (c) 2013 jack. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>

// return a 2D vector describing the delta from a to b
CGPoint CGPointDelta( CGPoint a, CGPoint b )
{
	return CGPointMake(b.x-a.x,b.y-a.y);
}

// interpret the CGPoint as a 2D vector and return its length
float CGPointMagnitudeSquared( CGPoint p )
{
	return p.x*p.x+p.y*p.y;
}

CGPoint CGPointMultiply( CGPoint a, float f )
{
	return CGPointMake(a.x*f,a.y*f);
}

CGPoint CGPointAdd(CGPoint a, CGPoint b)
{
	return CGPointMake(a.x+b.x, a.y+b.y);
}

