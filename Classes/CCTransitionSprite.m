//
//  CCTransitionSprite.m
//  iAutomata
//
//  Created by Josh on 02/02/2011.
//  Copyright 2011 Josh Cooke. All rights reserved.
//

#import "CCTransitionSprite.h"
#import "cocos2d.h"
#import "iAutomataDiagramScene.h"

@implementation CCTransitionSprite
@synthesize transition;
- (CCTransitionSprite*)spriteWithTransition:(iAutomataTransition*)t {
	if ((self = [super init])) {
		transition = t;
		arrowhead = [[CCSprite spriteWithFile:@"arrowhead.png"] retain];
		activeArrowhead = [[CCSprite spriteWithFile:@"arrowhead2.png"] retain];
		[arrowhead setAnchorPoint:ccp(0.5f,1.0f)];
		[activeArrowhead setAnchorPoint:ccp(0.5f,1.0f)];
		curve = [[FRCurve curveFromType:kFRCurveBezier order:kFRCurveQuadratic segments:64] retain];
		[curve setWidth:1.0f];
		[curve setShowControlPoints:NO];
		label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%c",[transition getSymbol]] fontName:@"Marker Felt" fontSize:12];
		//NSLog(@"From %@ to %@",[[transition getFromState] getName],[[transition getToState] getName]);
		if ([[transition getFromState] isEqual:[transition getToState]]) {
			[self setCurvePointsFromSelfTransition:transition];
		} else {
			[self setCurvePointsFromTransition:transition];
		}
		[curve invalidate];
		[curve setColor:ccc3(0, 0, 0)];
		[self addChild:curve z:1];
		[label setColor:ccc3(0, 0, 0)];
		[self addChild:label z:2 tag:13];
		[self addChild:arrowhead z:3 tag:14];
	}
	return self;
}

- (void)update {
	if ([[transition getFromState] isEqual:[transition getToState]]) {
		[self setCurvePointsFromSelfTransition:transition];
	} else {
		[self setCurvePointsFromTransition:transition];
	}
	[label setString:[NSString stringWithFormat:@"%c",[transition getSymbol]]];
	[curve invalidate];
}
- (CGPoint) curvePointWithP0:(CGPoint)p0 P1:(CGPoint)p1 {
	CGPoint p;
	float offset = 5.0f; // manually set this
	int dx = p0.x-p1.x;
	int dy = p0.y-p1.y;
	CGPoint lCentre = ccp((p0.x+p1.x)/2,(p1.y+p0.y)/2);
	float theta = atanf((float)abs(dy)/(float)abs(dx));
	int l = roundf(sqrtf(dx*dx+dy*dy));
	//int halfL = (int)((float)l/2.0f);
	int curveDepth = (int)((float)l / offset);
	//NSLog(@"Curvedepth: %d theta:%f l:%d",curveDepth,theta,l);
	int xOffset = curveDepth * sinf(theta);
	int yOffset = curveDepth * cosf(theta);
	//NSLog(@"theta: %d curvedepth: %d xOffset: %d yOffset: %d",(int)theta*180/M_PI,curveDepth,xOffset,yOffset);
	if (dx == 0 && dy == 0) {
		p = p0;
	} else if (dx == 0) { // vertical line
		if (dy < 0) { // up
			p = ccp(lCentre.x-curveDepth,lCentre.y);
		} else { // down
			p = ccp(lCentre.x+curveDepth,lCentre.y);
		}
	} else if (dy == 0) {
		if (dx < 0) { // right
			p = ccp(lCentre.x,lCentre.y+curveDepth);
		} else { // left
			p = ccp(lCentre.x,lCentre.y-curveDepth);
		}
	} else {
		if (dy < 0) { // upwards
			if (dx < 0) { // right
				p = ccp(lCentre.x-xOffset,lCentre.y+yOffset);
			} else { // left
				p = ccp(lCentre.x-xOffset,lCentre.y-yOffset);
			}
		} else { // downwards
			if (dx < 0) { //right
				p = ccp(lCentre.x+xOffset,lCentre.y+yOffset);
			} else { //left
				p = ccp(lCentre.x+xOffset,lCentre.y-yOffset);
			}
		}
	}
	return p;
	
}

