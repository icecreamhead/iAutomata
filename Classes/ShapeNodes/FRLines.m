///
//  CCLines.m
//
//  Created by Lam Pham on 11/13/09.
//  Copyright 2009 FancyRatStudios. All rights reserved.
//	@see header for full info
///

#import "FRLines.h"
#import "CCTextureSynthesis.h"
#import "CCTextureCache+More.h"
#import "CCDrawingPrimitives.h"

#pragma mark -
#pragma mark Paths
#pragma mark -	

const float QuadLagrangePinnedKnot[QuadLagrangeKnotCount] = {0.f, 0.5f, 1.f};
const float CubicLagrangePinnedKnot[CubicLagrangeKnotCount] = {0.f, 0.33f, 0.66f, 1.f};

ccpCurveCubicParams ccpCubicParamsMake(CGPoint start, CGPoint cp1, CGPoint cp2, CGPoint end)
{
	return (ccpCurveCubicParams){start, cp1, cp2, end};
}

ccpCurveQuadParams ccpQuadParamsMake(CGPoint start, CGPoint cp1, CGPoint end)
{
	return (ccpCurveQuadParams){start, cp1, end};
}

CGPoint ccpAitkenLagrangeStep(ccTime t, const CGPoint *CP, int CPCount, const float *ti, float tiCount)
{
	float *bF = malloc(tiCount*sizeof(float)); 
	for (int j = 0; j < tiCount; ++j){
		float P = 1;
		for (int i = 0; i < tiCount; ++i){
			if (i != j) 
				P = P*(t-ti[i])/(ti[j] - ti[i]);
		}
		bF[j] = P;
	}
	
	CGPoint pt = CGPointZero;
	for(int j = 0; j < CPCount; ++j){
		pt = ccpAdd(pt,ccpMult(CP[j],bF[j]));
	}
	free(bF);
	return pt;
}

void ccpAitkenLagrange(ccpCurve *curve,
					   const CGPoint *CP, int CPCount, 
					   const float *ti, float tiCount)
{
	if(curve->verticesCount < 2 || CPCount != tiCount)return;
	if(!curve->vertices || !CP || !ti) return;
	
	float step = 1.f/(curve->verticesCount - 1), t = 0.f;
	for (int k = 0; k < curve->verticesCount; ++k){
		curve->vertices[k] = ccpAitkenLagrangeStep(t, CP, CPCount, ti, tiCount);
		t += step;
	}
	curve->dirty = YES;
}



ccpCurve* ccpCurveQuadLagrange(int verticesCount, ccpCurveQuadParams params)
{
	ccpCurve *curve = ccpCurveMake(verticesCount);
	ccpAitkenLagrange(curve, (CGPoint*)&params, QuadLagrangeKnotCount, QuadLagrangePinnedKnot, QuadLagrangeKnotCount);
	return curve;
}



ccpCurve* ccpCurveCubicLagrange(int verticesCount, ccpCurveCubicParams params)
{
	ccpCurve *curve = ccpCurveMake(verticesCount);
	ccpAitkenLagrange(curve, (CGPoint*)&params, CubicLagrangeKnotCount, CubicLagrangePinnedKnot, CubicLagrangeKnotCount);
	return curve;
}

CGPoint ccpDeCasteljauBezierStep(ccTime dt, const CGPoint *CP, int CPCount)
{
	
	CGPoint *Pi = malloc(CPCount*sizeof(CP[0]));
	memcpy(Pi, CP, CPCount*sizeof(CP[0]));
	for (int j = CPCount-1; j > 0; j--){
		for (int i = 0; i < j; i++){
			Pi[i] = (ccpLerp(Pi[i], Pi[i+1], dt));
		}
	}
	CGPoint pt = Pi[0];
	free(Pi);
	return pt;
}

void ccpDeCasteljauBezier(ccpCurve *curve, const CGPoint *CP, int CPCount)
{
	if(!curve)return;
	if(curve->verticesCount < 2)return;
	if(!CP) return;
	float step = 1.f/(curve->verticesCount - 1), t = 0.f;
	
	for (int k = 0; k < curve->verticesCount; ++k){
		curve->vertices[k] = ccpDeCasteljauBezierStep(t, CP, CPCount);
		t += step;
	}
	curve->dirty = YES;
}

