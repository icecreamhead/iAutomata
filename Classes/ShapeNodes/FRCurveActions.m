//
//  FRCurveActions.m
//  Che
//
//  Created by Lam Pham on 11-01-29.
//  Copyright 2011 Fancy Rat Studios Inc. All rights reserved.
//

#import "FRCurveActions.h"


@implementation FRActionLagrangeTo

+(id) actionWithDuration: (ccTime) t lagrange:(ccBezierConfig) config
{	
	return [[[self alloc] initWithDuration:t lagrange:config ] autorelease];
}

-(id) initWithDuration: (ccTime) t lagrange:(ccBezierConfig) config
{
	if( (self=[super initWithDuration: t]) ) {
		params_ = ccpCubicParamsMake(CGPointZero, config.controlPoint_1, config.controlPoint_2, config.endPosition);
	}
	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	ccBezierConfig config;
	config.controlPoint_1 = params_.cp1;
	config.controlPoint_2 = params_.cp2;
	config.endPosition = params_.end;
	CCAction *copy = [[[self class] allocWithZone: zone] initWithDuration: [self duration] lagrange: config];
	return copy;
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	params_.start = CGPointZero;
	params_.start = [(CCNode*)target_ position];
}

-(void) update: (ccTime) t
{	
	
	CGPoint step = ccpAitkenLagrangeStep(t, (CGPoint*)&params_, CubicLagrangeKnotCount, CubicLagrangePinnedKnot, CubicLagrangeKnotCount);
	[target_ setPosition:step];
}

- (CCActionInterval*) reverse
{
	ccBezierConfig r;
	
	r.controlPoint_1 = ccpAdd(params_.cp2, ccpNeg(params_.end));
	r.controlPoint_2 = ccpAdd(params_.cp1, ccpNeg(params_.end));
	r.endPosition = params_.end;
	
	FRActionLagrangeTo *action = [[self class] actionWithDuration:[self duration] bezier:r];
	return action;
}

@end
