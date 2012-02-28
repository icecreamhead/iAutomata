#import "CCTextureCache+More.h"

@implementation CCTextureCache (Search)

-(BOOL)containsFilename:(NSString*) filename
{
	return [textures_ objectForKey:filename] != nil;
}

-(NSString*)filenameForTexture:(CCTexture2D*)texture
{
	NSArray *keys = [textures_ allKeysForObject:texture];
	if ([keys count] == 0) {
		return nil;
	}
	
	NSAssert([keys count] == 1, @"CCTextureCache: There are more than 1 key for this texture!");
	
	return [keys lastObject];
}

-(NSArray*)allCachedNames
{
  return [textures_ allKeys];
}

@end