ccpCurve* ccpCurveQuadBezier(int verticesCount, ccpCurveQuadParams params)
{
	ccpCurve *curve = ccpCurveMake(verticesCount);
	ccpDeCasteljauBezier(curve, (CGPoint*)&params, 3);
	curve->dirty = YES;
	return curve;
}

ccpCurve* ccpCurveCubicBezier(int verticesCount, ccpCurveCubicParams params)
{
	ccpCurve *curve = ccpCurveMake(verticesCount);
	ccpDeCasteljauBezier(curve, (CGPoint*)&params, 4);
	curve->dirty = YES;
	return curve;
}

ccpCurve* ccpCurveMake(int verticesCount)
{
	ccpCurve *curve = malloc(sizeof(ccpCurve));
	curve->verticesCount = verticesCount;
	curve->vertices = malloc(verticesCount*sizeof(CGPoint));
	curve->vertexGL = 0;
	curve->vertexGLCount = 0;
	curve->texture = nil;
	curve->widthFunc = &ccpCurveWidthStandard;
	curve->width = 1;
	curve->color = ccWHITE;
	curve->opacity = 255;
	curve->dirty = YES;
	return curve;
}

void ccpCurveRelease(ccpCurve *curve)
{
	[curve->texture release];
	curve->texture = nil;
	free(curve->vertexGL);
	curve->vertexGL = 0;
	curve->vertexGLCount = 0;
	free(curve->vertices);
	curve->vertices = 0;
	curve->verticesCount = 0;
	free(curve);
}

ccpCurveCubicParams ccpCubicFromQuadBezier(ccpCurveQuadParams bezier)
{
	ccpCurveCubicParams params;
	params.start = bezier.start;
	params.end = bezier.end;
	params.cp1 = ccpLerp(bezier.cp1 , bezier.start, 2.f/3.f);
	params.cp2 = ccpLerp(bezier.cp1 , bezier.end, 2.f/3.f);
	return params;
}

static unsigned int ccCurveNextPOT(unsigned int x)
{
    x = x - 1;
    x = x | (x >> 1);
    x = x | (x >> 2);
    x = x | (x >> 4);
    x = x | (x >> 8);
    x = x | (x >>16);
    return x + 1;
}

UIImage* makeLineTexture(float radius)
{
	radius = radius + 2;
	CGContextRef context = ccTexGenContext(CGSizeMake(radius*2, radius*2));	
	CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
	CGContextFillEllipseInRect(context, CGRectMake(1, 1, radius*2-2, radius*2-2));
	CGImageRef cgImage = CGBitmapContextCreateImage(context);
	UIImage *image = [UIImage imageWithCGImage:cgImage];
	CGImageRelease(cgImage);
	CGContextRelease(context);	
	return image;
}

