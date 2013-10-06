//
//  CGPoint+Vector.h
//  TreeCollectionViewTest
//
//  Created by damian on 06/10/13.
//  Copyright (c) 2013 jack. All rights reserved.
//

#ifndef TreeCollectionViewTest_CGPoint_Vector_h
#define TreeCollectionViewTest_CGPoint_Vector_h

#define fequal(a,b) (fabs((a)-(b))<FLT_EPSILON)

// return a 2D vector describing the delta from a to b
CGPoint CGPointDelta( CGPoint a, CGPoint b );
// interpret the CGPoint as a 2D vector and return its length squared
float CGPointMagnitudeSquared( CGPoint p );

CGPoint CGPointMultiply( CGPoint a, float f);
CGPoint CGPointAdd(CGPoint a, CGPoint b);

#endif
