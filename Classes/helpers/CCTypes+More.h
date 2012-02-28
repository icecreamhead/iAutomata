/**
 *  CCTypes+More.h
 *
 *  Created by Lam Pham on 23/10/09.
 *  Copyright 2009 Fancy Rat Studios Inc. All rights reserved.
 *
 *	There are some extensions to conveniently cast color types.
 */

#import "ccTypes.h"

#ifdef __cplusplus
extern "C" {
#endif
  
#define kCGPointEpsilon FLT_EPSILON
	
  typedef struct {
    float l,b,r,t;
  } ccEdge;
	  
  static const ccEdge ccEdgeZero = {0.f,0.f,0.f,0.f};
  
  static inline ccEdge ccEdgeMake(float lrbt)
  {
    return (ccEdge){lrbt, lrbt, lrbt, lrbt};
  }
	
  static inline ccEdge ccEdgeMake2(float lr, float bt)
  {
    return (ccEdge){lr, bt, lr, bt};
  }
  static inline ccEdge ccEdgeMake4(float l, float b, float r, float t)
  {
    return (ccEdge){l, b, r, t};
  }
  
  static inline ccEdge ccEdgeFromccp(CGPoint point)
  {
    return ccEdgeMake2(point.x, point.y);
  }
  
  static inline ccEdge ccEdgeNeg(ccEdge padding)
  {
    return (ccEdge){-padding.l, -padding.b, -padding.r, -padding.t};
  }
  
  static inline CGRect CGRectFromccEdge(CGRect rect, ccEdge padding)
  {
    CGRect newRect = rect;
    newRect.origin.x += padding.l;
    newRect.origin.y += padding.b;
    newRect.size.width -= (padding.r + padding.l);
    newRect.size.height -= (padding.t+ padding.b);
    return newRect;
  }
	
	typedef struct {
		float r,g,b;
	} ccColor3F;
	
	static inline ccColor3F ccc3FFromccc3B(ccColor3B c)
	{
		return (ccColor3F){c.r/255.f, c.g/255.f, c.b/255.f};
	}
	
	static inline ccColor3B ccc3BFromccc3F(ccColor3F c)
	{
		return (ccColor3B){c.r*255, c.g*255.f, c.b*255.f};
	}
	
	static inline ccColor3F ccc3FFromccc4B(ccColor4B c)
	{
		return (ccColor3F){c.r/255.f, c.g/255.f, c.b/255.f};
	}
	
	static inline ccColor3B ccc3BFromccc4B(ccColor4B c)
	{
		return (ccColor3B){c.r, c.g, c.b};
	}
	
	static inline ccColor4B ccc4BFromccc3B(ccColor3B c)
	{
		return (ccColor4B){c.r, c.g, c.b, 255};
	}
	
	static inline void HSVtoRGB( float *r, float *g, float *b, float h, float s, float v )
	{
		int i;
		float f, p, q, t;
		if( s == 0 ) {
			// achromatic (grey)
			*r = *g = *b = v;
			return;
		}
		h /= 60;			// sector 0 to 5
		i = floorf( h );
		f = h - i;			// factorial part of h
		p = v * ( 1 - s );
		q = v * ( 1 - s * f );
		t = v * ( 1 - s * ( 1 - f ) );
		switch( i ) {
			case 0:
				*r = v;
				*g = t;
				*b = p;
				break;
			case 1:
				*r = q;
				*g = v;
				*b = p;
				break;
			case 2:
				*r = p;
				*g = v;
				*b = t;
				break;
			case 3:
				*r = p;
				*g = q;
				*b = v;
				break;
			case 4:
				*r = t;
				*g = p;
				*b = v;
				break;
			default:		// case 5:
				*r = v;
				*g = p;
				*b = q;
				break;
		}
	}
	
	static inline ccColor3B ccc3BFromHSV(float h, float s, float v)
	{
		ccColor3F c;
		HSVtoRGB(&c.r, &c.g, &c.b, h, s, v);
		return ccc3BFromccc3F(c);
	}
	
	static inline NSString *NSStringFromCCTime(ccTime time)
	{
		NSMutableString *str = [NSMutableString string];
		int iTime = (int)time;
		//short hours = time/3600;
		//[str appendFormat:@"%d",hours];
		iTime %= 3600;
		[str appendFormat:@"%02d",iTime/60];
		iTime %= 60;
		[str appendFormat:@":%02d",iTime];
		return str;
	}
	
	static inline CGSize CGSizeFromCGPoint(CGPoint pt)
	{
		return CGSizeMake(pt.x, pt.y);
	}
	
#ifdef __cplusplus
}
#endif