void __ccpCurveDrawTexture(ccpCurve *curve){
	if (!curve || !curve->vertices) {
		return;
	}
	if (curve->dirty) {
		if (curve->vertexGL) {
			free(curve->vertexGL);
			curve->vertexGL = NULL;
			curve->vertexGLCount = 0;
		}
		
		if (curve->texture) {
			[curve->texture release];
			curve->texture = nil;
		}
		
		//	Since the actual texture line has a 1px gap around the edge we add
		//	2px radius.
		float radius = (curve->width*CC_CONTENT_SCALE_FACTOR())/2.f+2.f;
		
		//	Synthesize the texture that we need to draw a smooth line
		int pot = ccCurveNextPOT(radius+2);
		NSString *texFilename = [NSString stringWithFormat:@"line-%d.cg",pot];
		if (![[CCTextureCache sharedTextureCache]containsFilename:texFilename]) {
			curve->texture = [[[CCTextureCache sharedTextureCache]addCGImage:[makeLineTexture(pot)CGImage] forKey:texFilename] retain];
		} else {
			curve->texture = [[[CCTextureCache sharedTextureCache]addImage:texFilename]retain];
		}
				
		ccColor4B colors = ccc4BFromccc3B(curve->color);
		colors.a = curve->opacity;
		
		float curveCount = curve->verticesCount + 2;
		
		curve->vertexGLCount = curve->verticesCount*2 + 4;
		curve->vertexGL = malloc(curve->vertexGLCount * sizeof(ccV3F_C4B_T2F));
		
		bzero(curve->vertexGL,curve->vertexGLCount * sizeof(ccV3F_C4B_T2F));
		
		CGPoint start = ccpMult(curve->vertices[0], CC_CONTENT_SCALE_FACTOR());
		CGPoint end = ccpMult(curve->vertices[1], CC_CONTENT_SCALE_FACTOR());
		CGPoint dir = ccpNormalize(ccpSub(end, start));
		CGPoint n = ccpPerp(dir);
		
		float widthVar = curve->widthFunc(curve, 0.f, true);
		
		//	Creates the starting vertices which are for the rounded endpoint
		CGPoint v = ccpAdd(ccpSub(start,ccpMult(dir, radius*widthVar)), ccpMult(n, radius*widthVar));
		curve->vertexGL[0].vertices = (ccVertex3F){v.x, v.y, 0.f};
		curve->vertexGL[0].texCoords = (ccTex2F){0.f, 0.f};
		curve->vertexGL[0].colors = colors;
		
		widthVar = curve->widthFunc(curve, 0.f, false);
		v = ccpAdd(ccpSub(start,ccpMult(dir, radius*widthVar)), ccpMult(n, -radius*widthVar));
		curve->vertexGL[1].vertices = (ccVertex3F){v.x, v.y,0.f};
		curve->vertexGL[1].texCoords = (ccTex2F){0.f, curve->texture.maxT};
		curve->vertexGL[1].colors = colors;
		
		
		//	For each vertices offset to create a wider curve
		for (int i = 0; i < curve->verticesCount; i++) {
			
			//	We grab the two points that can give us a tangent
			//	We also make sure we don't access out of the array bounds
			start = ccpMult(curve->vertices[i], CC_CONTENT_SCALE_FACTOR());
			
			if(0 <= i-1 && i+1 < curve->verticesCount) {
				CGPoint a = ccpMult(curve->vertices[i-1], CC_CONTENT_SCALE_FACTOR());
				CGPoint b = ccpMult(curve->vertices[i+1], CC_CONTENT_SCALE_FACTOR());
				dir = ccpNormalize(ccpAdd(ccpSub(start, a),ccpSub(b, start)));
			} else if (i+1 < curve->verticesCount) {
				end = ccpMult(curve->vertices[i + 1], CC_CONTENT_SCALE_FACTOR());
				dir = ccpNormalize(ccpSub(end, start));
			} else {
				end = ccpMult(curve->vertices[i - 1], CC_CONTENT_SCALE_FACTOR());
				dir = ccpNormalize(ccpSub(start, end));
			}
			
			n = ccpPerp(dir);
			float a = (i+1)/curveCount;
			widthVar = curve->widthFunc(curve, a, true);
			v = ccpAdd(start, ccpMult(n, radius*widthVar));
			int i1 = i*2+2;
			curve->vertexGL[i1].vertices = (ccVertex3F){v.x,v.y,0.f};
			curve->vertexGL[i1].texCoords = (ccTex2F){curve->texture.maxS/2,0.0f};
			curve->vertexGL[i1].colors = colors;
			
			int i2 = i*2+3;
			widthVar = curve->widthFunc(curve, a, false);
			v = ccpAdd(start, ccpMult(n, -radius*widthVar));
			curve->vertexGL[i2].vertices = (ccVertex3F){v.x,v.y,0.f};
			curve->vertexGL[i2].texCoords = (ccTex2F){curve->texture.maxS/2, curve->texture.maxT};
			curve->vertexGL[i2].colors = colors;
			
		}
		
		//	The endpoint rounded image
		start = ccpMult(curve->vertices[curve->verticesCount-2], CC_CONTENT_SCALE_FACTOR());
		end = ccpMult(curve->vertices[curve->verticesCount-1], CC_CONTENT_SCALE_FACTOR());
		dir = ccpNormalize(ccpSub(end, start));
		n = ccpPerp(dir);
		
		widthVar = curve->widthFunc(curve, 1.f, true);
		v = ccpAdd(ccpAdd(end,ccpMult(dir, radius*widthVar)), ccpMult(n, radius*widthVar));
		curve->vertexGL[curve->vertexGLCount-2].vertices = (ccVertex3F){v.x,v.y,0.f};
		curve->vertexGL[curve->vertexGLCount-2].texCoords = (ccTex2F){curve->texture.maxS, 0.f};
		curve->vertexGL[curve->vertexGLCount-2].colors = colors;
		
		widthVar = curve->widthFunc(curve, 1.f, false);
		v = ccpAdd(ccpAdd(end,ccpMult(dir, radius*widthVar)), ccpMult(n, -radius*widthVar));
		curve->vertexGL[curve->vertexGLCount-1].vertices = (ccVertex3F){v.x,v.y,0.f};
		curve->vertexGL[curve->vertexGLCount-1].texCoords = (ccTex2F){curve->texture.maxS, curve->texture.maxT};
		curve->vertexGL[curve->vertexGLCount-1].colors = colors;
		curve->dirty = NO;
	}
	glBindTexture(GL_TEXTURE_2D, [curve->texture name]);
	glVertexPointer(3, GL_FLOAT, sizeof(ccV3F_C4B_T2F), &curve->vertexGL[0].vertices);
	glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(ccV3F_C4B_T2F), &curve->vertexGL[0].colors);
	glTexCoordPointer(2, GL_FLOAT, sizeof(ccV3F_C4B_T2F), &curve->vertexGL[0].texCoords);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, curve->vertexGLCount);
}

