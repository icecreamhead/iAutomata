//
//  iAutomataState.h
//  iAutomata
//
//  Created by Josh on 04/01/2011.
//  Copyright 2011 Josh Cooke. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface iAutomataState : NSObject {
	NSString *name;
	CGPoint position;
	BOOL startState, acceptState;
	int radius;
}
@property int radius;
+ (iAutomataState*)initWithName:(NSString*)n coordinates:(CGPoint)pos;
- (void)setName:(NSString*)n;
- (NSString*)getName;
- (CGPoint)getPosition;
- (CGPoint)anchorTR;
- (CGPoint)anchorBR;
- (CGPoint)anchorBL;
- (CGPoint)anchorTL;
- (CGPoint)anchorT;
- (CGPoint)anchorR;
- (CGPoint)anchorB;
- (CGPoint)anchorL;
- (void)setPosition:(CGPoint)pos;
- (void)makeStartState;
- (void)makeAcceptState;
- (BOOL)isStartState;
- (BOOL)isAcceptState;
- (void)removeStartState;
- (void)removeAcceptState;

@end
