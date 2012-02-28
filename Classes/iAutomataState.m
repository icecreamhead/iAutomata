//
//  iAutomataState.m
//  iAutomata
//
//  Created by Josh on 04/01/2011.
//  Copyright 2011 Josh Cooke. All rights reserved.
//

#import "iAutomataState.h"
#import "cocos2d.h"


@implementation iAutomataState
@synthesize radius;
+ (iAutomataState*)initWithName:(NSString *)n coordinates:(CGPoint)pos {
	iAutomataState *q = [[[iAutomataState alloc] init] autorelease];
	if (q) {
		[q setName:n];
		[q setPosition:pos];
		[q setRadius:30];
	}
	
	return q;
}
- (void)setName:(NSString*)n {
	NSLog(@"setting name in state: %@",n);
	name = n;
}
- (NSString*)getName {
	return name;
}
- (CGPoint)getPosition {
	return position;
}
- (CGPoint)anchorTR {
	int offset = (int)sqrt((float)(radius*radius)/(float)2);
	return ccp((int)position.x+offset,(int)position.y+offset);
}
- (CGPoint)anchorBR {
	int offset = (int)sqrt((float)(radius*radius)/(float)2);
	return ccp((int)position.x+offset,(int)position.y-offset);
}
- (CGPoint)anchorBL {
	int offset = (int)sqrt((float)(radius*radius)/(float)2);
	return ccp((int)position.x-offset,(int)position.y-offset);
}
- (CGPoint)anchorTL {
	int offset = (int)sqrt((float)(radius*radius)/(float)2);
	return ccp((int)position.x-offset,(int)position.y+offset);
}
- (CGPoint)anchorT {
	return ccp((int)position.x,(int)position.y+radius);
}
- (CGPoint)anchorR {
	return ccp((int)position.x+radius,(int)position.y);
}
- (CGPoint)anchorB {
	return ccp((int)position.x,(int)position.y-radius);
}
- (CGPoint)anchorL {
	return ccp((int)position.x-radius,(int)position.y);
}
- (void)setPosition:(CGPoint)pos {
	position = pos;
}
- (void)makeStartState {
	startState = YES;
}
- (void)makeAcceptState {
	acceptState = YES;
}
- (BOOL)isStartState {
	return startState;
}
- (BOOL)isAcceptState {
	return acceptState;
}
- (void)removeStartState {
	startState = NO;
}
- (void)removeAcceptState {
	acceptState = NO;
}

@end
