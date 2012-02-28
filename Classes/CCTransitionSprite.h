//
//  CCTransitionSprite.h
//  iAutomata
//
//  Created by Josh on 02/02/2011.
//  Copyright 2011 Josh Cooke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iAutomataTransition.h"
#import "cocos2d.h"
#import "FRCurve.h"


@interface CCTransitionSprite : CCSprite {
	iAutomataTransition *transition;
	FRCurve *curve;
	CCSprite *arrowhead,*activeArrowhead;
	CCLabelTTF *label;
}
@property (nonatomic,retain) iAutomataTransition *transition;
- (CCTransitionSprite*)spriteWithTransition:(iAutomataTransition*)t;
- (void)update;
- (CGPoint) curvePointWithP0:(CGPoint)p0 P1:(CGPoint)p1;
- (CGPoint)curvePointWithStateCentre:(CGPoint)p;
- (void)setActive:(BOOL)active;
- (iAutomataTransition*)getTransition;
- (void)setCurvePointsFromTransition:(iAutomataTransition*)t;
- (void)setCurvePointsFromSelfTransition:(iAutomataTransition*)t;
- (void)setArrowheadRotationAngleWithPoint0:(CGPoint)p0 Point1:(CGPoint)p1;
- (FRCurve*)getCurve;
@end
