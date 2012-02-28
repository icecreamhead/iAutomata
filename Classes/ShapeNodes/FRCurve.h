//
//  FRBezierCurve.h
//  LegendaryWars
//
//  Created by Lam Pham on 6/19/10.
//  Copyright 2010 Fancy Rat Studios Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "FRLines.h"

/**
 *	Implementation of curves here.
 */
typedef enum {
	kFRCurveLagrange,
	kFRCurveBezier,
} FRCurveType;

/**
 *	For now the curve order is limited to the most efficient orders for quadratic and cubic
 *	So you aren't allowed to make orders all values of n.
 */
typedef enum {
	kFRCurveQuadratic = 1,
	kFRCurveCubic = 2,
} FRCurveOrder;

@interface FRCurve : CCNode<CCRGBAProtocol> {
	ccpCurve *curve_;
	FRCurveType type_;
	FRCurveOrder order_;
	CGPoint* params_;
	BOOL created_;
	BOOL showControlPoints_;
	ccBlendFunc blendFunc_;
}
@property (readonly) ccpCurve *curve;
@property (assign) float width;
@property (assign) FRCurveType type;
@property (assign) FRCurveOrder order;
@property (readonly) CGPoint *params;
@property (readonly) unsigned char paramCount;
@property BOOL showControlPoints;
@property (nonatomic,readwrite) ccBlendFunc blendFunc;

+(id)curveFromType:(FRCurveType)type order:(FRCurveOrder)order segments:(int)segments;
-(id)initFromType:(FRCurveType)type order:(FRCurveOrder)order segments:(int)segments;
-(void)setPoint:(CGPoint)pt atIndex:(NSUInteger)index;
-(CGPoint)pointAtIndex:(NSUInteger)index;
-(void)invalidate;
@end
