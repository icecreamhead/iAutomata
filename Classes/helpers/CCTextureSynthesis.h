/**
 *  CCTextureShapes.h
 *
 *  Created by Lam Pham on 3/18/10.
 *  Copyright 2010 Fancy Rat Studios Inc. All rights reserved.
 *
 *	Some Texture Synthesis functions
 */
#ifdef __cplusplus
extern "C" {
#endif	
	
#import <UIKit/UIKit.h>
	static inline CGContextRef ccTexGenContext(CGSize s)
	{
		int tx = s.width;
		int ty = s.height;
		
		int bitsPerComponent			= 8;
		//int bitsPerPixel				= 32;
		int bytesPerPixel				= (bitsPerComponent * 4)/8;
		int bytesPerRow					= bytesPerPixel * tx;
		//NSInteger myDataLength			= bytesPerRow * ty;
		
		CGBitmapInfo bitmapInfo			= kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault;
		
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGContextRef context = CGBitmapContextCreate(nil, tx, ty, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo);
		CGColorSpaceRelease(colorSpace);
		return context;
	}
	
	static inline UIImage* UIImageFromRectData(NSDictionary *rectData)
	{
		CGSize size = CGSizeFromString([rectData valueForKeyPath:@"size"]);
		float border = [[rectData valueForKeyPath:@"border"] floatValue];
		float radius = [[rectData valueForKeyPath:@"radius"] floatValue];
		float shadowBlur = 0.f;
		
		if([rectData valueForKeyPath:@"shadow-blur"]){
			shadowBlur = [[rectData valueForKeyPath:@"shadow-blur"] floatValue];
		}
		
		CGContextRef context = ccTexGenContext(CGSizeMake(size.width+(border+shadowBlur)*2,size.height+(border+shadowBlur)*2));
		CGContextSetLineCap(context, kCGLineCapRound);
		
		CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
		CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.f);
		
		if ([rectData valueForKeyPath:@"stroke-color"]) {
			CGRect color = CGRectFromString([rectData valueForKeyPath:@"stroke-color"]);
			CGContextSetRGBStrokeColor(context, color.origin.x, color.origin.y, color.size.width, color.size.height);
		}
		if ([rectData valueForKeyPath:@"fill-color"]) {
			CGRect color = CGRectFromString([rectData valueForKeyPath:@"fill-color"]);
			CGContextSetRGBFillColor(context, color.origin.x, color.origin.y, color.size.width, color.size.height);
		}
		
		if(shadowBlur > 0.f){
			float shadowColor[] = {0, 0, 0, 1.f};
			CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
			CGColorRef color = CGColorCreate(colorSpace,shadowColor);
			CGColorSpaceRelease(colorSpace);
			CGContextSetShadowWithColor(context, CGSizeZero, shadowBlur, color);
			CGColorRelease(color);
		}
		
		CGContextSetLineWidth(context, border);
		CGRect rrect = CGRectMake((border+shadowBlur), (border+shadowBlur), size.width , size.height );
		// Make sure corner radius isn't larger than half the shorter side
		if (radius > size.width/2.0)
			radius = size.width/2.0;
		if (radius > size.height/2.0)
			radius = size.height/2.0; 
		CGFloat minx = CGRectGetMinX(rrect);
		CGFloat midx = CGRectGetMidX(rrect);
		CGFloat maxx = CGRectGetMaxX(rrect);
		CGFloat miny = CGRectGetMinY(rrect);
		CGFloat midy = CGRectGetMidY(rrect);
		CGFloat maxy = CGRectGetMaxY(rrect);
		CGContextMoveToPoint(context, minx, midy);
		CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
		CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
		CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
		CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
		
		CGContextClosePath(context);
		CGContextDrawPath(context, kCGPathFillStroke);
		CGImageRef cgImage = CGBitmapContextCreateImage(context);
		UIImage *image = [UIImage imageWithCGImage:cgImage];
		CGImageRelease(cgImage);
		CGContextRelease(context);
		return image;
	}
#ifdef __cplusplus
}
#endif