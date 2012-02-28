//
//  CCTextureCache+More.h
//
//  Created by Lam Pham on 5/20/10.
//  Copyright 2010 Fancy Rat Studios Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCTextureCache (Search)

/**
 *	@param filename
 *		Checks the cache for an existance of this file
 *	@returns if a filename exists in the texture cache
 */
-(BOOL)containsFilename:(NSString*) filename;

/**
 *	@param texture
 *		Checks the cache for the name of this texture
 *	@returns 
 *		filename if it exists in the texture cache for this CCTexture2D
 *		nil if there is no filename for the texture
 */
-(NSString*)filenameForTexture:(CCTexture2D*)texture;

-(NSArray*)allCachedNames;
@end