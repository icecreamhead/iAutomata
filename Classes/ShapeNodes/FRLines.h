///
//  CCLines.h
//
//  Created by Lam Pham on 11/13/09.
//  Copyright 2009 Fancy Rat Studios Inc. All rights reserved.
///

#import <Foundation/Foundation.h>
#import "CGPointExtension.h"
#import "CCTypes+More.h"
#import "CCSprite.h"

#ifdef __cplusplus
extern "C" {
#endif	
	
#pragma mark -
#pragma mark Paths
#pragma mark -	
	
#define QuadLagrangeKnotCount 3
	extern const float QuadLagrangePinnedKnot[QuadLagrangeKnotCount];
#define CubicLagrangeKnotCount 4
	extern const float CubicLagrangePinnedKnot[CubicLagrangeKnotCount];
	
	typedef struct {
		CGPoint		start;
		CGPoint		cp1;
		CGPoint		cp2;
		CGPoint		end;
	} ccpCurveCubicParams;
	
	typedef struct {
		CGPoint		start;
		CGPoint		cp1;
		CGPoint		end;
	} ccpCurveQuadParams;
	
	struct ccpCurve_t;
	typedef float (*ccpCurveWidthFunc)(const struct ccpCurve_t*, float, bool);
	
	struct ccpCurve_t{
		CGPoint *vertices;
		int verticesCount;
		
		ccV3F_C4B_T2F *vertexGL;
		int vertexGLCount;
		float width;
		ccpCurveWidthFunc widthFunc;
		
		BOOL dirty:1;
		BOOL smoothHint:1;
		ccColor3B color;
		GLubyte opacity;
		CCTexture2D *texture;
	};
	
	typedef struct ccpCurve_t ccpCurve;
	
	ccpCurveCubicParams ccpCubicParamsMake(CGPoint start, CGPoint cp1, CGPoint cp2, CGPoint end);
	
	ccpCurveQuadParams ccpQuadParamsMake(CGPoint start, CGPoint cp1, CGPoint end);
	
	///
	//	A set of points representing a quadratic lagrange curve. It uses the Aitken algorithm
	//	to quickly create the points.
	//	Based off of: http://www.ibiblio.org/e-notes/Splines/Lagrange.htm
	//	
	//	@params vertices
	//		an array of vertices that the function will populate with points
	//		NOTE: The array must be already allocated.
	//	@params verticesCount
	//		the size of the vertices array
	//		NOTE: The array size must be greater than 1.
	//	@params params
	//		start
	//			the starting point
	//		cp1
	//			the control point
	//		end
	//			the end point
	///
	ccpCurve* ccpCurveQuadLagrange(int verticesCount, ccpCurveQuadParams params);
	
	///
	//	A set of points representing a cubic lagrange curve. It uses the Aitken algorithm
	//	to quickly create the points.
	//	Based off of: http://www.ibiblio.org/e-notes/Splines/Lagrange.htm
	//	
	//	@params vertices
	//		an array of vertices that the function will populate with points
	//		NOTE: The array must be already allocated.
	//	@params verticesCount
	//		the size of the vertices array
	//		NOTE: The array size must be greater than 1.
	//	@params params
	//		start
	//			the starting point
	//		cp1
	//			the first control point
	//		cp2
	//			the second control point
	//		end
	//			the end point
	///
	ccpCurve* ccpCurveCubicLagrange(int verticesCount, ccpCurveCubicParams params);
	
	
	///
	//	Generally don't use this unless you know what you're doing
	///
	CGPoint ccpDeCasteljauBezierStep(ccTime dt, const CGPoint *CP, int CPCount);
	void ccpDeCasteljauBezier(ccpCurve *curve, const CGPoint *CP, int CPCount);
	CGPoint ccpAitkenLagrangeStep(ccTime t, const CGPoint *CP, int CPCount, const float *ti, float tiCount);
	void ccpAitkenLagrange(ccpCurve *curve, const CGPoint *CP, int CPCount, const float *ti, float tiCount);
	
	///
	//	A set of points representing a cubic bezier curve. It uses the de Casteljau algorithm
	//	to quickly create the points.
	//	Based off of: http://www.ibiblio.org/e-notes/Splines/Bezier.htm
	//	
	//	@params vertices
	//		an array of vertices that the function will populate with points
	//		NOTE: The array must be already allocated.
	//	@params verticesCount
	//		the size of the vertices array
	//		NOTE: The array size must be greater than 1.
	//	@params params
	//		start
	//			the starting point
	//		cp1
	//			the first control point
	//		cp2
	//			the second control point
	//		end
	//			the end point
	///
	ccpCurve* ccpCurveCubicBezier(int verticesCount, ccpCurveCubicParams params);
	
	///
	//	A set of points representing a quadratic bezier curve. It uses the de Casteljau algorithm
	//	to quickly create the points.
	//	Based off of: 
	//		http://www.ibiblio.org/e-notes/Splines/Bezier.htm
	//		http://antigrain.com/research/adaptive_bezier/index.html
	//	
	//	@params vertices
	//		an array of vertices that the function will populate with points
	//		NOTE: The array must be already allocated.
	//	@params verticesCount
	//		the size of the vertices array
	//		NOTE: The array size must be greater than 1.
	//	@params params
	//		start
	//			the starting point
	//		cp1
	//			the control point
	//		end
	//			the end point
	///
	ccpCurve* ccpCurveQuadBezier(int verticesCount, ccpCurveQuadParams params);
	 
	///
	//	Allows us to generate the parameter values of a cubic bezier from a 
	//	quadratic bezier
	///
	ccpCurveCubicParams ccpCubicFromQuadBezier(ccpCurveQuadParams params);
	
	void ccpCurveDraw(ccpCurve *curve);
	ccpCurve* ccpCurveMake(int verticesCount);
	void ccpCurveRelease(ccpCurve *curve);
	
	void ccpCurveSetWidth(ccpCurve *curve, float width);
	void ccpCurveSetWidthFunc(ccpCurve *curve, ccpCurveWidthFunc func);
	void ccpCurveSetColor(ccpCurve *curve, ccColor3B color);
	void ccpCurveSetOpacity(ccpCurve *curve, GLubyte opacity);
	
	void ccpCurveUpdateCubicBezier(ccpCurve *curve, ccpCurveCubicParams params);
	void ccpCurveUpdateQuadBezier(ccpCurve *curve, ccpCurveCubicParams params);
	
#pragma mark -
#pragma mark Curve Width Functions
	float ccpCurveWidthStandard(const ccpCurve *curve, float a, bool side);
	float ccpCurveWidthThinEnd(const ccpCurve *curve, float a, bool side);
	float ccpCurveWidthWiggly(const ccpCurve *curve, float a, bool side);
	float ccpCurveWidthRibbon(const ccpCurve *curve, float a, bool side);
	
#ifdef __cplusplus
}
#endif