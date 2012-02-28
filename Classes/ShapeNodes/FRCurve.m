//
//  FRBezierCurve.m
//  LegendaryWars
//
//  Created by Lam Pham on 6/19/10.
//  Copyright 2010 Fancy Rat Studios Inc. All rights reserved.
//

#import "FRCurve.h"

@implementation FRCurve

@synthesize curve = curve_;
@synthesize order = order_;
@synthesize type = type_;
@synthesize params = params_;
@synthesize showControlPoints = showControlPoints_;
@synthesize blendFunc = blendFunc_;

+(id)curveFromType:(FRCurveType)type order:(FRCurveOrder)order segments:(int)segments
{
	return [[[self alloc] initFromType:type order:order segments:segments] autorelease];
}

-(id)initFromType:(FRCurveType)type order:(FRCurveOrder)order segments:(int)segments
{
	if((self = [super init])){
		params_ = nil;
		self.order = order;
		self.type = type;
		curve_ = ccpCurveMake(segments);
		created_ = NO;
		self.width = 1.f;
		blendFunc_ = (ccBlendFunc){CC_BLEND_SRC, CC_BLEND_DST};
	}
	return self;
}

-(void) dealloc
{
	ccpCurveRelease(curve_);
	free(params_);
	[super dealloc];
}

-(void)setWidth:(float)newWidth
{
	ccpCurveSetWidth(curve_, newWidth);
}
-(float)width
{
	return curve_->width;
}

-(unsigned char)paramCount
{
	return order_ + 2;
}

-(void)setOrder:(FRCurveOrder)newOrder
{
	if (order_ == newOrder && params_) return;
	order_ = newOrder;
	if (!params_) {
		params_ = malloc(self.paramCount * sizeof(CGPoint));
	} else {
		params_ = realloc(params_, self.paramCount * sizeof(CGPoint));
	}
}

-(void)draw
{
	[super draw];
	glBlendFunc(blendFunc_.src, blendFunc_.dst);
	if (curve_ && created_) {
		
		BOOL newBlend = NO;
		if( blendFunc_.src != CC_BLEND_SRC || blendFunc_.dst != CC_BLEND_DST ) {
			newBlend = YES;
			glBlendFunc( blendFunc_.src, blendFunc_.dst );
		}
		
		ccpCurveDraw(curve_);
		
		if( newBlend )
			glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
	}
	if (showControlPoints_) {
		glColor4ub(0, 255, 0, 255);
		glPointSize(10.f);
		ccDrawPoints(params_, self.paramCount);
		glPointSize(1.f);
	}
}
-(void)invalidate
{
	if (!created_) {
		return;
	}
	if(type_ == kFRCurveLagrange){
		if(order_ == kFRCurveQuadratic){
			ccpAitkenLagrange(curve_, params_, self.paramCount, QuadLagrangePinnedKnot, QuadLagrangeKnotCount);
		} else if(order_ == kFRCurveCubic) {
			ccpAitkenLagrange(curve_, params_, self.paramCount, CubicLagrangePinnedKnot, CubicLagrangeKnotCount);
		}
	} else if(type_ == kFRCurveBezier) {
		ccpDeCasteljauBezier(curve_, params_, self.paramCount);
	}
}
-(void)setPoint:(CGPoint)pt atIndex:(NSUInteger)index;
{
	if (index < self.paramCount) {
		params_[index] = pt;
		created_ = YES;
	}
}
-(CGPoint)pointAtIndex:(NSUInteger)index
{
	if (index < self.paramCount) {
		return params_[index];
	}
	return CGPointZero;
}
-(void)setColor:(ccColor3B)color
{
	ccpCurveSetColor(curve_, color);
}
-(ccColor3B)color
{
	return curve_->color;
}
-(void)setOpacity:(GLubyte)opacity
{
	ccpCurveSetOpacity(curve_, opacity);
}
-(GLubyte)opacity
{
	return curve_->opacity;
}
@end