- (void)setActive:(BOOL)active {
	if (active) {
		[curve setColor:ccc3(0, 255, 0)];
		[curve setWidth:1.2f];
		[self removeChild:arrowhead cleanup:NO];
		[self removeChild:activeArrowhead cleanup:NO];
		[self addChild:activeArrowhead z:3 tag:14];
	} else {
		[curve setColor:ccc3(0, 0, 0)];
		[curve setWidth:1.0f];
		[self removeChild:arrowhead cleanup:NO];
		[self removeChild:activeArrowhead cleanup:NO];
		[self addChild:arrowhead z:3 tag:14];
	}
}
- (void)setCurvePointsFromTransition:(iAutomataTransition*)t {
	CGPoint p0_,p0_a,p2_,p2_a,p1;
	CGPoint p0 = [[t getFromState] getPosition];
	CGPoint p2 = [[t getToState] getPosition];
	int dx = p0.x - p2.x;
	int dy = p0.y - p2.y;
	float theta = atanf((float)abs(dy)/(float)abs(dx));
	int xOffset = 30 * cosf(theta);
	int yOffset = 30 * sinf(theta);
	
	if (dx == 0 && dy == 0) {
		p0_a = p0;
		p2_a = p2;
		p1 = p0;
	} else if (dx == 0) { // on same vertical line
		if (dy < 0) { // upwards
			p0_ = ccp(0,30);
			p0_a = ccp(-15+p0.x,25+p0.y);
			
			p2_ = ccp(0,-30);
			p2_a = ccp(-15+p2.x,-25+p2.y);
		} else { // downwards
			p0_ = ccp(0,-30);
			p0_a = ccp(15+p0.x,-25+p0.y);
			
			p2_ = ccp(0,30);
			p2_a = ccp(15+p2.x,25+p2.y);
		}
	} else if (dy == 0) { // on same horizontal line
		if (dx < 0) { // rightwards
			p0_ = ccp(30,0);
			p0_a = ccp(25+p0.x,15+p0.y);
			
			p2_ = ccp(-30,0);
			p2_a = ccp(-25+p2.x,15+p2.y);
		} else { // leftwards
			p0_ = ccp(-30,0);
			p0_a = ccp(-25+p0.x,-15+p0.y);
			
			p2_ = ccp(30,0);
			p2_a = ccp(25+p2.x,-15+p2.y);
		}
	} else {
		if (dy < 0) { //upwards
			if (dx < 0) { //rightwards
				p0_ = ccp(xOffset,yOffset);
				p0_a.x = (int)(((float)p0_.x*cosf(M_PI/4.0f))-((float)p0_.y*sinf(M_PI/4.0f)) + p0.x);
				p0_a.y = (int)(((float)p0_.x*sinf(M_PI/4.0f))+((float)p0_.y*cosf(M_PI/4.0f)) + p0.y);
				
				p2_ = ccp(-xOffset,-yOffset);
				p2_a.x = (int)(((float)p2_.x*cosf(-M_PI/4.0f))-((float)p2_.y*sinf(-M_PI/4.0f)) + p2.x);
				p2_a.y = (int)(((float)p2_.x*sinf(-M_PI/4.0f))+((float)p2_.y*cosf(-M_PI/4.0f)) + p2.y);
			} else { //leftwards
				p0_ = ccp(-xOffset,yOffset);
				p0_a.x = (int)(((float)p0_.x*cosf(M_PI/4.0f))-((float)p0_.y*sinf(M_PI/4.0f)) + p0.x);
				p0_a.y = (int)(((float)p0_.x*sinf(M_PI/4.0f))+((float)p0_.y*cosf(M_PI/4.0f)) + p0.y);
				
				p2_ = ccp(xOffset,-yOffset);
				p2_a.x = (int)(((float)p2_.x*cosf(-M_PI/4.0f))-((float)p2_.y*sinf(-M_PI/4.0f)) + p2.x);
				p2_a.y = (int)(((float)p2_.x*sinf(-M_PI/4.0f))+((float)p2_.y*cosf(-M_PI/4.0f)) + p2.y);
			}
		} else { //downwards
			if (dx < 0) { //rightwards
				p0_ = ccp(xOffset,-yOffset);
				p0_a.x = (int)(((float)p0_.x*cosf(M_PI/4.0f))-((float)p0_.y*sinf(M_PI/4.0f)) + p0.x);
				p0_a.y = (int)(((float)p0_.x*sinf(M_PI/4.0f))+((float)p0_.y*cosf(M_PI/4.0f)) + p0.y);
				
				p2_ = ccp(-xOffset,yOffset);
				p2_a.x = (int)(((float)p2_.x*cosf(-M_PI/4.0f))-((float)p2_.y*sinf(-M_PI/4.0f)) + p2.x);
				p2_a.y = (int)(((float)p2_.x*sinf(-M_PI/4.0f))+((float)p2_.y*cosf(-M_PI/4.0f)) + p2.y);
			} else { //leftwards
				p0_ = ccp(-xOffset,-yOffset);
				p0_a.x = (int)(((float)p0_.x*cosf(M_PI/4.0f))-((float)p0_.y*sinf(M_PI/4.0f)) + p0.x);
				p0_a.y = (int)(((float)p0_.x*sinf(M_PI/4.0f))+((float)p0_.y*cosf(M_PI/4.0f)) + p0.y);
				
				p2_ = ccp(xOffset,yOffset);
				p2_a.x = (int)(((float)p2_.x*cosf(-M_PI/4.0f))-((float)p2_.y*sinf(-M_PI/4.0f)) + p2.x);
				p2_a.y = (int)(((float)p2_.x*sinf(-M_PI/4.0f))+((float)p2_.y*cosf(-M_PI/4.0f)) + p2.y);
			}
		}

	}
	p1 = [self curvePointWithP0:p0_a P1:p2_a];
	[curve setPoint:p0_a atIndex:0];
	[curve setPoint:p1 atIndex:1];
	[curve setPoint:p2_a atIndex:2];
	[label setPosition:p1];
	[arrowhead setPosition:p2_a];
	[activeArrowhead setPosition:p2_a];
	[self setArrowheadRotationAngleWithPoint0:p1 Point1:p2_a];
}
- (void)setArrowheadRotationAngleWithPoint0:(CGPoint)p0 Point1:(CGPoint)p1 {
	/* find rotation angle for arrowhead */
	[arrowhead setVisible:YES];
	float rotationAngle = 0.0f;
	int dx = p1.x - p0.x;
	int dy = p1.y - p0.y;
	
	if (dx == 0 && dy == 0) {
		[arrowhead setVisible:NO];
	} else if (dx == 0) { // vertical
		if (dy < 0) { // down
			rotationAngle = 180.0f;
		} else { // up
			rotationAngle = 0.0f;
		}
	} else if (dy == 0) { // horizontal
		if (dx < 0) { // left
			rotationAngle = 270.0f;
		} else { // right
			rotationAngle = 90.0f;
		}
	} else if (dx < 0) { // left
		float theta = atanf((float)abs(dy)/(float)abs(dx));
		if (dy < 0) { // down
			rotationAngle = 180 + (90 - theta*180/M_PI);
		} else { // up
			rotationAngle = 270 + theta*180/M_PI;
		}
	} else { // right
		float theta = atanf((float)abs(dy)/(float)abs(dx));
		if (dy < 0) { // down
			rotationAngle = 90 + theta*180/M_PI;
		} else { // up
			rotationAngle = 90 - theta*180/M_PI;
		}
	}
	[arrowhead setRotation:rotationAngle];
	[activeArrowhead setRotation:rotationAngle];
}
- (iAutomataTransition*)getTransition {
	return transition;
}
- (CGPoint)curvePointWithStateCentre:(CGPoint)pCentre {
	CGPoint origin = ccp([iAutomataDiagram getSize].width/2,[iAutomataDiagram getSize].height/2);
	//NSLog(@"Origin: (%d,%d) Point Centre: (%d,%d)",(int)origin.x,(int)origin.y,(int)pCentre.x,(int)pCentre.y);
	int dx = origin.x - pCentre.x;
	int dy = origin.y - pCentre.y;
	if (dx == 0 && dy == 0) {
		return ccp(origin.x,50+origin.y);
	} else if (dx == 0) { // vertical middle
		if (dy < 0) { // up
			return ccp(pCentre.x,pCentre.y+50);
		} else { // down
			return ccp(pCentre.x,pCentre.y-50);
		}
	} else if (dy == 0) { // horizontal middle
		if (dx < 0) { // right
			return ccp(pCentre.x+50,pCentre.y);
		} else { // left
			return ccp(pCentre.x-50,pCentre.y);
		}
	} else {
		int l = (int) sqrtf(dx*dx+dy*dy) +50;
		float theta = atanf((float)abs(dy)/(float)abs(dx));
		int dx_ = (int)(l * cosf(theta));
		int dy_ = (int)(l * sinf(theta));		
		if (dx < 0) { // left
			if (dy > 0) { // up
				return ccp(origin.x+dx_, origin.y-dy_);
			} else { // down
				return ccp(origin.x+dx_, origin.y+dy_);
			}
		} else { // right
			if (dy > 0) { // up
				return ccp(origin.x-dx_, origin.y-dy_);
			} else { // down
				return ccp(origin.x-dx_, origin.y+dy_);
			}
		}
	}
}
-(void)setCurvePointsFromSelfTransition:(iAutomataTransition*)t {
	CGPoint pCentre = [[t getFromState] getPosition];
	CGPoint p0 = [[transition getFromState] anchorL];
	CGPoint p2 = [[transition getToState] anchorB];
	CGPoint p1, pa;
	CGPoint origin = ccp([iAutomataDiagram getSize].width/2,[iAutomataDiagram getSize].height/2);
	
	//x' = Cos(Theta) * x - Sin(Theta) * y
	//y' = Sin(Theta) * x + Cos(Theta) * y	
	
	int dx = origin.x - pCentre.x;
	int dy = origin.y - pCentre.y;
	if (dx == 0 && dy == 0) {
		p1 = ccp(origin.x,70+origin.y);
		pa = ccp(0,30);
		p0.x = ((int)((float)pa.x * cosf(M_PI/4.0f) - (float)pa.y * sinf(M_PI/4.0f)))+origin.x;
		p0.y = ((int)((float)pa.x * sinf(M_PI/4.0f) + (float)pa.y * cosf(M_PI/4.0f)))+origin.y;
		p2.x = ((int)((float)pa.x * cosf(-M_PI/4.0f) - (float)pa.y * sinf(-M_PI/4.0f)))+origin.x;
		p2.y = ((int)((float)pa.x * sinf(-M_PI/4.0f) + (float)pa.y * cosf(-M_PI/4.0f)))+origin.y;
	} else if (dx == 0) { // vertical middle
		if (dy < 0) { // up
			p1 = ccp(pCentre.x,pCentre.y+70);
			pa = ccp(0,30);
			p0.x = ((int)((float)pa.x * cosf(M_PI/4.0f) - (float)pa.y * sinf(M_PI/4.0f)))+pCentre.x;
			p0.y = ((int)((float)pa.x * sinf(M_PI/4.0f) + (float)pa.y * cosf(M_PI/4.0f)))+pCentre.y;
			p2.x = ((int)((float)pa.x * cosf(-M_PI/4.0f) - (float)pa.y * sinf(-M_PI/4.0f)))+pCentre.x;
			p2.y = ((int)((float)pa.x * sinf(-M_PI/4.0f) + (float)pa.y * cosf(-M_PI/4.0f)))+pCentre.y;
		} else { // down
			p1 = ccp(pCentre.x,pCentre.y-70);
			pa = ccp(0,-30);
			p0.x = ((int)((float)pa.x * cosf(M_PI/4.0f) - (float)pa.y * sinf(M_PI/4.0f)))+pCentre.x;
			p0.y = ((int)((float)pa.x * sinf(M_PI/4.0f) + (float)pa.y * cosf(M_PI/4.0f)))+pCentre.y;
			p2.x = ((int)((float)pa.x * cosf(-M_PI/4.0f) - (float)pa.y * sinf(-M_PI/4.0f)))+pCentre.x;
			p2.y = ((int)((float)pa.x * sinf(-M_PI/4.0f) + (float)pa.y * cosf(-M_PI/4.0f)))+pCentre.y;
		}
	} else if (dy == 0) { // horizontal middle
		if (dx < 0) { // right
			p1 = ccp(pCentre.x+70,pCentre.y);
			pa = ccp(30,0);
			p0.x = ((int)((float)pa.x * cosf(M_PI/4.0f) - (float)pa.y * sinf(M_PI/4.0f)))+pCentre.x;
			p0.y = ((int)((float)pa.x * sinf(M_PI/4.0f) + (float)pa.y * cosf(M_PI/4.0f)))+pCentre.y;
			p2.x = ((int)((float)pa.x * cosf(-M_PI/4.0f) - (float)pa.y * sinf(-M_PI/4.0f)))+pCentre.x;
			p2.y = ((int)((float)pa.x * sinf(-M_PI/4.0f) + (float)pa.y * cosf(-M_PI/4.0f)))+pCentre.y;
		} else { // left
			p1 = ccp(pCentre.x-70,pCentre.y);
			pa = ccp(-30,0);
			p0.x = ((int)((float)pa.x * cosf(M_PI/4.0f) - (float)pa.y * sinf(M_PI/4.0f)))+pCentre.x;
			p0.y = ((int)((float)pa.x * sinf(M_PI/4.0f) + (float)pa.y * cosf(M_PI/4.0f)))+pCentre.y;
			p2.x = ((int)((float)pa.x * cosf(-M_PI/4.0f) - (float)pa.y * sinf(-M_PI/4.0f)))+pCentre.x;
			p2.y = ((int)((float)pa.x * sinf(-M_PI/4.0f) + (float)pa.y * cosf(-M_PI/4.0f)))+pCentre.y;
		}
	} else {
		int l1 = (int) sqrtf(dx*dx+dy*dy) +70;
		int l2 = l1 - 40;
		float theta = atanf((float)abs(dy)/(float)abs(dx));
		int dx_ = (int)(l1 * cosf(theta));
		int dy_ = (int)(l1 * sinf(theta));
		pa.x = (int)(l2 * cosf(theta));
		pa.y = (int)(l2 * sinf(theta));
		int pdx = pa.x - abs(dx);
		int pdy = pa.y - abs(dy);
		//NSLog(@"dx dy: (%d,%d) pa.x pa.y: (%d,%d) dx_ dy_: (%d,%d)",abs(dx),abs(dy),(int)pa.x,(int)pa.y,(int)dx_,(int)dy_);
		
		if (dx < 0) { // left
			if (dy > 0) { // up
				p1 = ccp(origin.x+dx_, origin.y-dy_);
				pdy = -pdy;
			} else { // down
				p1 = ccp(origin.x+dx_, origin.y+dy_);
				//pdx = -pdx; pdy = -pdy;
			}
		} else { // right
			if (dy > 0) { // up
				p1 = ccp(origin.x-dx_, origin.y-dy_);
				pdx = -pdx; pdy = -pdy;
			} else { // down
				p1 = ccp(origin.x-dx_, origin.y+dy_);
				pdx = -pdx;
			}
		}
		//NSLog(@"pd: (%d,%d)",pdx,pdy);
		p0.x = ((int)((float)pdx * cosf(M_PI/4.0f) - (float)pdy * sinf(M_PI/4.0f))+pCentre.x);
		p0.y = ((int)((float)pdx * sinf(M_PI/4.0f) + (float)pdy * cosf(M_PI/4.0f))+pCentre.y);
		p2.x = ((int)((float)pdx * cosf(-M_PI/4.0f) - (float)pdy * sinf(-M_PI/4.0f))+pCentre.x);
		p2.y = ((int)((float)pdx * sinf(-M_PI/4.0f) + (float)pdy * cosf(-M_PI/4.0f))+pCentre.y);
	}
	[label setPosition:p1];
	[curve setPoint:p1 atIndex:1];
	[curve setPoint:p0 atIndex:0];
	[curve setPoint:p2 atIndex:2];
	[arrowhead setPosition:p2];
	[activeArrowhead setPosition:p2];
	[self setArrowheadRotationAngleWithPoint0:p1 Point1:p2];
}
-(FRCurve*)getCurve {
    return curve;
}
@end