void ccpCurveDraw(ccpCurve *curve)
{
	if (curve->width == 1.f) {
		if (!curve->smoothHint) {
			glLineWidth(1.f);
			glEnable (GL_LINE_SMOOTH);
			glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
			curve->smoothHint = YES;
		}
		glColor4ub(curve->color.r, curve->color.g, curve->color.b, curve->opacity);
		glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		ccDrawPoly( curve->vertices, curve->verticesCount, NO);
	} else if (curve->width > 1.f) {
		if (curve->smoothHint) {
			glLineWidth(1.f);
			glDisable (GL_LINE_SMOOTH);
			glHint(GL_LINE_SMOOTH_HINT, GL_DONT_CARE);
			curve->smoothHint = NO;
		}
		__ccpCurveDrawTexture(curve);
	}
}

void ccpCurveSetWidthFunc(ccpCurve *curve, ccpCurveWidthFunc func)
{
	curve->widthFunc = func;
	curve->dirty = YES;
}

void ccpCurveSetWidth(ccpCurve *curve, float width)
{
	curve->width = width;
	curve->dirty = YES;
}

void ccpCurveSetColor(ccpCurve *curve, ccColor3B color)
{
	curve->color = color;
	curve->dirty = YES;
}

void ccpCurveSetOpacity(ccpCurve *curve, GLubyte opacity)
{
	curve->opacity = opacity;
	curve->dirty = YES;
}


void ccpCurveUpdateQuadBezier(ccpCurve *curve, ccpCurveCubicParams params)
{
	ccpDeCasteljauBezier(curve, (CGPoint*)&params, 3);
}

void ccpCurveUpdateCubicBezier(ccpCurve *curve, ccpCurveCubicParams params)
{
	ccpDeCasteljauBezier(curve, (CGPoint*)&params, 4);
}

#pragma mark -
#pragma mark Curve Width Functions
float ccpCurveWidthStandard(const ccpCurve *curve, float a, bool side)
{
	return 1.f;
}

float ccpCurveWidthThinEnd(const ccpCurve *curve, float a, bool side)
{
	return fabsf(sinf(a*M_PI));
}

float ccpCurveWidthRibbon(const ccpCurve *curve, float a, bool side)
{
	return fabsf(sinf(a*M_PI*8));
}

float ccpCurveWidthWiggly(const ccpCurve *curve, float a, bool side)
{
	return side? sinf(a*M_PI*8)*.5f+.5f : sinf(a*M_PI*8 + M_PI/2.f)*.5f+.5f;
}